import {spawn} from 'node:child_process';
import readline from 'node:readline';
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
const root=new URL('./',import.meta.url);
const state=JSON.parse(fs.readFileSync(new URL('bmad-change-state.json',root),'utf8'));
const backup=JSON.parse(fs.readFileSync(new URL('bmad-change-backup.json',root),'utf8'));
const server=fileURLToPath(new URL('../../mcp-jira/server.mjs',root));
const child=spawn(process.execPath,[server],{env:process.env,stdio:['pipe','pipe','inherit']});
const lines=readline.createInterface({input:child.stdout});let seq=0;const pending=new Map();
lines.on('line',line=>{const m=JSON.parse(line);pending.get(m.id)?.(m);});
function rpc(method,params={}){return new Promise((resolve,reject)=>{const id=++seq;const timer=setTimeout(()=>{pending.delete(id);reject(new Error('MCP timeout'));},90000);pending.set(id,m=>{clearTimeout(timer);pending.delete(id);m.error?reject(new Error(m.error.message)):resolve(m.result);});child.stdin.write(JSON.stringify({jsonrpc:'2.0',id,method,params})+'\n');});}
async function call(name,args){const r=await rpc('tools/call',{name,arguments:args});if(r.isError)throw new Error(`${name}: ${r.content[0].text}`);return r.structuredContent.data;}
async function read(name,args){for(let n=0;n<8;n++){try{return await call(name,args);}catch(e){if(!e.message.includes('HTTP 429')||n===7)throw e;await new Promise(r=>setTimeout(r,15000+n*5000));}}}
try{
 await rpc('initialize',{protocolVersion:'2025-06-18'});
 const keys=[...state.deprecated,...state.refined,...state.created.map(x=>x.key)];
 const after=[];for(let i=0;i<keys.length;i+=5)after.push(...await Promise.all(keys.slice(i,i+5).map(key=>read('zephyr_get_test',{key}))));
 const byKey=new Map(after.map(x=>[x.key,x]));
 for(const key of state.deprecated){const a=byKey.get(key),b=backup.tests[key];assert.equal(a.status,'Deprecated');assert.equal(a.testScript.type,b.testScript.type);assert.equal(a.testScript.text,b.testScript.text);assert.deepEqual(a.issueLinks,b.issueLinks);assert.deepEqual(a.labels,b.labels);assert.equal(a.lastTestResultStatus??null,b.lastTestResultStatus??null);}
 for(const key of state.refined){const a=byKey.get(key),b=backup.tests[key];assert.equal(a.status,b.status);assert.equal(a.testScript.type,'BDD');assert.deepEqual(a.issueLinks,b.issueLinks);assert.deepEqual(a.labels,b.labels);assert.equal(a.lastTestResultStatus??null,b.lastTestResultStatus??null);}
 for(const c of state.created){const a=byKey.get(c.key);assert.equal(a.name,c.name);assert.equal(a.status,'Draft');assert.equal(a.testScript.type,'BDD');assert.ok(a.issueLinks.includes(c.story));assert.ok([undefined,'Not Executed'].includes(a.lastTestResultStatus));assert.ok(!a.folder,`${c.key} possui pasta inesperada`);}
 const cycles=[];let start_at=0;while(true){const page=await read('zephyr_search_cycles',{project_key:'ETICS',max_results:100,start_at});cycles.push(...page);if(page.length<100)break;start_at+=100;if(start_at>10000)throw new Error('Cycle limit');}
 const affected=new Set(keys),newKeys=new Set(state.created.map(x=>x.key));
 const cycleMembership=cycles.filter(c=>(c.items||[]).some(i=>affected.has(i.testCaseKey))).map(c=>({key:c.key,name:c.name,members:(c.items||[]).filter(i=>affected.has(i.testCaseKey)).map(i=>({key:i.testCaseKey,status:i.status}))}));
 assert.equal(cycleMembership.flatMap(c=>c.members).filter(x=>newKeys.has(x.key)).length,0,'Novo caso entrou em ciclo inesperadamente');
 const result={verifiedAt:new Date().toISOString(),deprecated:state.deprecated.length,refined:state.refined.length,created:state.created,allBdd:after.every(x=>x.testScript?.type==='BDD'),cycleSearchCount:cycles.length,cycleMembership};
 fs.writeFileSync(new URL('bmad-change-verification.json',root),JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify({verified:keys.length,deprecated:result.deprecated,refined:result.refined,created:result.created.length,cycles:cycles.length,affectedCycles:cycleMembership.map(x=>x.key)}));
}catch(e){console.error(e.message);process.exitCode=1;}finally{child.kill();lines.close();}
