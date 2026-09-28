import fs from 'node:fs';
const base=(process.env.BITBUCKET_BASE_URL||'https://bitbucket.cpqd.com.br').replace(/\/+$/,'');
const token=process.env.BITBUCKET_TOKEN?.trim();
const username=process.env.BITBUCKET_USERNAME?.trim();
const password=process.env.BITBUCKET_PASSWORD?.trim();
const authorization=token?`Bearer ${token}`:username&&password?`Basic ${Buffer.from(`${username}:${password}`,'utf8').toString('base64')}`:null;
if(!authorization)throw new Error('Credencial Bitbucket ausente no ambiente');
const basePath='/rest/api/1.0/projects/GP/repos/documents/browse';
async function browse(path,start=0){
 const url=new URL(basePath+(path?'/'+path.split('/').map(encodeURIComponent).join('/'):''),base);
 url.searchParams.set('limit','1000');
 if(start)url.searchParams.set('start',String(start));
 const response=await fetch(url,{headers:{Accept:'application/json',Authorization:authorization}});
 if(!response.ok)throw new Error(`Bitbucket HTTP ${response.status} em ${path||'/'} [${start}]`);
 return response.json();
}
const directories=[''];const files=[];let scanned=0;
for(let cursor=0;cursor<directories.length;cursor++){
 const path=directories[cursor];let start=0;
 while(true){
  const data=await browse(path,start);const children=data.children;
  if(!children||!Array.isArray(children.values))throw new Error(`Resposta inesperada em ${path}`);
  for(const item of children.values){
   const relative=typeof item.path?.toString==='string'?item.path.toString:item.path?.components?.join('/');
   const childPath=path&&relative&&!relative.startsWith(path+'/')?path+'/'+relative:relative;
   if(!childPath)throw new Error(`Path ausente em ${path}`);
   if(item.type==='DIRECTORY')directories.push(childPath);
   else files.push({path:childPath,type:item.type});
  }
  if(children.isLastPage)break;
  start=children.nextPageStart;
  if(!Number.isInteger(start))throw new Error(`Pagina sem cursor em ${path}`);
 }
 scanned++;
 if(scanned%50===0)console.log(JSON.stringify({scannedDirectories:scanned,queuedDirectories:directories.length,files:files.length}));
 if(directories.length>20000)throw new Error('Limite de diretórios excedido');
}
const related=files.filter(f=>/(^|[\/._-])recon(?=([\/._-]|x|$))|reconcili/i.test(f.path));
const documents=related.filter(f=>/\.(odt|ods|xls|xlsx|doc|docx|pdf|ppt|pptx)$/i.test(f.path));
const support=related.filter(f=>!documents.includes(f)&&!f.path.includes('/javadoc-commons/'));
const result={searchedAt:new Date().toISOString(),repository:'GP/documents',revision:'default',directories:directories.length,files:files.length,documents,support};
fs.writeFileSync(new URL('./documents-recon-inventory.json',import.meta.url),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
