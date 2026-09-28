const fs=require('fs');
const base=__dirname, story='ETICS-251765';
const cases=[];
const common='Ambiente CLARO com HU-38 instalada; usuário associado ao perfil autorizado pela CLARO; Lance de Cabo Óptico e valores válidos disponíveis. Registrar IDs reais, valores anteriores e evidências. Executar em dados de teste controlados.';
function add(title,source,steps,criterion,extra='') {const id='CT'+String(cases.length+1).padStart(2,'0');cases.push({id,name:`${story} | HU-38 | ${id} | ${title}`,source,precondition:common+(extra?' '+extra:''),objective:`Validar ${title.toLowerCase()}. Fonte: GP-Visao-CLARO-FlexibilizacaoProjeto, versão 01.01, ${source}; história ${story}.`,bdd_script:steps.join('\n'),criterion});}
add('Editar todos os atributos não bloqueados em lance Existente','§4 (escopo adicional), §7.2 e histórico da versão 01.01',[
'Given um Lance de Cabo Óptico na situação Existente e nenhuma OT corrente',
'And a matriz de atributos do lance foi conferida contra o modelo e a configuração da versão, identificando todos os atributos não bloqueados e seus valores válidos',
'When abrir Corrigir inventário',
'Then todos os atributos classificados como não bloqueados na matriz permitem edição, inclusive os adicionais à lista original da seção 7.2',
'When alterar cada atributo não bloqueado com um valor válido, salvar e consultar novamente o lance após cada alteração',
'Then cada valor informado permanece gravado no respectivo atributo',
'And os atributos não alterados preservam seus valores e a situação permanece Existente',
'And a correção não cria vínculo do lance com uma OT'],
'AMPLIAÇÃO / EXISTENTE — Todos os atributos não bloqueados permitem edição e persistem sem OT.',
'Preparar matriz completa: atributo, bloqueio esperado independente da tela sob teste, valor anterior, valor válido e resultado. A documentação não enumera a lista completa ampliada; a matriz é obrigatória para declarar cobertura de todos os campos.');
add('Editar atributos adicionais em lance Projetado/Modificação','§4, §6.2 e §7.2',[
'Given um Lance de Cabo Óptico na situação Projetado/Modificação vinculado à OT A',
'And não há OT definida como corrente',
'And a matriz de atributos identifica os campos não bloqueados adicionais à lista original da seção 7.2',
'When alterar cada campo adicional por Corrigir inventário com um valor válido e salvar',
'Then cada alteração persiste ao consultar novamente o lance',
'And a situação continua Projetado/Modificação e o vínculo original com a OT A é preservado',
'And a correção é registrada sem associação a uma OT'],
'AMPLIAÇÃO / PROJETADO — Campos adicionais persistem em Projetado/Modificação sem mudar situação ou vínculo original.',
'Identificar os campos adicionais pela matriz validada, sem assumir que a lista original de oito campos limita a HU-38.');
add('Manter atributos bloqueados protegidos','HU-38, §4 e §7.2',[
'Given um Lance de Cabo Óptico com valores registrados nos atributos classificados como bloqueados pelo modelo e pela configuração',
'When abrir Corrigir inventário e verificar cada atributo bloqueado',
'Then a operação não permite editar esses atributos',
'When alterar um atributo não bloqueado com valor válido e salvar',
'Then todos os atributos bloqueados mantêm os valores anteriores'],
'BLOQUEIOS — Atributos bloqueados permanecem protegidos e inalterados.',
'Preparar lista de bloqueios esperados a partir do modelo/configuração, não inferida apenas do comportamento observado da tela.');
for(const field of ['Rota','Comprimento Real Total (m)','Propriedade','Proprietário','Tipo de Rede','Observações','Configuração de Cor','Tipo']) {
 const specific=field==='Comprimento Real Total (m)'?'o Comprimento Real Total (m) é 10,00 e o novo valor válido é 20,00':field==='Tipo'?'há um tipo alternativo válido com a mesma quantidade de fibras do tipo atual':`há um valor válido para ${field} diferente do valor atual, respeitando os cadastros e dependências existentes`;
 add(`Preservar edição de ${field}`,'§7.2'+(field==='Tipo'?' e §6.2.3':''),[
 'Given um Lance de Cabo Óptico Existente e nenhuma OT corrente',`And ${specific}`,
 `When alterar ${field} por Corrigir inventário para o novo valor válido e salvar`,
 `Then ${field} apresenta o novo valor ao consultar novamente o lance`,
 'And a situação permanece Existente e os demais atributos não envolvidos na regra da alteração preservam seus valores'],
 `REGRESSÃO / ${field.toUpperCase()} — Edição válida permanece disponível e persiste sem OT.`);
}
add('Ignorar OT corrente na correção','§7.2',[
'Given um lance Projetado/Modificação vinculado à OT A',
'And um atributo não bloqueado possui valor válido para correção',
'When definir a própria OT A como corrente, corrigir o atributo e salvar',
'Then a correção persiste sem associação à OT corrente e mantém a situação e o vínculo original do lance',
'When repetir em dados independentes com uma OT B diferente da OT A definida como corrente',
'Then a correção também persiste sem associação à OT B e mantém a situação e o vínculo original do lance'],
'OT CORRENTE — A correção ignora tanto a OT do lance quanto outra OT corrente.');
add('Manter validações de consistência dos campos','§7.2',[
'Given a matriz de atributos não bloqueados contém as regras de consistência vigentes e exemplos de valores inválidos',
'And os valores persistidos do lance foram registrados antes da tentativa',
'When tentar salvar por Corrigir inventário um valor que viola uma regra vigente, repetindo para cada regra aplicável',
'Then o sistema apresenta a validação correspondente e impede persistir o valor inválido',
'And o atributo permanece com seu valor anterior ao consultar novamente o lance',
'When informar um valor válido para o mesmo atributo e salvar',
'Then o valor válido persiste'],
'CONSISTÊNCIA — Validações vigentes rejeitam valores inválidos e aceitam valores válidos.',
'Levantar obrigatoriedade, formato, domínio e dependências que efetivamente se aplicam a cada campo. O documento determina preservação das regras, mas não lista limites nem textos de mensagens.');
for(const [kind,count,result] of [
 ['igual',12,['Then o tipo é alterado para o novo tipo de 12 fibras','And as 12 fibras existentes preservam seus identificadores, contagens e conexões']],
 ['maior',24,['Then o tipo é alterado para o novo tipo de 24 fibras','And as fibras de 1 a 12 preservam seus identificadores, contagens e conexões','And somente as fibras faltantes de 13 a 24 são criadas automaticamente','And as novas fibras ficam disponíveis para criação manual de contagem e conexão, sem herdar automaticamente as contagens e conexões existentes']],
 ['menor',6,['Then o sistema apresenta uma mensagem de erro e impede a alteração','And o tipo original de 12 fibras permanece','And nenhuma fibra, contagem ou conexão existente é removida ou alterada']]
])add(`Alterar tipo conectado com capacidade ${kind}`,'§6.2.3 e regras detalhadas do §7.2',[
'Given um lance conectado de tipo com 12 fibras, com identificadores, contagens e conexões registrados',
`And existe um tipo alternativo válido com ${count} fibras`,
`When solicitar por Corrigir inventário a mudança para o tipo de ${count} fibras e salvar`,...result,
'When consultar novamente o lance e suas fibras',
'Then o estado persistido corresponde ao resultado verificado'],
`TIPO / CAPACIDADE ${kind.toUpperCase()} — ${kind==='igual'?'Aceita troca e preserva fibras, contagens e conexões.':kind==='maior'?'Cria apenas fibras faltantes e preserva a rede existente.':'Rejeita redução e mantém a rede original.'}`);
add('Registrar histórico da correção','§6.2.1, §6.2.2 e §7.2',[
'Given um lance com um atributo não bloqueado de valor anterior conhecido e usuário autorizado identificado',
'When corrigir o atributo para um novo valor válido e salvar',
'Then o histórico registra Corrigir inventário, atributo, valor anterior e novo valor',
'And registra o usuário responsável e a data e hora compatíveis com a operação',
'And o registro da correção não fica associado a uma OT',
'When consultar novamente o histórico do lance',
'Then o registro permanece disponível com os mesmos dados'],
'HISTÓRICO — Correção rastreável por atributo, antes/depois, usuário e data/hora, sem OT.');
for(const action of ['Implantar OT','Cancelar OT','Desfazer alterações de OT']){
 const implant=action==='Implantar OT';
 add(`Preservar correção em atributo distinto ao ${action.toLowerCase()}`,'§6.2.1 e §7.2',[
'Given um lance com Lote de Fabricação 123 e Rota XYZ',
'And Modificar atributos com a OT A alterou Lote de Fabricação para 456',
'When executar Corrigir inventário sem OT e alterar Rota para ABC',
`And executar ${action} para a OT A`,
'Then a Rota permanece ABC',
`And Lote de Fabricação fica ${implant?'456':'123'}`,
`And o histórico preserva as alterações e registra ${action} com usuário e data/hora`,
'When repetir com dados independentes executando a correção de Rota antes da alteração com OT',
'Then os valores finais são os mesmos para a respectiva operação de OT'],
`ATRIBUTOS DISTINTOS / ${action.toUpperCase()} — Rota corrigida permanece ABC; lote fica ${implant?'456':'123'}.`,
'Usar valores válidos equivalentes se o ambiente não permitir as amostras 123/456 e XYZ/ABC; registrar a equivalência antes de executar.');
}
for(const action of ['Implantar OT','Cancelar OT','Desfazer alterações de OT'])add(`Preservar última correção no mesmo atributo ao ${action.toLowerCase()}`,'§6.2.2 e §7.2',[
'Given um lance com Comprimento Real Total (m) igual a 10,00',
'And Modificar atributos com a OT A alterou o comprimento para 15,00',
'When executar Corrigir inventário sem OT e alterar o comprimento de 15,00 para 20,00',
`And executar ${action} para a OT A`,
'Then o Comprimento Real Total (m) permanece 20,00',
'And o histórico de Corrigir inventário mantém a alteração de 15,00 para 20,00 sem reescrever o valor anterior',
`And o histórico registra ${action} com usuário responsável e data/hora`],
`MESMO ATRIBUTO / ${action.toUpperCase()} — Correção para 20,00 permanece e o histórico mantém 15,00 → 20,00.`);
add('Corrigir atributo após implantação da OT','§6.2.2',[
'Given um lance com Comprimento Real Total (m) igual a 10,00',
'And Modificar atributos com a OT A alterou o comprimento para 15,00',
'When implantar a OT A e depois executar Corrigir inventário sem OT alterando o comprimento para 20,00',
'Then o comprimento persistido é 20,00 e o lance permanece Existente',
'And o histórico apresenta Modificar atributos 10,00 para 15,00, Implantar OT e Corrigir inventário 15,00 para 20,00 nessa ordem'],
'ORDEM / CORREÇÃO APÓS IMPLANTAÇÃO — Valor final 20,00 e sequência histórica preservada.');
add('Respeitar alteração por OT posterior à correção','§6.2.2',[
'Given um lance Existente com Comprimento Real Total (m) igual a 10,00',
'When executar Corrigir inventário sem OT alterando o comprimento para 20,00',
'And executar Modificar atributos com a OT A alterando o comprimento de 20,00 para 15,00',
'And implantar a OT A',
'Then o comprimento persistido é 15,00',
'And o histórico apresenta Corrigir inventário 10,00 para 20,00, Modificar atributos 20,00 para 15,00 e Implantar OT nessa ordem'],
'ORDEM / OT POSTERIOR À CORREÇÃO — Alteração posterior implantada prevalece com valor final 15,00.');
add('Disponibilizar operação ao perfil autorizado','§4 (escopo adicional) e §7.2',[
'Given um usuário associado ao perfil específico informado pela CLARO para Corrigir inventário',
'And existe um lance elegível e um atributo não bloqueado com valor válido para alteração',
'When acessar o lance com esse usuário e executar Corrigir inventário',
'Then a operação está disponível e permite salvar a alteração válida',
'And o valor persiste e o histórico identifica o usuário responsável'],
'PERFIL AUTORIZADO — Usuário do perfil CLARO consegue corrigir atributos elegíveis.',
'Confirmar o nome/ID do perfil com a configuração aprovada pela CLARO; a documentação não o informa.');
add('Impedir operação para usuário sem perfil autorizado','§4 (escopo adicional) e §7.2',[
'Given um usuário que pode consultar o lance mas não pertence ao perfil autorizado para Corrigir inventário',
'And os valores atuais do lance foram registrados',
'When acessar as operações do lance com esse usuário',
'Then Corrigir inventário não está disponível para execução',
'And o usuário não consegue gravar uma correção por essa operação',
'And os valores persistidos do lance permanecem inalterados'],
'PERFIL NÃO AUTORIZADO — Usuário fora do perfil não executa nem grava correção.',
'Usar usuário sem permissões administrativas que concedam o perfil implicitamente.');
const data={story,document:'GP-Visao-CLARO-FlexibilizacaoProjeto (1).doc',documentVersion:'01.01',cycleName:'CLARO | HU-38 | Corrigir inventário do Lance de Cabo Óptico | ETICS-251765',folder:null,notes:['A matriz completa de atributos editáveis/bloqueados e regras vigentes deve ser preparada na execução; o documento não enumera todos os campos ampliados.','Nome/ID do perfil autorizado depende de definição/configuração CLARO.','Para capacidade igual, seguem-se as regras detalhadas de §6.2.3 e §7.2 que permitem a troca, apesar da frase resumida do §7.2 mencionar somente aumento.','Escopo limitado ao Lance de Cabo Óptico e às regressões de Corrigir inventário; não inclui TFO, Sobra, reposicionamento ou outras operações de fibras.'],cases};
fs.writeFileSync(base+'/cenarios.json',JSON.stringify(data,null,2));
fs.writeFileSync(base+'/cenarios.feature','# language: pt\nFuncionalidade: HU-38 - Corrigir inventário do Lance de Cabo Óptico\n\n'+cases.map(c=>`  # ${c.id}; ${c.source}\n  Cenário: ${c.name}\n`+c.bdd_script.split('\n').map(l=>'    '+l.replace(/^(Given|When|Then|And) /,(_,k)=>({Given:'Dado',When:'Quando',Then:'Então',And:'E'}[k]+' '))).join('\n')).join('\n\n')+'\n');
console.log(JSON.stringify({count:cases.length,names:cases.map(c=>c.name)}));
