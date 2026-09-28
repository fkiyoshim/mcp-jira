// Public Jira Data Center v2 and Zephyr Scale Server v1 APIs.
export function extension({ request, projectKey, issueKey, writeEnabled }) {
  const string = { type: 'string' };
  const project = { project_key: string };
  const strings = { type: 'array', items: string, maxItems: 100 };
  const step = { type: 'object', properties: { description: string, testData: string, expectedResult: string }, required: ['description', 'expectedResult'], additionalProperties: false };
  const testFields = { name: string, objective: string, precondition: string, folder: string, status: string, priority: string, labels: strings, issue_links: strings, steps: { type: 'array', items: step, minItems: 1, maxItems: 500 } };
  const definitions = [];
  const handlers = new Map();
  function tool(name, description, properties, required, run, write = false, destructive = false) {
    if (write && !writeEnabled) return;
    definitions.push({ name, description, inputSchema: { type: 'object', properties, required, additionalProperties: false }, annotations: { readOnlyHint: !write, destructiveHint: destructive, idempotentHint: !write, openWorldHint: true } });
    handlers.set(name, { run, write });
  }
  function text(v, label, max = 32767) {
    if (typeof v !== 'string' || !v.trim() || v.length > max) throw new Error(`${label} invalido.`);
    return v;
  }
  function key(v, kind) {
    const match = /^([A-Z][A-Z0-9_]*)-([TR])([1-9][0-9]*)$/.exec(String(v || '').toUpperCase());
    if (!match || match[2] !== kind) throw new Error('Chave Zephyr invalida.');
    projectKey(match[1]);
    return match[0];
  }
  function list(v, label, max = 100) {
    if (!Array.isArray(v) || v.length > max) throw new Error(`${label} deve ser uma lista de ate ${max} itens.`);
    return v;
  }
  function page(v, fallback, max) {
    if (v === undefined) return fallback;
    if (!Number.isInteger(v) || v < (fallback === 0 ? 0 : 1) || v > max) throw new Error('Paginacao invalida.');
    return v;
  }
  async function verifyIssue(v) {
    const requested = issueKey(v);
    const found = await request(`/rest/api/2/issue/${requested}`, { fields: 'project,issuetype' });
    // Jira may resolve a moved issue through its previous key.
    if (!found?.fields?.project?.key) throw new Error('Nao foi possivel confirmar projeto da issue.');
    projectKey(found.fields.project.key);
    return found;
  }
  async function links(values) {
    const validated = list(values, 'issue_links').map(issueKey);
    for (const value of validated) await verifyIssue(value);
    return validated;
  }
  function schemaValidate(value, schema, path = 'arguments') {
    if (schema.type === 'object') {
      if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error(`${path} invalido.`);
      for (const field of schema.required || []) if (!(field in value)) throw new Error(`${path}.${field} obrigatorio.`);
      for (const [field, val] of Object.entries(value)) {
        if (!schema.properties?.[field]) { if (schema.additionalProperties === false) throw new Error(`${path}.${field} nao permitido.`); }
        else schemaValidate(val, schema.properties[field], `${path}.${field}`);
      }
    } else if (schema.type === 'array') {
      list(value, path, schema.maxItems || 1000);
      if (schema.minItems && value.length < schema.minItems) throw new Error(`${path} vazio.`);
      value.forEach((v,i)=>schemaValidate(v,schema.items,`${path}[${i}]`));
    } else if (schema.type === 'string' && typeof value !== 'string') throw new Error(`${path} deve ser texto.`);
    else if (schema.type === 'integer' && !Number.isInteger(value)) throw new Error(`${path} deve ser inteiro.`);
  }
  async function testBody(a) {
    const body = {};
    if (a.bdd_script !== undefined && a.steps !== undefined) throw new Error('Use bdd_script ou steps, nunca ambos.');
    if (a.bdd_script !== undefined) body.testScript = { type: 'BDD', text: text(a.bdd_script, 'bdd_script') };
    for (const field of ['name','objective','precondition','folder','status','priority','labels']) if (a[field] !== undefined) body[field] = a[field];
    if (a.name !== undefined) text(a.name, 'name', 255);
    if (a.issue_links !== undefined) body.issueLinks = await links(a.issue_links);
    if (a.steps !== undefined) body.testScript = { type: 'STEP_BY_STEP', steps: a.steps.map(s=>({ description:text(s.description,'description'), testData:s.testData || '', expectedResult:text(s.expectedResult,'expectedResult') })) };
    return body;
  }
  const paging = { max_results: { type:'integer', minimum:1, maximum:100 }, start_at:{type:'integer',minimum:0} };
  tool('jira_get_permissions','Consulta permissoes do token no projeto.',project,[], a=>request('/rest/api/2/mypermissions',{projectKey:projectKey(a.project_key)}));
  tool('jira_get_create_metadata','Consulta tipos e campos aceitos na criacao de issues.',project,[],a=>request('/rest/api/2/issue/createmeta',{projectKeys:projectKey(a.project_key),expand:'projects.issuetypes.fields'}));
  tool('jira_get_link_types','Lista tipos e direcoes de vinculos Jira.',{},[],()=>request('/rest/api/2/issueLinkType'));
  const issueFields = { summary:string, description:string, labels:strings, priority:{type:'object',properties:{id:string},required:['id'],additionalProperties:false}, custom_fields:{type:'object',additionalProperties:true} };
  function issueBody(a) {
    const f={};
    for(const field of ['summary','description','labels','priority']) if(a[field]!==undefined) f[field]=a[field];
    if(a.summary!==undefined) text(a.summary,'summary',255);
    for(const [field,value] of Object.entries(a.custom_fields || {})) {
      if(!/^customfield_[1-9][0-9]*$/.test(field)) throw new Error('Somente customfield_ID permitido em custom_fields.');
      f[field]=value;
    }
    return f;
  }
  tool('jira_create_issue','Cria issue em projeto autorizado; consultar metadados antes de preencher campos.',{...project,...issueFields,issue_type_id:string},['summary','issue_type_id'],async a=> {
    const f=issueBody(a); f.project={key:projectKey(a.project_key)}; f.issuetype={id:text(a.issue_type_id,'issue_type_id',32)};
    return request('/rest/api/2/issue',{}, {method:'POST',body:{fields:f}});
  },true);
  tool('jira_update_issue','Edita campos de uma issue autorizada. Nao move nem exclui issues.',{issue_key:string,...issueFields},['issue_key'],async a=> {
    const f=issueBody(a); if(!Object.keys(f).length) throw new Error('Nenhum campo para atualizar.');
    const found=await verifyIssue(a.issue_key);
    return request(`/rest/api/2/issue/${issueKey(found.key)}`,{}, {method:'PUT',body:{fields:f}});
  },true,true);
  tool('jira_link_issues','Cria vinculo entre duas issues autorizadas. Use o nome do tipo e a direcao consultados.',{inward_issue_key:string,outward_issue_key:string,link_type:string},['inward_issue_key','outward_issue_key','link_type'],async a=> {
    const inward=await verifyIssue(a.inward_issue_key), outward=await verifyIssue(a.outward_issue_key);
    return request('/rest/api/2/issueLink',{}, {method:'POST',body:{type:{name:text(a.link_type,'link_type',255)},inwardIssue:{key:issueKey(inward.key)},outwardIssue:{key:issueKey(outward.key)}}});
  },true);
  for (const [kind,resource,prefix] of [['test','testcase','T'],['cycle','testrun','R']]) {
    tool(`zephyr_get_${kind}`,`Consulta ${kind==='test'?'teste e passos':'ciclo e testes'} no Zephyr Scale.`,{key:string},['key'],a=>request(`/rest/atm/1.0/${resource}/${key(a.key,prefix)}`));
    tool(`zephyr_search_${kind}s`,'Pesquisa por projeto e, opcionalmente, nome exato no Zephyr Scale.',{...project,name:string,...paging},[],a=> {
      let query=`projectKey = "${projectKey(a.project_key)}"`;
      if(a.name!==undefined) {
        text(a.name,'name',255);
        if(/["\\\r\n]/.test(a.name)) throw new Error('Nome com aspas/barra invertida nao suportado no filtro.');
        query+=` AND name = "${a.name}"`;
      }
      return request(`/rest/atm/1.0/${resource}/search`,{query,maxResults:page(a.max_results,25,100),startAt:page(a.start_at,0,100000)});
    });
  }
  tool('zephyr_create_test','Cria teste Zephyr Scale com passos e vinculos as historias. Nao registra execucao.',{...project,...testFields},['name','steps'],async a=>request('/rest/atm/1.0/testcase',{}, {method:'POST',body:{...await testBody(a),projectKey:projectKey(a.project_key)}}),true);
  tool('zephyr_update_test','Atualiza teste Zephyr Scale. steps ou bdd_script substituem o roteiro; issue_links substitui os vinculos. Consultar antes.',{key:string,...testFields,bdd_script:string},['key'],async a=> {
    const k=key(a.key,'T'); const body=await testBody(a);
    if(!Object.keys(body).length) throw new Error('Nenhum campo para atualizar.');
    await request(`/rest/atm/1.0/testcase/${k}`);
    return request(`/rest/atm/1.0/testcase/${k}`,{}, {method:'PUT',body});
  },true,true);
  tool('zephyr_create_cycle','Cria ciclo Zephyr Scale com testes existentes, inicialmente nao executados. Datas/versao opcionais.',{...project,name:string,version:string,folder:string,planned_start_date:string,planned_end_date:string,test_keys:strings,issue_links:strings},['name','test_keys'],async a=> {
    const p=projectKey(a.project_key), name=text(a.name,'name',255);
    const keys=list(a.test_keys,'test_keys').map(v=>key(v,'T'));
    if(new Set(keys).size!==keys.length) throw new Error('Testes duplicados no ciclo.');
    for(const k of keys) {
      if(!k.startsWith(p+'-T')) throw new Error('Teste deve pertencer ao projeto do ciclo.');
      await request(`/rest/atm/1.0/testcase/${k}`);
    }
    const body={projectKey:p,name,items:keys.map(testCaseKey=>({testCaseKey,status:'Not Executed'}))};
    for(const f of ['version','folder']) if(a[f]!==undefined) body[f]=a[f];
    for(const [from,to] of [['planned_start_date','plannedStartDate'],['planned_end_date','plannedEndDate']]) if(a[from]!==undefined) {
      if(!/^\d{4}-\d{2}-\d{2}(T.*)?$/.test(a[from]) || !Number.isFinite(Date.parse(a[from]))) throw new Error('Data ISO invalida.');
      body[to]=a[from];
    }
    if(body.plannedStartDate && body.plannedEndDate && Date.parse(body.plannedStartDate)>Date.parse(body.plannedEndDate)) throw new Error('Fim anterior ao inicio.');
    if(a.issue_links!==undefined) body.issueLinks=await links(a.issue_links);
    return request('/rest/atm/1.0/testrun',{}, {method:'POST',body});
  },true);
  return { tools:definitions, async call(name,a) {
    const handler=handlers.get(name); if(!handler) throw new Error(`Ferramenta desconhecida ou escrita desabilitada: ${name}.`);
    schemaValidate(a,definitions.find(t=>t.name===name).inputSchema);
    if(handler.write && !writeEnabled) throw new Error('Escrita desabilitada.');
    return handler.run(a);
  }};
}
