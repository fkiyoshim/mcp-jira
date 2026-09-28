import fs from 'node:fs/promises';
import path from 'node:path';
const inventory=JSON.parse(await fs.readFile(new URL('./documents-recon-inventory.json',import.meta.url),'utf8'));
const docs=inventory.documents.filter(x=>!x.path.includes('Resultado_Testes_Sistemicos/'));
const root=path.resolve('artifacts/recon/documents-review');
const base=(process.env.BITBUCKET_BASE_URL||'https://bitbucket.cpqd.com.br').replace(/\/+$/,'');
const token=process.env.BITBUCKET_TOKEN?.trim();
const username=process.env.BITBUCKET_USERNAME?.trim();
const password=process.env.BITBUCKET_PASSWORD?.trim();
const authorization=token?`Bearer ${token}`:username&&password?`Basic ${Buffer.from(`${username}:${password}`,'utf8').toString('base64')}`:null;
if(!authorization)throw new Error('Credencial Bitbucket ausente');
const results=[];
for(const {path:remotePath} of docs){
 const url=new URL('/rest/api/1.0/projects/GP/repos/documents/raw/'+remotePath.split('/').map(encodeURIComponent).join('/'),base);
 const response=await fetch(url,{headers:{Authorization:authorization}});
 if(!response.ok)throw new Error(`Bitbucket HTTP ${response.status} em ${remotePath}`);
 const data=Buffer.from(await response.arrayBuffer());
 const target=path.join(root,...remotePath.split('/'));
 await fs.mkdir(path.dirname(target),{recursive:true});
 await fs.writeFile(target,data);
 results.push({remotePath,localPath:target,size:data.length,contentType:response.headers.get('content-type')});
 console.log(JSON.stringify({path:remotePath,size:data.length}));
}
await fs.writeFile(path.join(root,'download-manifest.json'),JSON.stringify(results,null,2)+'\n');
