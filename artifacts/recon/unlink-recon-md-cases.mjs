import { spawn } from 'node:child_process';
import readline from 'node:readline';
import fs from 'node:fs';
import { fileURLToPath } from 'node:url';

const firstOnly = process.argv.includes('--first');
const base = new URL('./', import.meta.url);
const manifest = JSON.parse(fs.readFileSync(new URL('h02-h08-md-published.json', base), 'utf8'));
const backup = JSON.parse(fs.readFileSync(new URL('h02-h08-md-before-removal-2026-09-24.json', base), 'utf8'));
const progressUrl = new URL('h02-h08-md-unlink-progress.json', base);
const progress = fs.existsSync(progressUrl) ? JSON.parse(fs.readFileSync(progressUrl, 'utf8')) : {
  startedAt: new Date().toISOString(), action: 'Remove only issueLinks from MD test cases', done: [],
};
const done = new Set(progress.done);
if (manifest.length !== 63 || Object.keys(backup.cases).length !== 63) throw new Error('Unexpected manifest/backup size');
const server = fileURLToPath(new URL('../../mcp-jira/server.mjs', import.meta.url));
const child = spawn(process.execPath, [server, '--write'], { env: process.env, stdio: ['pipe', 'pipe', 'inherit'] });
const reader = readline.createInterface({ input: child.stdout });
const pending = new Map();
let sequence = 0;
reader.on('line', line => { const message = JSON.parse(line); pending.get(message.id)?.(message); });
const rpc = (method, params = {}) => new Promise((resolve, reject) => {
  const id = ++sequence;
  const timer = setTimeout(() => { pending.delete(id); reject(new Error('MCP timeout')); }, 45000);
  pending.set(id, message => { clearTimeout(timer); pending.delete(id); resolve(message); });
  child.stdin.write(JSON.stringify({ jsonrpc: '2.0', id, method, params }) + '\n');
});
async function call(name, args) {
  const response = await rpc('tools/call', { name, arguments: args });
  if (response.result?.isError) throw new Error(response.result.content?.[0]?.text);
  return response.result?.structuredContent?.data;
}
function save() { fs.writeFileSync(progressUrl, JSON.stringify(progress, null, 2) + '\n'); }
try {
  await rpc('initialize', { protocolVersion: '2025-06-18' });
  for (const item of manifest) {
    if (done.has(item.key)) continue;
    const before = backup.cases[item.key];
    if (!before || before.name !== `${item.id} — ${before.name.split(' — ').slice(1).join(' — ')}` ||
      !before.name.startsWith(item.id + ' — ') ||
      !before.labels?.includes('RECON_H02_H08_MD') ||
      JSON.stringify(before.issueLinks) !== JSON.stringify([item.story])) {
      throw new Error(`Backup mismatch: ${item.key}`);
    }
    const current = await call('zephyr_get_test', { key: item.key });
    if (current.name !== before.name || !current.labels?.includes('RECON_H02_H08_MD')) throw new Error(`Remote identity changed: ${item.key}`);
    if (JSON.stringify(current.issueLinks ?? []) === '[]') {
      progress.done.push(item.key); done.add(item.key); save();
      console.log(`${item.key} already unlinked`);
      if (firstOnly) break;
      continue;
    }
    if (JSON.stringify(current.issueLinks) !== JSON.stringify([item.story])) throw new Error(`Remote links changed: ${item.key}`);
    await call('zephyr_update_test', { key: item.key, issue_links: [] });
    const after = await call('zephyr_get_test', { key: item.key });
    if (JSON.stringify(after.issueLinks ?? []) !== '[]' || after.name !== current.name ||
      after.status !== current.status || after.testScript?.text !== current.testScript?.text ||
      after.testScript?.type !== current.testScript?.type ||
      JSON.stringify(after.labels) !== JSON.stringify(current.labels)) {
      throw new Error(`Post-update verification failed: ${item.key}`);
    }
    progress.done.push(item.key); done.add(item.key); save();
    console.log(`${item.key} unlinked and verified (${done.size}/63)`);
    if (firstOnly) break;
  }
  console.log(JSON.stringify({ completed: done.size, total: manifest.length, progress: fileURLToPath(progressUrl) }));
} finally { child.kill(); reader.close(); }
