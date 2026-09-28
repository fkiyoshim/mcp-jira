# Cenários RECON — cadastrados no Zephyr

**Complemento H01 em 10/09/2026:** revisão do documento técnico anexado, ampliação de T8038 e oito novos casos, separados em ciclos sistêmico ETICS-C647 e desenvolvimento ETICS-C648. A situação atual e os roteiros complementares estão em [h01-revisao-separacao-equipes.md](h01-revisao-separacao-equipes.md). O ciclo geral ETICS-C646 mantém os 50 membros originais; os trechos abaixo registram o pacote inicial.

Ciclo ETICS-C646: **CLARO | RECON lógico | H01–H08 | Visão 01.01**.

**Situação: ciclo ETICS-C646 e 50 testes cadastrados e verificados via MCP; testes NÃO executados.** Casos ETICS-T8036 a ETICS-T8085 vinculados às oito histórias do épico [ETICS-245531](https://jira.cpqd.com.br/browse/ETICS-245531) e ao ciclo. Evidências em zephyr-verification.json. Prioridade no Zephyr: Normal, seguindo o primeiro cadastro; Alta permanece como proposta neste documento.

## Escopo e fontes

- Histórias H01–H08 e comentários consultados no Jira em 09/09/2026.
- Documento de visão versão 01.01 fornecido pelo usuário, analisado por extração textual das seções e tabelas; figuras e cores não foram verificadas visualmente.
- O quadro 4984 e o filtro rápido 17398 não puderam ser abertos: nenhum navegador conectado. A busca pelo épico incluiu histórias abertas, mas não comprova a composição exata do backlog do quadro.
- O épico ETICS-245538 contém histórias do painel/eventos e notificações. A inclusão desse escopo aguarda resposta do usuário; não foi atribuída automaticamente a H01–H08.
- Os projetos técnicos no Bitbucket referenciados pelas histórias não foram acessados. Fixtures XML completas, nomes canônicos e detalhes não presentes nas histórias precisam desse contrato antes da execução.

## Rastreabilidade

| História | Estado no Jira | Casos |
|---|---|---:|
| [ETICS-252410](https://jira.cpqd.com.br/browse/ETICS-252410) — [CLARO-Recon] H01 - Sincronizacao silenciosa de atributos IM para GP | Para Teste | 6 |
| [ETICS-252562](https://jira.cpqd.com.br/browse/ETICS-252562) — [CLARO-Recon] H02 - Ajuste da tela de configuracao de reconciliacao para lista | Em Implementação | 5 |
| [ETICS-252569](https://jira.cpqd.com.br/browse/ETICS-252569) — [CLARO-Recon] H03 - Artefato compartilhado para upsert de objetos em documento JSON | Em Implementação | 10 |
| [ETICS-252611](https://jira.cpqd.com.br/browse/ETICS-252611) — [CLARO-Recon] H04 - Preparar o Recon para sincronização de campos JSON do IM para o GP | Em Implementação | 10 |
| [ETICS-252614](https://jira.cpqd.com.br/browse/ETICS-252614) — [CLARO-Recon] H05 - Sincronizar o grupo Zona do IM no documento JSON do Roteador | Aberta | 5 |
| [ETICS-252615](https://jira.cpqd.com.br/browse/ETICS-252615) — [CLARO-Recon] H06 - Sincronizar atributos HA do IM no objeto JSON Device do Roteador | Aberta | 5 |
| [ETICS-252629](https://jira.cpqd.com.br/browse/ETICS-252629) — [CLARO-Recon] H07 - Sincronizar grupo de Roteamento Estático do IM no JSON do Roteador | Aberta | 4 |
| [ETICS-252632](https://jira.cpqd.com.br/browse/ETICS-252632) — [CLARO-Recon] H08 - Sincronizar Roteamento Dinâmico do IM no JSON do Roteador | Aberta | 5 |

## Pendências que afetam a execução

1. H08 solicita BGP, OSPF e RIP; visão §6.28 marca diversos atributos como Discovery=NÃO e §7 inclui roteamento dinâmico na descoberta. Confirmar o mapeamento vigente, incluindo RIP.
2. A chave composta de rota estática da visão §6.30 é destination-address-mask + priority. Confirmar equivalência no contrato JSON de H07.
3. Confirmar chave de zona, objectTypes, formatos canônicos, allowlist e exemplos XML nos contratos de H03–H08. S/T e id nos casos de componente são fixtures sintéticas de tipos registrados, não nomes de produção.
4. Não há regra publicada suficiente para entradas repetidas da mesma identidade no lote, null/vazio, limites de tamanho, concorrência e tratamento de falha do CDK após merge. Não impor resultado arbitrário para esses pontos.
5. A visão tem escopo maior que as oito histórias: interfaces, DHCP, VRRP, NAT, topologia, agendamento e atualização de recursos lógicos condicionada à consistência física. A cobertura integral desses tópicos depende de identificar as histórias correspondentes no quadro. Este pacote não representa cobertura integral da visão.
6. Definir versão do ciclo, ambiente e datas antes da execução. Nenhuma versão foi inferida do nome de branch.

## Preparação e evidências

Executar em ambiente de teste com fixtures homologadas. Para cada caso registrar build GP/IM, configuração usada, ID da reconciliação, inventário anterior/posterior e evidência do resultado. Casos com NestedRuleCaller exigem observabilidade ou harness; a UI isolada não comprova a contagem de chamadas. Não usar resultado de teste como "Aprovado" antes da execução.

## Casos

### [CLARO-Recon] H01 - Sincronizacao silenciosa de atributos IM para GP — ETICS-252410

#### RECON-H01-01 — Ignorar atributo configurado com 0

**História:** [ETICS-252410](https://jira.cpqd.com.br/browse/ETICS-252410) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.

**Dados:** Atributo reconciliável A: GP=valor_GP, IM=valor_IM; configuração A=0.

1. Executar a reconciliação e abrir o detalhamento.
   - **Esperado:** A diferença em A não gera divergência.

2. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** A permanece com valor_GP; o atributo ignorado não é sincronizado.

**Base:** H01; comentário de 28/08/2026.

#### RECON-H01-02 — Comparar atributo configurado com 1

**História:** [ETICS-252410](https://jira.cpqd.com.br/browse/ETICS-252410) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.

**Dados:** Atributo A: GP=valor_GP, IM=valor_IM; A=1.

1. Executar a reconciliação e detalhar o equipamento.
   - **Esperado:** A diferença aparece na comparação IM x GP.

2. Consultar o inventário sem acionar atualização.
   - **Esperado:** O GP mantém valor_GP; a comparação não efetiva atualização.

**Base:** H01; comentário de 28/08/2026.

#### RECON-H01-03 — Sincronizar atributo 2 sem divergência nem exibição

**História:** [ETICS-252410](https://jira.cpqd.com.br/browse/ETICS-252410) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.

**Dados:** Atributo A: GP=valor_GP, IM=valor_IM; A=2.

1. Executar a reconciliação e abrir a árvore.
   - **Esperado:** A não gera divergência nem aparece na árvore.

2. Consultar o GP antes de atualizar.
   - **Esperado:** A permanece com valor_GP.

3. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** A passa a valor_IM.

**Base:** H01; comentário de 28/08/2026.

#### RECON-H01-04 — Aplicar os três modos no mesmo equipamento

**Zephyr:** ETICS-T8039 · **História:** ETICS-252410

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. B é um atributo cuja atualização pelo fluxo existente é permitida; os valores recebidos são válidos e nenhuma regra de negócio impede a atualização do roteador.

**Dados:** A=0, B=1, C=2; GP: A=valor_GP_A, B=valor_GP_B, C=valor_GP_C; IM: A=valor_IM_A, B=valor_IM_B, C=valor_IM_C; valores GP e IM diferentes para cada atributo.

1. Executar a reconciliação e abrir o detalhamento do roteador.
   - **Esperado:** Somente B apresenta divergência na comparação IM x GP, com valor_GP_B e valor_IM_B; A e C não geram divergência e C não aparece na árvore.

2. Consultar o inventário antes de acionar Atualizar inventário.
   - **Esperado:** A=valor_GP_A, B=valor_GP_B e C=valor_GP_C; a comparação e a consulta não alteram os valores no GP.

3. Selecionar a divergência de B para resolução com o dado do IM pelo fluxo existente, acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** A permanece com valor_GP_A; B passa a valor_IM_B pela atualização da divergência selecionada; C passa a valor_IM_C silenciosamente, sem exigir seleção de C na árvore.

**Base:** H01/H02; visão 01.01, seções 3 e 9.

#### RECON-H01-05 — Manter atributos silenciosos inalterados durante consultas

**História:** [ETICS-252410](https://jira.cpqd.com.br/browse/ETICS-252410) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.

**Dados:** A=2 e valores diferentes no GP e IM.

1. Executar reconciliação e abrir/fechar o detalhamento duas vezes.
   - **Esperado:** A não aparece nem gera divergência.

2. Executar Consultar inventário e conferir A.
   - **Esperado:** Valor GP original preservado até Atualizar inventário.

**Base:** H01; visão §§3 e 8.

#### RECON-H01-06 — Reexecutar sincronização com o mesmo valor

**História:** [ETICS-252410](https://jira.cpqd.com.br/browse/ETICS-252410) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.

**Dados:** A=2; valor IM já aplicado no GP.

1. Executar novamente a reconciliação com a mesma resposta.
   - **Esperado:** Não há divergência de A nem exibição de A.

2. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** A mantém o valor IM, sem duplicação do objeto atualizado.

**Base:** H01.

**Observação/pendência:** Teste de regressão derivado da semântica de atualização.

### [CLARO-Recon] H02 - Ajuste da tela de configuracao de reconciliacao para lista — ETICS-252562

#### RECON-H02-01 — Apresentar lista com as três opções por atributo

**História:** [ETICS-252562](https://jira.cpqd.com.br/browse/ETICS-252562) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Usuário com acesso à configuração de atributos.

**Dados:** Configuração de teste existente.

1. Abrir Configuração/Atributos reconciliáveis e editar.
   - **Esperado:** Cada atributo configurável é apresentado como lista de seleção.

2. Abrir a lista de cada categoria de atributo disponível.
   - **Esperado:** Opções exatamente 0=Ignorar, 1=Comparar IM x GP, 2=Sincronizar IM -> GP; seleção única.

**Base:** H02 AC1–2.

#### RECON-H02-02 — Persistir os valores numéricos 0, 1 e 2

**História:** [ETICS-252562](https://jira.cpqd.com.br/browse/ETICS-252562) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Usuário autorizado; consulta técnica de RECON_ATRIB_CFG disponível.

**Dados:** Três atributos A, B e C.

1. Selecionar A=0, B=1, C=2 e salvar.
   - **Esperado:** Gravação concluída.

2. Reabrir a configuração e consultar os valores persistidos.
   - **Esperado:** Seleções preservadas; valores numéricos 0, 1 e 2 em RECON_ATRIB_CFG.

**Base:** H02 AC2–3.

#### RECON-H02-03 — Abrir e salvar configuração legada sem migração

**História:** [ETICS-252562](https://jira.cpqd.com.br/browse/ETICS-252562) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Configuração criada antes da alteração, contendo valores 0 e 1.

**Dados:** Cópia de configuração legada, sem conversão prévia de dados.

1. Abrir a configuração legada.
   - **Esperado:** Valores 0 e 1 aparecem nas opções correspondentes.

2. Salvar sem alterar e reabrir.
   - **Esperado:** Valores e comportamento existentes preservados sem migração.

**Base:** H02 AC4.

#### RECON-H02-04 — Alterar sucessivamente o modo de um atributo

**História:** [ETICS-252562](https://jira.cpqd.com.br/browse/ETICS-252562) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Usuário autorizado; configuração de teste.

**Dados:** A inicialmente 0.

1. Alterar A para 1, salvar e reabrir.
   - **Esperado:** A=1 persistido e selecionado.

2. Alterar A para 2, salvar e reabrir.
   - **Esperado:** A=2 persistido e selecionado.

3. Alterar A para 0, salvar e reabrir.
   - **Esperado:** A=0 persistido e selecionado, sem múltiplas opções ativas.

**Base:** H02 AC2–3.

#### RECON-H02-05 — Comparar somente atributos com valor 1

**História:** [ETICS-252562](https://jira.cpqd.com.br/browse/ETICS-252562) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.

**Dados:** Configuração com A=0, B=1, C=2; valores diferentes entre GP e IM.

1. Salvar a configuração pela nova lista e executar reconciliação.
   - **Esperado:** Configuração aceita pelo consumidor atual.

2. Abrir o detalhamento.
   - **Esperado:** Somente B gera divergência por comparação; A e C não são comparados.

**Base:** H02 AC5–6.

**Observação/pendência:** A sincronização funcional de C é coberta pela H01.

### [CLARO-Recon] H03 - Artefato compartilhado para upsert de objetos em documento JSON — ETICS-252569

#### RECON-H03-01 — Inserir singleton inexistente

**História:** [ETICS-252569](https://jira.cpqd.com.br/browse/ETICS-252569) · **Tipo:** Componente · **Prioridade proposta:** Alta

**Pré-condições:** Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.

**Dados:** Tipo S registrado sem chave; documento válido sem S; fragmento S com attributes={valor:'novo'}.

1. Aplicar upsert unitário de S.
   - **Esperado:** Documento final contém uma ocorrência de S com os atributos recebidos.

2. Inspecionar o resultado da operação.
   - **Esperado:** Resultado estruturado informa INSERT para S.

**Base:** H03.

#### RECON-H03-02 — Substituir singleton inteiro sem merge parcial

**História:** [ETICS-252569](https://jira.cpqd.com.br/browse/ETICS-252569) · **Tipo:** Componente · **Prioridade proposta:** Alta

**Pré-condições:** Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.

**Dados:** S existente com attributes={valor:'antigo',obsoleto:true,lista:[1,2]}; entrada S={valor:'novo',lista:[3]}.

1. Aplicar upsert de S.
   - **Esperado:** Uma ocorrência de S permanece.

2. Inspecionar atributos e resultado.
   - **Esperado:** valor=novo, lista=[3], obsoleto ausente; resultado UPDATE.

**Base:** H03.

#### RECON-H03-03 — Inserir e atualizar objetos por chave natural

**História:** [ETICS-252569](https://jira.cpqd.com.br/browse/ETICS-252569) · **Tipo:** Componente · **Prioridade proposta:** Alta

**Pré-condições:** Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.

**Dados:** Tipo T com chave registrada id; documento T/id=A; entradas T/id=A e T/id=B.

1. Aplicar lote com A atualizado e B novo.
   - **Esperado:** A substituído integralmente; B inserido.

2. Inspecionar resultados por item.
   - **Esperado:** UPDATE para A e INSERT para B, com os respectivos objetos finais.

**Base:** H03.

#### RECON-H03-04 — Preservar objetos ausentes do lote

**História:** [ETICS-252569](https://jira.cpqd.com.br/browse/ETICS-252569) · **Tipo:** Componente · **Prioridade proposta:** Alta

**Pré-condições:** Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.

**Dados:** Documento contém T/id=A e T/id=B; lote altera somente A.

1. Aplicar lote com nova versão de A.
   - **Esperado:** Operação concluída.

2. Comparar B com o snapshot.
   - **Esperado:** B preservado integralmente; não há exclusão por ausência na entrada.

**Base:** H03.

#### RECON-H03-05 — Validar o lote inteiro antes de qualquer alteração

**História:** [ETICS-252569](https://jira.cpqd.com.br/browse/ETICS-252569) · **Tipo:** Componente · **Prioridade proposta:** Alta

**Pré-condições:** Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.

**Dados:** Primeiro fragmento válido; segundo fragmento viola formato canônico.

1. Aplicar os dois fragmentos no mesmo lote.
   - **Esperado:** Lote rejeitado com erro tipado.

2. Inspecionar documento e snapshots.
   - **Esperado:** Nenhuma alteração parcial é aplicada; primeiro item não deixa resultado persistido.

**Base:** H03.

#### RECON-H03-06 — Rejeitar documento JSON malformado

**História:** [ETICS-252569](https://jira.cpqd.com.br/browse/ETICS-252569) · **Tipo:** Componente · **Prioridade proposta:** Alta

**Pré-condições:** Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.

**Dados:** Documento atual com sintaxe JSON inválida e fragmento válido.

1. Invocar upsert.
   - **Esperado:** Erro tipado identifica documento inválido.

2. Verificar diagnóstico e ausência de resultado de sucesso.
   - **Esperado:** Nenhum documento final parcialmente atualizado; mensagem útil sem despejar conteúdo sensível.

**Base:** H03.

#### RECON-H03-07 — Rejeitar ausência de chave natural obrigatória

**História:** [ETICS-252569](https://jira.cpqd.com.br/browse/ETICS-252569) · **Tipo:** Componente · **Prioridade proposta:** Alta

**Pré-condições:** Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.

**Dados:** Tipo T tem chave id; fragmento T contém attributes sem id.

1. Aplicar fragmento sem id.
   - **Esperado:** Falha de validação de chave; não deve tratar T como singleton.

2. Comparar documento com snapshot.
   - **Esperado:** Documento inalterado e erro tipado.

**Base:** H03.

#### RECON-H03-08 — Executar componente sem dependências de infraestrutura

**História:** [ETICS-252569](https://jira.cpqd.com.br/browse/ETICS-252569) · **Tipo:** Componente · **Prioridade proposta:** Alta

**Pré-condições:** Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.

**Dados:** Consumidor mínimo com JAR e dependências declaradas; sem GP, IM, CDK ou banco configurados.

1. Resolver o artefato via gerenciamento de dependências do OSS Commons.
   - **Esperado:** Módulo disponível no reator e para o consumidor.

2. Executar INSERT e UPDATE válidos.
   - **Esperado:** Operações funcionam em memória sem exigir serviços externos.

**Base:** H03.

#### RECON-H03-09 — Produzir resultado determinístico em chamadas independentes

**História:** [ETICS-252569](https://jira.cpqd.com.br/browse/ETICS-252569) · **Tipo:** Componente · **Prioridade proposta:** Alta

**Pré-condições:** Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.

**Dados:** Mesmo documento inicial e mesmo lote em duas execuções novas.

1. Executar duas vezes a mesma operação a partir de cópias do documento inicial.
   - **Esperado:** Ambas terminam com sucesso.

2. Comparar documentos finais e resultados por item.
   - **Esperado:** Resultados equivalentes; uma execução não contamina a outra.

**Base:** H03.

#### RECON-H03-10 — Não validar regras de domínio no componente genérico

**História:** [ETICS-252569](https://jira.cpqd.com.br/browse/ETICS-252569) · **Tipo:** Componente · **Prioridade proposta:** Alta

**Pré-condições:** Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.

**Dados:** Tipo registrado; chave válida; atributo interno opaco com texto que não representa um IPv4.

1. Aplicar fragmento estruturalmente válido.
   - **Esperado:** Componente aceita o atributo interno sem validar IPv4.

2. Consultar o resultado.
   - **Esperado:** Valor opaco preservado; validação de domínio permanece no consumidor.

**Base:** H03 exclusões.

### [CLARO-Recon] H04 - Preparar o Recon para sincronização de campos JSON do IM para o GP — ETICS-252611

#### RECON-H04-01 — Coletar fragmentos em CLOB sem alterar GP

**História:** [ETICS-252611](https://jira.cpqd.com.br/browse/ETICS-252611) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Acesso técnico somente de consulta a RECON_EQPT.

**Dados:** GP contém objeto antigo X; IM retorna dois fragmentos novos Y e Z.

1. Executar a reconciliação.
   - **Esperado:** Coleta concluída.

2. Inspecionar CLOB de RECON_EQPT e JSON do GP.
   - **Esperado:** CLOB contém array apenas de Y e Z, cada fragmento com objectType e attributes; não contém cópia de X; GP mantém snapshot inicial.

**Base:** H04 RN2–3,11.

#### RECON-H04-02 — Aplicar lote misto com única atualização

**História:** [ETICS-252611](https://jira.cpqd.com.br/browse/ETICS-252611) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Contador/spy de NestedRuleCaller disponível.

**Dados:** GP contém singleton S e T/id=A; IM atualiza S e A e insere T/id=B.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** S e A substituídos integralmente; B inserido.

2. Inspecionar o contador e o argumento do NestedRuleCaller.
   - **Esperado:** Exatamente uma chamada para o equipamento, contendo JSON final com os três resultados.

**Base:** H04 RN4–8.

#### RECON-H04-03 — Abortar lote quando qualquer fragmento é inválido

**História:** [ETICS-252611](https://jira.cpqd.com.br/browse/ETICS-252611) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Contador/spy de NestedRuleCaller disponível.

**Dados:** Lote com fragmento válido seguido de fragmento inválido.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Atualização rejeitada; nenhum fragmento aplicado.

2. Conferir GP e contador.
   - **Esperado:** Snapshot original preservado; zero chamadas ao NestedRuleCaller.

**Base:** H04 RN7,9.

#### RECON-H04-04 — Abortar atualização com documento GP inválido

**História:** [ETICS-252611](https://jira.cpqd.com.br/browse/ETICS-252611) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Contador/spy disponível; fixture controlada para JSON inválido.

**Dados:** Documento GP malformado e lote IM válido.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Falha diagnosticada sem aplicar fragmentos.

2. Conferir contador e inventário.
   - **Esperado:** Zero chamadas ao NestedRuleCaller; conteúdo anterior não substituído parcialmente.

**Base:** H04 RN9.

#### RECON-H04-05 — Distinguir chaves por maiúsculas e minúsculas

**História:** [ETICS-252611](https://jira.cpqd.com.br/browse/ETICS-252611) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.

**Dados:** Tipo T registrado com chave id; GP tem id=abc; IM retorna id=ABC.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Objeto id=ABC inserido separadamente; id=abc preservado.

2. Inspecionar o documento final.
   - **Esperado:** Não há conversão de caixa nem colisão entre as duas identidades.

**Base:** H04 RN5–6.

#### RECON-H04-06 — Não normalizar objectType

**História:** [ETICS-252611](https://jira.cpqd.com.br/browse/ETICS-252611) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Registro com dois tipos válidos que diferem somente em caixa.

**Dados:** Tipos T e t registrados; GP contém T/id=A; IM retorna t/id=A.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** T/id=A preservado; t/id=A tratado como identidade distinta.

2. Comparar nomes dos tipos no JSON final.
   - **Esperado:** Caixa original mantida.

**Base:** H04 RN6.

**Observação/pendência:** Requer dois tipos válidos registrados; não presumir aceitação de tipo desconhecido.

#### RECON-H04-07 — Preservar configurações ausentes na resposta IM

**História:** [ETICS-252611](https://jira.cpqd.com.br/browse/ETICS-252611) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.

**Dados:** GP contém A e B; IM retorna somente atualização de A.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** A atualizado.

2. Conferir B no GP.
   - **Esperado:** B permanece integralmente, sem exclusão por ausência na resposta.

**Base:** H04 RN10.

#### RECON-H04-08 — Aceitar resposta IM sem objetos HW

**História:** [ETICS-252611](https://jira.cpqd.com.br/browse/ETICS-252611) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.

**Dados:** GP com configurações existentes; resposta IM válida sem fragmentos HW.

1. Executar a reconciliação e consultar resultado.
   - **Esperado:** Ausência de objetos HW não causa erro de parsing.

2. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Configurações existentes preservadas, sem inserção artificial nem exclusão.

**Base:** H04 RN1,10.

**Observação/pendência:** Quantidade de chamadas para lote vazio não definida; não impor esse resultado.

#### RECON-H04-09 — Combinar com inventário atual no momento da atualização

**História:** [ETICS-252611](https://jira.cpqd.com.br/browse/ETICS-252611) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.

**Dados:** Coletar atualização de A; após coleta, inserir objeto B no GP por operação permitida.

1. Concluir coleta e inserir B no GP antes de Atualizar inventário.
   - **Esperado:** GP contém B novo; CLOB contém somente fragmentos coletados.

2. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** A atualizado e B preservado: merge usa documento GP atual, não snapshot da coleta.

**Base:** H04 contexto; visão §8.

#### RECON-H04-10 — Rejeitar chave inválida sem atualizar equipamento

**História:** [ETICS-252611](https://jira.cpqd.com.br/browse/ETICS-252611) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Contador/spy disponível.

**Dados:** Lote canônico de tipo com chave registrada, mas fragmento sem a chave.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Lote rejeitado por chave inválida.

2. Verificar GP e contador.
   - **Esperado:** GP preservado; zero chamadas ao NestedRuleCaller.

**Base:** H04 RN9.

### [CLARO-Recon] H05 - Sincronizar o grupo Zona do IM no documento JSON do Roteador — ETICS-252614

#### RECON-H05-01 — Converter cada registry de zona em um objeto

**História:** [ETICS-252614](https://jira.cpqd.com.br/browse/ETICS-252614) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H04 e H05 disponíveis; fixture XML validada pelo contrato de zona.

**Dados:** equipment/additionalInfo/group/key=zona com duas registry de zonas distintas e suas interfaces.

1. Executar reconciliação e consultar CLOB.
   - **Esperado:** Dois fragmentos de zona correspondem às duas registry, preservando a associação de interfaces.

2. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** As duas zonas são inseridas no mesmo documento JSON do roteador.

**Base:** H05.

#### RECON-H05-02 — Atualizar zona existente integralmente

**História:** [ETICS-252614](https://jira.cpqd.com.br/browse/ETICS-252614) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Chave de zona confirmada no contrato de H05.

**Dados:** Zona já existente; IM retorna mesma identidade com outra lista de interfaces.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Zona substituída pela versão recebida.

2. Comparar zona e interfaces.
   - **Esperado:** Uma ocorrência para a identidade; lista final igual à recebida, sem merge com interfaces antigas.

**Base:** H05; H04 RN5.

**Observação/pendência:** Nome da chave de zona depende do contrato técnico referenciado, ainda não acessível.

#### RECON-H05-03 — Manter zonas fora da árvore de divergências

**História:** [ETICS-252614](https://jira.cpqd.com.br/browse/ETICS-252614) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H05 disponível.

**Dados:** Zona existente no GP com interfaces diferentes das retornadas no IM.

1. Executar reconciliação e detalhar.
   - **Esperado:** Zona não aparece na árvore de divergências.

2. Consultar GP antes e depois de Atualizar inventário.
   - **Esperado:** Antes mantém valor original; depois reflete zona recebida.

**Base:** H05.

#### RECON-H05-04 — Restringir conversor de zona ao grupo zona

**História:** [ETICS-252614](https://jira.cpqd.com.br/browse/ETICS-252614) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Harness do conversor H05.

**Dados:** XML contendo zona, HA, rotas, BGP, OSPF, RIP, port, card, vlan e pseudowire.

1. Executar o conversor de H05 isoladamente.
   - **Esperado:** Somente registry do grupo zona geram fragmentos.

2. Inspecionar os fragmentos produzidos.
   - **Esperado:** Nenhum fragmento produzido por H05 para os demais grupos.

**Base:** H05 escopo.

**Observação/pendência:** No fluxo integrado, outros conversores habilitados podem tratar seus próprios grupos.

#### RECON-H05-05 — Abortar conjunto de zonas diante de fragmento inválido

**História:** [ETICS-252614](https://jira.cpqd.com.br/browse/ETICS-252614) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H04/H05; spy disponível.

**Dados:** Uma zona válida e outra que gere fragmento inválido conforme contrato.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Lote do equipamento rejeitado integralmente.

2. Consultar GP e spy.
   - **Esperado:** Nenhuma das zonas aplicada; zero chamadas ao NestedRuleCaller.

**Base:** H05 infraestrutura H04.

### [CLARO-Recon] H06 - Sincronizar atributos HA do IM no objeto JSON Device do Roteador — ETICS-252615

#### RECON-H06-01 — Converter os quatro atributos HA de additionalInfo

**História:** [ETICS-252615](https://jira.cpqd.com.br/browse/ETICS-252615) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H04/H06 disponíveis.

**Dados:** group-name=SPO-HA-121; hbdev-1=port1; hbdev-2=port2; monitor=[x3,x4], diretamente em additionalInfo.

1. Executar reconciliação e inspecionar fragmento.
   - **Esperado:** Configuração device contém os quatro atributos e ambos os valores de monitor.

2. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Configuração device persistida no campo HW_OBJECTS_JSON do roteador.

**Base:** H06 exemplo XML.

#### RECON-H06-02 — Atualizar device preservando zonas existentes

**História:** [ETICS-252615](https://jira.cpqd.com.br/browse/ETICS-252615) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H05/H06 disponíveis.

**Dados:** GP contém device antigo e zona válida; IM retorna novos quatro atributos HA.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Configuração device atualizada no documento compartilhado.

2. Comparar zona com snapshot.
   - **Esperado:** Zona preservada; não é criado documento paralelo para HA.

**Base:** H06.

#### RECON-H06-03 — Converter somente os quatro atributos HA previstos

**História:** [ETICS-252615](https://jira.cpqd.com.br/browse/ETICS-252615) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Harness do conversor H06.

**Dados:** additionalInfo com quatro atributos HA e atributo extra; grupos zona/BGP; atributos HA homônimos dentro de port.

1. Executar conversor H06.
   - **Esperado:** Somente os quatro atributos diretos de equipment/additionalInfo alimentam device.

2. Inspecionar attributes de device.
   - **Esperado:** Atributo extra, grupos e atributos da porta não foram indevidamente convertidos.

**Base:** H06 escopo.

#### RECON-H06-04 — Persistir HA e zonas no mesmo lote

**História:** [ETICS-252615](https://jira.cpqd.com.br/browse/ETICS-252615) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H04/H05/H06 disponíveis; spy de NestedRuleCaller.

**Dados:** Resposta IM com zona válida e quatro atributos HA válidos.

1. Executar reconciliação e acionar Atualizar inventário.
   - **Esperado:** Documento final contém zona e device.

2. Inspecionar chamadas por equipamento.
   - **Esperado:** Uma chamada ao NestedRuleCaller com o documento combinado.

**Base:** H06; H04 RN8.

#### RECON-H06-05 — Substituir lista de interfaces monitoradas

**História:** [ETICS-252615](https://jira.cpqd.com.br/browse/ETICS-252615) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H06 disponível.

**Dados:** device contém monitor=[x3,x4]; IM retorna monitor=[x5] e demais atributos HA válidos.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** device atualizado.

2. Inspecionar monitor.
   - **Esperado:** Lista final contém apenas x5; x3 e x4 não são retidos por merge parcial.

**Base:** H06; H04 substituição integral.

### [CLARO-Recon] H07 - Sincronizar grupo de Roteamento Estático do IM no JSON do Roteador — ETICS-252629

#### RECON-H07-01 — Inserir rota estática recebida do IM

**História:** [ETICS-252629](https://jira.cpqd.com.br/browse/ETICS-252629) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H07 disponível; XML e mapeamento de rota aprovados.

**Dados:** Rota de teste: destination-address-mask=192.0.2.0/24, priority=10, ip-address=192.0.2.1; demais campos obrigatórios conforme contrato.

1. Coletar rota via reconciliação.
   - **Esperado:** GP permanece inalterado antes do comando de atualização.

2. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Rota recebida está presente no documento JSON do roteador com valores mapeados corretamente.

**Base:** H07; visão §6.30.

**Observação/pendência:** Fixture XML e objectType canônico ainda dependem do contrato técnico.

#### RECON-H07-02 — Atualizar rota com a mesma chave composta

**História:** [ETICS-252629](https://jira.cpqd.com.br/browse/ETICS-252629) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Mapeamento da chave da visão confirmado para H07.

**Dados:** GP e IM com destino 192.0.2.0/24 e prioridade 10; próximo salto muda de 192.0.2.1 para 192.0.2.2.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Rota existente atualizada, sem duplicação.

2. Verificar destino, prioridade e próximo salto.
   - **Esperado:** Mesma chave composta; próximo salto final 192.0.2.2.

**Base:** H07; visão §6.30.

**Observação/pendência:** Confirmar correspondência entre chave do modelo da visão e chave do JSON.

#### RECON-H07-03 — Distinguir rotas por prioridade

**História:** [ETICS-252629](https://jira.cpqd.com.br/browse/ETICS-252629) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Mapeamento da chave da visão confirmado para H07.

**Dados:** Duas rotas com destino 192.0.2.0/24, prioridades 10 e 20 e próximos saltos distintos.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Duas rotas persistidas.

2. Conferir identidades e atributos.
   - **Esperado:** Não há colisão por considerar somente o destino; prioridade participa da identidade.

**Base:** H07; visão §6.30.

**Observação/pendência:** Confirmar chave no contrato do JSON.

#### RECON-H07-04 — Atualizar rotas junto das demais configurações

**História:** [ETICS-252629](https://jira.cpqd.com.br/browse/ETICS-252629) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H04–H07 disponíveis.

**Dados:** GP contém device e zona; IM retorna rota estática nova.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Rota inserida no documento compartilhado.

2. Comparar device e zona com snapshot.
   - **Esperado:** Configurações não alteradas pelo lote permanecem intactas.

**Base:** H07; H04 RN10.

### [CLARO-Recon] H08 - Sincronizar Roteamento Dinâmico do IM no JSON do Roteador — ETICS-252632

#### RECON-H08-01 — Sincronizar configuração BGP do IM

**História:** [ETICS-252632](https://jira.cpqd.com.br/browse/ETICS-252632) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H08 disponível; fixture BGP homologada e mapeamento canônico definido.

**Dados:** Configuração BGP válida para equipamento suportado, com valores distintos do GP.

1. Executar reconciliação com a resposta controlada.
   - **Esperado:** Coleta concluída sem alterar o documento GP.

2. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Configuração BGP recebida presente no documento JSON do roteador com os valores previstos no mapeamento.

**Base:** H08.

**Observação/pendência:** A visão §6.28 marca diversos atributos Discovery=NÃO, enquanto H08 solicita sincronização; confirmar mapeamento antes de executar.

#### RECON-H08-02 — Sincronizar configuração OSPF do IM

**História:** [ETICS-252632](https://jira.cpqd.com.br/browse/ETICS-252632) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H08 disponível; fixture OSPF homologada e mapeamento canônico definido.

**Dados:** Configuração OSPF válida para equipamento suportado, com valores distintos do GP.

1. Executar reconciliação com a resposta controlada.
   - **Esperado:** Coleta concluída sem alterar o documento GP.

2. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Configuração OSPF recebida presente no documento JSON do roteador com os valores previstos no mapeamento.

**Base:** H08.

**Observação/pendência:** A visão §6.28 marca diversos atributos Discovery=NÃO, enquanto H08 solicita sincronização; confirmar mapeamento antes de executar.

#### RECON-H08-03 — Sincronizar configuração RIP do IM

**História:** [ETICS-252632](https://jira.cpqd.com.br/browse/ETICS-252632) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H08 disponível; fixture RIP homologada e mapeamento canônico definido.

**Dados:** Configuração RIP válida para equipamento suportado, com valores distintos do GP.

1. Executar reconciliação com a resposta controlada.
   - **Esperado:** Coleta concluída sem alterar o documento GP.

2. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Configuração RIP recebida presente no documento JSON do roteador com os valores previstos no mapeamento.

**Base:** H08.

**Observação/pendência:** A história inclui RIP; detalhamento ausente na visão. Fixture e critérios de mapeamento pendentes.

#### RECON-H08-04 — Sincronizar BGP, OSPF e RIP no mesmo equipamento

**História:** [ETICS-252632](https://jira.cpqd.com.br/browse/ETICS-252632) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H08 e os três contratos de conversão disponíveis; spy.

**Dados:** IM retorna configurações válidas de BGP, OSPF e RIP para equipamento suportado.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** As três configurações são aplicadas ao documento JSON do equipamento.

2. Inspecionar configurações e chamadas.
   - **Esperado:** Nenhum protocolo sobrescreve outro indevidamente; uma chamada final por equipamento.

**Base:** H08; H04 RN7–8.

**Observação/pendência:** Confirmar cardinalidade e identidade de cada protocolo no contrato.

#### RECON-H08-05 — Preservar rotas estáticas, zonas e HA ao atualizar protocolo

**História:** [ETICS-252632](https://jira.cpqd.com.br/browse/ETICS-252632) · **Tipo:** Funcional/Integração · **Prioridade proposta:** Alta

**Pré-condições:** Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H04–H08 disponíveis.

**Dados:** GP contém rota estática, zona, device e protocolo; IM altera somente o protocolo.

1. Acionar Atualizar inventário e consultar novamente o roteador no ISP.
   - **Esperado:** Protocolo atualizado.

2. Comparar os demais objetos com snapshot.
   - **Esperado:** Rotas estáticas, zonas e HA preservados integralmente.

**Base:** H08; H04 RN10.



## Convers?o BDD no Zephyr

Os 50 registros existentes foram convertidos para o tipo BDD e relidos para confirma??o. Keywords Given/When/Then e conte?do em portugu?s. Chaves, v?nculos e ciclo ETICS-C646 preservados. Evid?ncias: zephyr-bdd-state.json; backup anterior: zephyr-before-bdd.json. Todos n?o executados.
