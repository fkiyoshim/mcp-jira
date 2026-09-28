import {spawn} from 'node:child_process';
import readline from 'node:readline';
import fs from 'node:fs';
import {fileURLToPath} from 'node:url';
const server=fileURLToPath(new URL('../../mcp-jira/server.mjs',import.meta.url));
const output=fileURLToPath(new URL('./bmad-h09-snapshot.json',import.meta.url));
const child=spawn(process.execPath,[server],{env:process.env,stdio:['pipe','pipe','inherit']});
const lines=readline.createInterface({input:child.stdout});let seq=0;const pending=new Map();
lines.on('line',line=>{const m=JSON.parse(line);pending.get(m.id)?.(m);});
function rpc(method,params={}){return new Promise((resolve,reject)=>{const id=++seq;const timer=setTimeout(()=>{pending.delete(id);reject(new Error('Timeout'));},90000);pending.set(id,m=>{clearTimeout(timer);pending.delete(id);m.error?reject(new Error(m.error.message)):resolve(m.result);});child.stdin.write(JSON.stringify({jsonrpc:'2.0',id,method,params})+'\n');});}
async function call(name,args){const r=await rpc('tools/call',{name,arguments:args});if(r.isError)throw new Error(`${name}: ${r.content[0].text}`);return r.structuredContent.data;}
async function retry(name,args){for(let n=0;n<8;n++){try{return await call(name,args);}catch(e){if(!e.message.includes('HTTP 429')||n===7)throw e;await new Promise(r=>setTimeout(r,15000+n*5000));}}}
try{
 await rpc('initialize',{protocolVersion:'2025-06-18'});
 const issue_key='ETICS-253096';
 const [story,comments]=await Promise.all([retry('jira_get_issue',{issue_key,fields:['summary','description','status','issuetype','labels','updated','issuelinks']}),retry('jira_get_comments',{issue_key,max_results:100,start_at:0})]);
 const found=[];let start=0;
 while(true){const starts=Array.from({length:5},(_,i)=>start+i*100);const pages=await Promise.all(starts.map(start_at=>retry('zephyr_search_tests',{project_key:'ETICS',max_results:100,start_at})));for(const p of pages)found.push(...p);if(pages.some(p=>p.length<100))break;start+=500;if(start>20000)throw new Error('Scan limit');}
 const related=found.filter(t=>(t.issueLinks||[]).includes(issue_key)||/RECON-H09/.test(t.name||''));
 const tests=[];for(const t of related){tests.push(await retry('zephyr_get_test',{key:t.key}));await new Promise(r=>setTimeout(r,250));}
 const snapshot={capturedAt:new Date().toISOString(),story,comments,scanned:found.length,tests};fs.writeFileSync(output,JSON.stringify(snapshot,null,2)+'\n');console.log(JSON.stringify({output,scanned:found.length,related:tests.length,title:story.fields.summary}));
}catch(e){console.error(e.message);process.exitCode=1;}finally{child.kill();lines.close();}
