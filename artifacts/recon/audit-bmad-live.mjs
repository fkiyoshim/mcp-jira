import {spawn} from 'node:child_process';
import readline from 'node:readline';
import fs from 'node:fs';
import {fileURLToPath} from 'node:url';

const server = fileURLToPath(new URL('../../mcp-jira/server.mjs', import.meta.url));
const output = fileURLToPath(new URL('./bmad-live-snapshot.json', import.meta.url));
const child = spawn(process.execPath, [server], {env:process.env, stdio:['pipe','pipe','inherit']});
const input = readline.createInterface({input:child.stdout});
const pending = new Map();
let seq=0;
input.on('line', line => {
  const m=JSON.parse(line);
  pending.get(m.id)?.(m);
});
function rpc(method, params={}) {
  return new Promise((resolve,reject) => {
    const id=++seq;
    const timeout=setTimeout(() => {pending.delete(id); reject(new Error(`${method} timeout`));}, 90000);
    pending.set(id,m => {clearTimeout(timeout);pending.delete(id);m.error?reject(new Error(m.error.message)):resolve(m.result);});
    child.stdin.write(JSON.stringify({jsonrpc:'2.0',id,method,params})+'\n');
  });
}
async function call(name, args) {
  const r=await rpc('tools/call',{name,arguments:args});
  if(r.isError) throw new Error(`${name}: ${r.content?.[0]?.text}`);
  return r.structuredContent.data;
}
async function resilientCall(name,args) {
  for(let attempt=0;attempt<8;attempt++) {
    try { return await call(name,args); }
    catch(e) {
      if(!String(e.message).includes('HTTP 429') || attempt===7) throw e;
      await new Promise(resolve=>setTimeout(resolve,15000+attempt*5000));
    }
  }
}
const storyKeys=['ETICS-252410','ETICS-252562','ETICS-252569','ETICS-252611','ETICS-252614','ETICS-252615','ETICS-252629','ETICS-252632'];
try {
  await rpc('initialize',{protocolVersion:'2025-06-18'});
  const [stories,comments,epicSearch]=await Promise.all([
    Promise.all(storyKeys.map(issue_key=>call('jira_get_issue',{issue_key,fields:['summary','description','status','issuetype','labels','updated','issuelinks','customfield_10008']}))),
    Promise.all(storyKeys.map(issue_key=>call('jira_get_comments',{issue_key,max_results:100,start_at:0}))),
    call('jira_search_issues',{jql:'"Epic Link" = ETICS-245531',fields:['summary','status','issuetype','labels'],max_results:100,start_at:0}).catch(e=>({error:e.message}))
  ]);
  const found=[];
  const pageSize=100;
  let start=0;
  while(true) {
    const starts=Array.from({length:5},(_,i)=>start+i*pageSize);
    const pages=await Promise.all(starts.map(start_at=>call('zephyr_search_tests',{project_key:'ETICS',max_results:pageSize,start_at})));
    for(const page of pages) {
      if(!Array.isArray(page)) throw new Error('Formato inesperado da busca Zephyr');
      found.push(...page);
    }
    console.log(JSON.stringify({scanned:found.length}));
    if(pages.some(p=>p.length<pageSize)) break;
    start+=5*pageSize;
    if(start>20000) throw new Error('Limite de varredura excedido');
  }
  const keys=new Set(storyKeys);
  const related=found.filter(t => (t.issueLinks||[]).some(k=>keys.has(k)) || (t.labels||[]).some(l=>/^RECON_H0[1-8]/.test(l)) || /RECON-H0[1-8]/.test(t.name||''));
  fs.writeFileSync(output,JSON.stringify({capturedAt:new Date().toISOString(),source:'MCP local cpqd_jira',boardScopeVerified:false,storyKeys,stories,comments,epicSearch,testSearch:{scanned:found.length,related:related.length},tests:related,detailPending:true},null,2)+'\n');
  const detail=[];
  for(let i=0;i<related.length;i++) {
    detail.push(await resilientCall('zephyr_get_test',{key:related[i].key}));
    if((i+1)%20===0) console.log(JSON.stringify({detailed:i+1}));
    await new Promise(resolve=>setTimeout(resolve,250));
  }
  const snapshot={capturedAt:new Date().toISOString(),source:'MCP local cpqd_jira',boardScopeVerified:false,storyKeys,stories,comments,epicSearch,testSearch:{scanned:found.length,related:related.length},tests:detail};
  fs.writeFileSync(output,JSON.stringify(snapshot,null,2)+'\n');
  console.log(JSON.stringify({output,stories:stories.length,epicSearchTotal:epicSearch.total??null,scanned:found.length,related:detail.length}));
} catch(e) {console.error(e.message);process.exitCode=1;}
finally {child.kill();input.close();}
