import {spawn} from 'node:child_process';
import readline from 'node:readline';
import fs from 'node:fs';
import {fileURLToPath} from 'node:url';
const server=fileURLToPath(new URL('../../mcp-bitbucket/server.mjs',import.meta.url));
const child=spawn(process.execPath,[server],{env:process.env,stdio:['pipe','pipe','inherit']});
const lines=readline.createInterface({input:child.stdout});let seq=0;const pending=new Map();
lines.on('line',line=>{const m=JSON.parse(line);pending.get(m.id)?.(m);});
function rpc(method,params={}){return new Promise((resolve,reject)=>{const id=++seq;const timer=setTimeout(()=>{pending.delete(id);reject(new Error('Timeout'));},60000);pending.set(id,m=>{clearTimeout(timer);pending.delete(id);m.error?reject(new Error(m.error.message)):resolve(m.result);});child.stdin.write(JSON.stringify({jsonrpc:'2.0',id,method,params})+'\n');});}
async function call(name,args){const r=await rpc('tools/call',{name,arguments:args});if(r.isError)throw new Error(r.content[0].text);return r.structuredContent.data;}
const branch='feature/claro-recon';
try{
 await rpc('initialize',{protocolVersion:'2025-06-18'});
 const dir=await call('bitbucket_get_file',{project_key:'GP',repository_slug:'gp',path:'docs/dev/13.3.200/recon',at:branch});
 fs.writeFileSync(new URL('./bmad-md-directory.json',import.meta.url),JSON.stringify(dir,null,2)+'\n');
 console.log(JSON.stringify({directoryKeys:Object.keys(dir),children:dir.children?.values?.map(x=>x.path?.name)||dir.children?.map?.(x=>x.path?.name)}));
 const names=['06-sincronizacao-json-im-gp-device-ha.md','07-sincronizacao-json-im-gp-route-static.md','08-sincronizacao-json-im-gp-roteamento-dinamico.md','09-reconciliar-versao-software-roteador.md'];
 for(const name of names){const result=await call('bitbucket_get_file',{project_key:'GP',repository_slug:'gp',path:'docs/dev/13.3.200/recon/'+name,at:branch});fs.writeFileSync(new URL('./bmad-'+name,import.meta.url),result.content??JSON.stringify(result,null,2));console.log(JSON.stringify({file:name,length:result.content?.length??null}));}
}catch(e){console.error(e.message);process.exitCode=1;}finally{child.kill();lines.close();}
