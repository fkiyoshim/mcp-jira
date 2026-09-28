import assert from 'node:assert/strict';
import test from 'node:test';
import { extension } from './write-tools.mjs';

test('conversao BDD atualiza somente roteiro e rejeita formatos conflitantes', async () => {
  const {api,calls}=setup();
  const script='Cenário: Exemplo\n  Dado um contexto\n  Quando executar\n  Então validar';
  await api.call('zephyr_update_test',{key:'ETICS-T1',bdd_script:script});
  assert.equal(calls[0].options,undefined);
  assert.deepEqual(calls.at(-1).options,{method:'PUT',body:{testScript:{type:'BDD',text:script}}});
  const count=calls.length;
  await assert.rejects(api.call('zephyr_update_test',{key:'ETICS-T1',bdd_script:script,steps:[{description:'x',expectedResult:'y'}]}),/nunca ambos/);
  await assert.rejects(api.call('zephyr_update_test',{key:'ETICS-T1',bdd_script:' '}),/invalido/);
  assert.equal(calls.length,count);
});

function setup(writeEnabled = true) {
  const calls=[];
  const projectKey=(v='ETICS')=> { if(v!=='ETICS') throw new Error('Projeto nao permitido'); return v; };
  const issueKey=v=>{ if(!/^ETICS-[1-9][0-9]*$/.test(v)) throw new Error('Issue nao permitida'); return v; };
  const api=extension({writeEnabled, projectKey, issueKey, request:async(path,query,options)=> {
    calls.push({path,query,options});
    if(path.includes('/issue/ETICS-')) return {key:'ETICS-1',fields:{project:{key:'ETICS'}}};
    return {key:path.includes('/testrun')?'ETICS-R1':'ETICS-T1'};
  }});
  return {api,calls};
}
test('modo leitura oculta e bloqueia escritas',async()=>{
  const {api,calls}=setup(false);
  assert.ok(api.tools.every(t=>t.annotations.readOnlyHint));
  await assert.rejects(api.call('zephyr_create_test',{name:'x',steps:[]}),/desabilitada/);
  assert.equal(calls.length,0);
});
test('cria teste com passos e rastreabilidade sem resultados de execucao',async()=>{
  const {api,calls}=setup();
  await api.call('zephyr_create_test',{name:'Cenario',steps:[{description:'Acao',testData:'Dado',expectedResult:'Resultado'}],issue_links:['ETICS-1']});
  assert.equal(calls[0].path,'/rest/api/2/issue/ETICS-1');
  const created=calls.at(-1);
  assert.equal(created.path,'/rest/atm/1.0/testcase');
  assert.equal(created.options.method,'POST');
  assert.deepEqual(created.options.body.issueLinks,['ETICS-1']);
  assert.equal(created.options.body.testScript.steps[0].expectedResult,'Resultado');
  assert.equal(created.options.body.projectKey,'ETICS');
  assert.equal(created.options.body.status,undefined);
});
test('bloqueia projetos, chaves e campos fora do contrato antes de escrever',async()=>{
  const {api,calls}=setup();
  const step={description:'Acao',expectedResult:'Resultado'};
  await assert.rejects(api.call('zephyr_create_test',{project_key:'OUTRO',name:'x',steps:[step]}),/permitido/);
  await assert.rejects(api.call('zephyr_create_test',{name:'x',steps:[step],issue_links:['OUTRO-1']}),/permitida/);
  await assert.rejects(api.call('zephyr_update_test',{key:'OUTRO-T1',name:'x'}),/permitido/);
  await assert.rejects(api.call('jira_update_issue',{issue_key:'ETICS-1',project:{key:'OUTRO'}}),/nao permitido/);
  await assert.rejects(api.call('jira_create_issue',{summary:'x',issue_type_id:'33',custom_fields:{project:{key:'OUTRO'}}}),/customfield/);
  await assert.rejects(api.call('zephyr_create_test',{name:'x',steps:[{...step,testCaseKey:'OUTRO-T1'}]}),/nao permitido/);
  assert.ok(calls.every(c=>!c.options));
});
test('cria ciclo com testes nao executados e valida todas as referencias',async()=>{
  const {api,calls}=setup();
  await api.call('zephyr_create_cycle',{name:'Ciclo',test_keys:['ETICS-T1','ETICS-T2'],issue_links:['ETICS-1']});
  const body=calls.at(-1).options.body;
  assert.deepEqual(body.items,[{testCaseKey:'ETICS-T1',status:'Not Executed'},{testCaseKey:'ETICS-T2',status:'Not Executed'}]);
  assert.equal(calls.filter(c=>c.options).length,1);
  assert.equal(calls.length,4);
});
test('nao aceita ciclo com testes externos, duplicados ou datas invertidas',async()=>{
  const {api,calls}=setup();
  await assert.rejects(api.call('zephyr_create_cycle',{name:'x',test_keys:['OUTRO-T1']}),/permitido/);
  await assert.rejects(api.call('zephyr_create_cycle',{name:'x',test_keys:['ETICS-T1','ETICS-T1']}),/duplicados/);
  await assert.rejects(api.call('zephyr_create_cycle',{name:'x',test_keys:[],planned_start_date:'2026-10-10',planned_end_date:'2026-10-01'}),/Fim anterior/);
  assert.ok(calls.every(c=>!c.options));
});
test('criacao e edicao Jira usam POST/PUT e nao permitem mover projeto',async()=>{
  const {api,calls}=setup();
  await api.call('jira_create_issue',{summary:'Historia',issue_type_id:'33',custom_fields:{customfield_10001:'valor'}});
  assert.deepEqual(calls[0].options.body.fields.project,{key:'ETICS'});
  assert.equal(calls[0].options.method,'POST');
  await api.call('jira_update_issue',{issue_key:'ETICS-1',description:'Texto'});
  assert.equal(calls.at(-1).options.method,'PUT');
  assert.deepEqual(calls.at(-1).options.body,{fields:{description:'Texto'}});
});
test('validacao rejeita argumentos e passos invalidos',async()=>{
  const {api,calls}=setup();
  for(const args of [{name:'x',steps:[]},{name:'x',steps:[{description:'x'}]},{name:'',steps:[{description:'x',expectedResult:'y'}]}]) await assert.rejects(api.call('zephyr_create_test',args));
  assert.equal(calls.length,0);
});
test('busca Zephyr fixa projeto e rejeita injecao de query',async()=>{
  const {api,calls}=setup();
  await api.call('zephyr_search_tests',{name:'Cenario'});
  assert.equal(calls[0].query.query,'projectKey = "ETICS" AND name = "Cenario"');
  await assert.rejects(api.call('zephyr_search_tests',{name:'x" OR projectKey = "OUTRO'}));
  await assert.rejects(api.call('zephyr_search_tests',{max_results:0}));
  assert.equal(calls.length,1);
});
test('erro remoto nao dispara repeticao automatica',async()=>{
  let writes=0;
  const api=extension({writeEnabled:true,projectKey:()=> 'ETICS',issueKey:v=>v,request:async()=>{writes++;throw new Error('HTTP 403');}});
  await assert.rejects(api.call('zephyr_create_test',{name:'x',steps:[{description:'x',expectedResult:'y'}]}),/403/);
  assert.equal(writes,1);
});
test('edicao de passos declara risco de substituicao',()=>{
  const {api}=setup();
  const update=api.tools.find(t=>t.name==='zephyr_update_test');
  assert.equal(update.annotations.readOnlyHint,false);
  assert.equal(update.annotations.destructiveHint,true);
});
