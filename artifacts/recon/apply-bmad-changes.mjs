import {spawn} from 'node:child_process';
import readline from 'node:readline';
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';

const root=new URL('./',import.meta.url);
const snapshot=JSON.parse(fs.readFileSync(new URL('bmad-live-snapshot.json',root),'utf8'));
const h09=JSON.parse(fs.readFileSync(new URL('bmad-h09-snapshot.json',root),'utf8'));
const backupPath=new URL('bmad-change-backup.json',root);
const statePath=new URL('bmad-change-state.json',root);
const prior=new Map(snapshot.tests.map(t=>[t.key,t]));
const deprecated=[
  ...Array.from({length:5},(_,i)=>`ETICS-T${8072+i}`),
  ...Array.from({length:9},(_,i)=>`ETICS-T${8146+i}`),
  ...Array.from({length:4},(_,i)=>`ETICS-T${8077+i}`),
  'ETICS-T8155',
  'ETICS-T8082','ETICS-T8083','ETICS-T8084',
];
const reason=key=>{
  if(+key.split('T')[1]>=8072 && +key.split('T')[1]<=8076 || +key.split('T')[1]>=8146 && +key.split('T')[1]<=8154) return 'H06 atual descreve OSPF no Device; este caso descreve HA da versão anterior da história.';
  if(['ETICS-T8077','ETICS-T8078','ETICS-T8079','ETICS-T8080','ETICS-T8155'].includes(key)) return 'H07 atual especifica Roteamento Estático FN; identidade e de/para dos casos anteriores não estão aprovados para FN.';
  return 'H08 atual cobre BGP e relacionados; OSPF e RIP não pertencem mais à descrição atual da H08.';
};
const refinements=[
  {
    key:'ETICS-T8085',
    name:'RECON-H08-05 — Preservar objetos alheios ao atualizar BGP',
    objective:'Cobrir preservação de objetos JSON não recebidos ao atualizar BGP. História ETICS-252632 (escopo atual); regra de não exclusão da H04. Exige contrato BGP homologado.',
    precondition:'Ambiente GP/IM; Roteador pareado sem divergência física; H04 e mapeamento BGP homologado disponíveis; documento GP com BGP e outros objetos JSON; registrar snapshot antes e depois.',
    bdd_script:[
      'Given o documento JSON do Roteador contém BGP e outros objetos de configuração válidos',
      'And o IM fornece uma configuração BGP alterada sem fornecer novamente os outros objetos',
      'When o usuário acionar Atualizar inventário',
      'Then a configuração BGP é atualizada conforme o contrato homologado',
      'And os objetos não recebidos do IM permanecem inalterados no documento JSON do Roteador'
    ].join('\n')
  },
  {
    key:'ETICS-T8156',
    name:'RECON-H08-MD-01 — Não persistir BGP com contrato final pendente',
    objective:'Caso de proteção do contrato BGP da H08 atual (ETICS-252632). O projeto técnico 08 ainda está em draft para de/para, identidade, subgrupos e tratamento de credenciais. Reavaliar após aprovação.',
    precondition:'Validação técnica. Fixture BGP sintética; contrato final BGP ainda pendente; snapshots de CLOB/GP e spies do upsert e NestedRuleCaller.',
    bdd_script:[
      'Given que o contrato final de BGP da H08 continua pendente',
      'And a resposta IM contém um grupo BGP representativo com dados sintéticos',
      'When a coleta for processada e Atualizar inventário for solicitado',
      'Then o fragmento BGP provisório não é persistido no CLOB do Recon',
      'And não é aplicado por upsert nem enviado ao NestedRuleCaller',
      'And nenhum objectType, chave de negócio ou destino final é inferido do XML provisório'
    ].join('\n')
  }
];
const commonLabels=['CLARO_RECON','RECON_H01_H09','TESTE_DESENVOLVIMENTO'];
const newCases=[
  {
    name:'RECON-H06-OSPF-01 — Sincronizar OSPF no Device do Roteador',story:'ETICS-252615',
    objective:'Cobertura mínima da descrição atual da H06. Fonte: ETICS-252615 em 24/09/2026. Pendente contrato de de/para e fixture OSPF; o projeto técnico 06 disponível ainda descreve HA.',
    precondition:'Ambiente GP/IM; Roteador pareado; H04 disponível; fixture OSPF e mapeamento para Device homologados antes da execução.',
    script:[
      'Given um Roteador pareado possui configuração OSPF no IM e documento JSON atual no GP',
      'And o contrato de conversão OSPF para Device está homologado',
      'When executar a reconciliação sem solicitar atualização',
      'Then o documento JSON do Roteador no GP permanece inalterado',
      'When o usuário acionar Atualizar inventário',
      'Then a configuração OSPF recebida do IM é aplicada ao objeto JSON Device conforme o contrato homologado'
    ].join('\n')
  },
  {
    name:'RECON-H07-FN-01 — Sincronizar Roteamento Estático FN no JSON do Roteador',story:'ETICS-252629',
    objective:'Cobertura mínima da descrição atual da H07. Fonte: ETICS-252629 em 24/09/2026. Pendente contrato FN de origem, identidade, cardinalidade e destino; não inferir chave da visão 01.01.',
    precondition:'Ambiente GP/IM; Roteador pareado; H04 disponível; fixture de Roteamento Estático FN e contrato JSON homologados antes da execução.',
    script:[
      'Given o IM fornece um objeto de Roteamento Estático FN para um Roteador pareado',
      'And o contrato FN de conversão, identidade e destino JSON está homologado',
      'When executar a reconciliação sem solicitar atualização',
      'Then o documento JSON do Roteador no GP permanece inalterado',
      'When o usuário acionar Atualizar inventário',
      'Then o objeto FN recebido é aplicado ao documento JSON do Roteador conforme o contrato homologado'
    ].join('\n')
  },
  {
    name:'RECON-H09-01 — Não divergir para versões de software iguais',story:'ETICS-253096',
    objective:'H09 critério de aceitação 1; projeto técnico 09, Versão de Software do Roteador.',
    precondition:'Roteador pareado; resposta IM com softwareVersion e GP com SOFTWARE_VERSION; configuração SOFTWARE_VERSION=1.',
    script:['Given SOFTWARE_VERSION está configurado como 1 para o Roteador','And GP e IM informam a mesma versão de software','When o Recon comparar o equipamento','Then a versão de software não gera divergência'].join('\n')
  },
  {
    name:'RECON-H09-02 — Mostrar divergência e os dois valores da versão',story:'ETICS-253096',
    objective:'H09 critério de aceitação 2; projeto técnico 09.',
    precondition:'Roteador pareado; resposta IM com softwareVersion distinto de IP_NE.SOFTWARE_VERSION; configuração SOFTWARE_VERSION=1.',
    script:['Given SOFTWARE_VERSION está configurado como 1 para o Roteador','And a versão informada pelo IM difere da versão no GP','When o usuário consultar o resultado da reconciliação','Then a versão de software é marcada como divergente','And os valores ISP e IM estão disponíveis no resultado'].join('\n')
  },
  {
    name:'RECON-H09-03 — Ignorar diferença da versão configurada com 0',story:'ETICS-253096',
    objective:'H09 critério de aceitação 3; projeto técnico 09.',
    precondition:'Roteador pareado; GP e IM com versões diferentes; configuração SOFTWARE_VERSION=0.',
    script:['Given SOFTWARE_VERSION está configurado como 0 para o Roteador','And as versões de software do IM e do GP são diferentes','When o Recon comparar o equipamento','Then a diferença de versão não altera o resultado da reconciliação'].join('\n')
  },
  {
    name:'RECON-H09-04 — Atualizar SOFTWARE_VERSION selecionado',story:'ETICS-253096',
    objective:'H09 critério de aceitação 4; projeto técnico 09.',
    precondition:'Roteador fisicamente consistente; SOFTWARE_VERSION=1; divergência de versão selecionada; fluxo de atualização de equipamento permitido.',
    script:['Given o resultado do Roteador mostra divergência de SOFTWARE_VERSION','And a divergência de versão foi selecionada para atualização','When o usuário acionar Atualizar inventário','Then IP_NE.SOFTWARE_VERSION recebe o valor de softwareVersion informado pelo IM'].join('\n')
  },
  {
    name:'RECON-H09-05 — Inicializar configurações antigas com valor 0',story:'ETICS-253096',
    objective:'H09 critério de aceitação 5; projeto técnico 09. Validação técnica do patch e da configuração existente.',
    precondition:'Base instalada antes da H09; patch idempotente aplicado; configuração de atributos preexistente.',
    script:['Given uma configuração de atributos criada antes da H09','And o patch de SOFTWARE_VERSION foi aplicado à base','When a configuração for lida pelo Recon','Then SOFTWARE_VERSION vale 0','And a configuração preexistente continua utilizável'].join('\n')
  },
  {
    name:'RECON-H09-06 — Aceitar ausência de softwareVersion no IM',story:'ETICS-253096',
    objective:'H09 critério de aceitação 6; projeto técnico 09. Dependência externa: IM deve publicar o elemento opcional para comparação real.',
    precondition:'Contrato IM com softwareVersion opcional; fixture de resposta sem esse elemento; Roteador pareado.',
    script:['Given a resposta do serviço IM não contém softwareVersion','When o Recon processar a resposta e executar a reconciliação','Then o valor ausente é tratado como vazio','And a reconciliação não falha por causa dessa ausência'].join('\n')
  }
];
const plan={capturedAt:new Date().toISOString(),sourceSnapshot:snapshot.capturedAt,storiesCurrent:['ETICS-252615','ETICS-252629','ETICS-252632','ETICS-253096'],deprecated:deprecated.map(key=>({key,reason:reason(key)})),refinements:refinements.map(({key,name})=>({key,name})),newCases:newCases.map(({name,story})=>({name,story}))};
fs.writeFileSync(new URL('bmad-change-plan.json',root),JSON.stringify(plan,null,2)+'\n');
console.log(JSON.stringify({plan:'bmad-change-plan.json',deprecated:deprecated.length,refinements:refinements.length,create:newCases.length}));
if(!process.argv.includes('--apply')) process.exit(0);

const server=fileURLToPath(new URL('../../mcp-jira/server.mjs',root));
const child=spawn(process.execPath,[server,'--write'],{env:process.env,stdio:['pipe','pipe','inherit']});
const lines=readline.createInterface({input:child.stdout});let seq=0;const pending=new Map();
lines.on('line',line=>{const m=JSON.parse(line);pending.get(m.id)?.(m);});
function rpc(method,params={}){return new Promise((resolve,reject)=>{const id=++seq;const timer=setTimeout(()=>{pending.delete(id);reject(new Error('MCP timeout; reler antes de repetir'));},90000);pending.set(id,m=>{clearTimeout(timer);pending.delete(id);m.error?reject(new Error(m.error.message)):resolve(m.result);});child.stdin.write(JSON.stringify({jsonrpc:'2.0',id,method,params})+'\n');});}
async function call(name,args){const r=await rpc('tools/call',{name,arguments:args});if(r.isError)throw new Error(`${name}: ${r.content[0].text}`);return r.structuredContent.data;}
async function read(name,args){for(let n=0;n<8;n++){try{return await call(name,args);}catch(e){if(!e.message.includes('HTTP 429')||n===7)throw e;await new Promise(r=>setTimeout(r,15000+n*5000));}}}
function save(path,v){fs.writeFileSync(path,JSON.stringify(v,null,2)+'\n');}
const state=fs.existsSync(statePath)?JSON.parse(fs.readFileSync(statePath,'utf8')):{startedAt:new Date().toISOString(),deprecated:[],refined:[],created:[],errors:[]};
const backup=fs.existsSync(backupPath)?JSON.parse(fs.readFileSync(backupPath,'utf8')):{capturedAt:new Date().toISOString(),tests:{}};
function record(){save(statePath,state);save(backupPath,backup);}
function guard(live,original){
  assert.equal(live.name,original.name,`${live.key} nome mudou`);
  assert.equal(live.status,original.status,`${live.key} status mudou`);
  assert.equal(live.testScript?.text,original.testScript?.text,`${live.key} roteiro mudou`);
  assert.deepEqual(live.issueLinks,original.issueLinks,`${live.key} vínculos mudaram`);
  assert.equal(live.lastTestResultStatus??null,original.lastTestResultStatus??null,`${live.key} execução mudou`);
}
try{
 await rpc('initialize',{protocolVersion:'2025-06-18'});
 for(const key of deprecated){
   if(state.deprecated.includes(key))continue;
   const live=await read('zephyr_get_test',{key});const original=prior.get(key);assert.ok(original,key+' ausente no snapshot');guard(live,original);
   assert.ok(['Not Executed',undefined].includes(live.lastTestResultStatus),key+' possui execução');
   backup.tests[key]=live;record();
   const note='Revisão de escopo em 24/09/2026: '+reason(key)+' Roteiro preservado para histórico; não executar como cobertura da história atual.';
   await call('zephyr_update_test',{key,status:'Deprecated',objective:(live.objective||'')+'\n'+note});
   const after=await read('zephyr_get_test',{key});assert.equal(after.status,'Deprecated');assert.equal(after.testScript.text,live.testScript.text);assert.deepEqual(after.issueLinks,live.issueLinks);assert.equal(after.lastTestResultStatus??null,live.lastTestResultStatus??null);
   state.deprecated.push(key);record();console.log(JSON.stringify({deprecated:key}));
   await new Promise(r=>setTimeout(r,250));
 }
 for(const change of refinements){
   if(state.refined.includes(change.key))continue;
   const live=await read('zephyr_get_test',{key:change.key});const original=prior.get(change.key);guard(live,original);
   backup.tests[change.key]=live;record();
   await call('zephyr_update_test',change);
   const after=await read('zephyr_get_test',{key:change.key});assert.equal(after.name,change.name);assert.equal(after.testScript.type,'BDD');assert.equal(after.testScript.text,change.bdd_script);assert.deepEqual(after.issueLinks,live.issueLinks);assert.deepEqual(after.labels,live.labels);assert.equal(after.lastTestResultStatus??null,live.lastTestResultStatus??null);
   state.refined.push(change.key);record();console.log(JSON.stringify({refined:change.key}));
   await new Promise(r=>setTimeout(r,250));
 }
 for(const c of newCases){
   if(state.created.some(x=>x.name===c.name&&x.verified))continue;
   const existing=await read('zephyr_search_tests',{project_key:'ETICS',name:c.name,max_results:100,start_at:0});
   if(existing.length)throw new Error(`Nome já existe: ${c.name} (${existing.map(x=>x.key).join(',')})`);
   const created=await call('zephyr_create_test',{project_key:'ETICS',name:c.name,objective:c.objective,precondition:c.precondition,status:'Draft',labels:commonLabels,issue_links:[c.story],steps:[{description:'Preparar fixture e executar o roteiro BDD aprovado.',expectedResult:'Conferir o comportamento descrito no roteiro BDD.'}]});
   const key=created.key;assert.match(key,/^ETICS-T[0-9]+$/);
   state.created.push({name:c.name,key,story:c.story,verified:false});record();
   await call('zephyr_update_test',{key,bdd_script:c.script});
   const after=await read('zephyr_get_test',{key});assert.equal(after.name,c.name);assert.equal(after.testScript.type,'BDD');assert.equal(after.testScript.text,c.script);assert.ok(after.issueLinks.includes(c.story));assert.equal(after.status,'Draft');
   state.created.find(x=>x.key===key).verified=true;record();console.log(JSON.stringify({created:key,name:c.name}));
   await new Promise(r=>setTimeout(r,250));
 }
 state.completedAt=new Date().toISOString();record();
}catch(e){state.errors.push({at:new Date().toISOString(),message:e.message});record();console.error(e.message);process.exitCode=1;}
finally{child.kill();lines.close();}
