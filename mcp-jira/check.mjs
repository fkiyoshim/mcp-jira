// Read-only MCP smoke check against the configured service; no content or credentials logged.
import { spawn } from 'node:child_process';
import readline from 'node:readline';
import { fileURLToPath } from 'node:url';
const child=spawn(process.execPath,[fileURLToPath(new URL('./server.mjs',import.meta.url)),'--write'],{env:process.env,stdio:['pipe','pipe','inherit']});
let seq=0;
const pending=new Map();
const lines=readline.createInterface({input:child.stdout});
lines.on('line',line=>{const message=JSON.parse(line);pending.get(message.id)?.(message);});
function rpc(method,params={}) { return new Promise((resolve,reject)=>{
  const id=++seq; const timer=setTimeout(()=>{pending.delete(id);reject(new Error('MCP timeout'));},45000);
  pending.set(id,m=>{clearTimeout(timer);pending.delete(id);resolve(m);});
  child.stdin.write(JSON.stringify({jsonrpc:'2.0',id,method,params})+'\n');
}); }
try {
  const init=await rpc('initialize',{protocolVersion:'2025-06-18'});
  const listed=await rpc('tools/list');
  console.log(JSON.stringify({server:init.result.serverInfo,tools:listed.result.tools.map(t=>({name:t.name,readOnly:t.annotations.readOnlyHint}))}));
  for(const [name,args] of [['jira_get_permissions',{project_key:'ETICS'}],['zephyr_search_tests',{project_key:'ETICS',max_results:1}],['zephyr_search_cycles',{project_key:'ETICS',max_results:1}]]) {
    const r=await rpc('tools/call',{name,arguments:args});
    const data=r.result?.structuredContent?.data;
    console.log(JSON.stringify({name,success:r.result?.isError===false,permissions:data?.permissions && Object.fromEntries(['BROWSE_PROJECTS','CREATE_ISSUES','EDIT_ISSUES','LINK_ISSUES'].map(k=>[k,data.permissions[k]?.havePermission])),count:Array.isArray(data)?data.length:undefined,error:r.result?.isError?r.result.content:undefined}));
    if(r.result?.isError) process.exitCode=1;
  }
} finally {child.kill();lines.close();}
