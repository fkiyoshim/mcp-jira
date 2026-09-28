# Reconciliação — revisão H02–H08 e correções da H01

Revisão concluída em 10/09/2026 no projeto ETICS. Foram consultados 7.910 casos únicos com paginação completa, identificados 44 casos vinculados a H02–H08 e cadastrados 63 complementos. A conferência final releu 77 casos: 63 novos e os 14 da H01.

## Resultado por história

| História | Jira | Casos anteriores | Complementos cadastrados | Chaves novas |
|---|---|---:|---:|---|
| [H02](https://jira.cpqd.com.br/browse/ETICS-252562) | ETICS-252562 | 5 | 5 | ETICS-T8094 a ETICS-T8098 |
| [H03](https://jira.cpqd.com.br/browse/ETICS-252569) | ETICS-252569 | 10 | 28 | ETICS-T8099 a ETICS-T8126 |
| [H04](https://jira.cpqd.com.br/browse/ETICS-252611) | ETICS-252611 | 10 | 10 | ETICS-T8127 a ETICS-T8136 |
| [H05](https://jira.cpqd.com.br/browse/ETICS-252614) | ETICS-252614 | 5 | 9 | ETICS-T8137 a ETICS-T8145 |
| [H06](https://jira.cpqd.com.br/browse/ETICS-252615) | ETICS-252615 | 5 | 9 | ETICS-T8146 a ETICS-T8154 |
| [H07](https://jira.cpqd.com.br/browse/ETICS-252629) | ETICS-252629 | 4 | 1 | ETICS-T8155 |
| [H08](https://jira.cpqd.com.br/browse/ETICS-252632) | ETICS-252632 | 5 | 1 | ETICS-T8156 |

Todos os novos casos estão em Draft, com roteiro BDD e vínculo à respectiva história. Casos novos sem pasta específica e sem associação a novo ciclo: o pedido não definiu ciclo de destino. Nenhum teste foi executado, nem resultado de execução registrado. Os rótulos TESTE_SISTEMICO e TESTE_DESENVOLVIMENTO identificam a natureza da validação; os testes técnicos indicam expressamente que não podem ser executados integralmente apenas pela aplicação.

Consultar em **Zephyr Scale → Casos de teste → Roteiro de teste/Test Script**. Filtrar pelo label RECON_H02_H08_MD ou pelas chaves abaixo. As histórias possuem os vínculos de cobertura.

## Comparação e decisões

- H02: os cinco casos anteriores cobriam listas, persistência 0/1/2, configurações legadas e comparação. Os complementos cobrem metadados dos 23 campos, idiomas, atualização do metamodelo e bloqueios de edição.
- H03: os dez casos anteriores usam o contrato legado por objectType. O MD fornecido em 03/09/2026 define ResourceDocumentPatchService, envelope versionado, patch parcial, IDs sequenciais e schema consumidor. Essa cobertura nova foi cadastrada separadamente. Os casos antigos continuam úteis à regressão da API legada, explicitamente preservada no MD.
- H04: os dez casos anteriores cobriam coleta, atomicidade geral, atualização única, chaves e leitura tardia. Os complementos tratam tamanho/representações do CLOB, documento inicial, vários destinos, allowlist/configuração, JSON bruto, metamodelo e logs.
- H05: os cinco casos anteriores cobriam conversão geral, substituição, árvore, escopo e falha genérica. Os complementos detalham cardinalidade e duplicidade, metadados XML, compatibilidade legada, nomes exatos, pacote integrado e documento vazio.
- H06: os cinco casos anteriores cobriam conversão geral, preservação de zonas, escopo, lote combinado e substituição de monitor. Os complementos detalham o de/para, singleton, cardinalidades, ausência/HA parcial, colisão de mapeamento, logs e entrega conjunta.
- H07/H08: os MDs estão em draft. Os novos casos verificam a proibição de persistir os contratos provisórios enquanto faltam decisões. Não foram inventados objectType final, identidade, cardinalidade, destino ou regra de tratamento de autenticação.
- H04–H06 continuam descrevendo o array canônico e a API legada de upsert; a nova API de H03 não foi aplicada implicitamente a essas histórias.
- A confirmação de que H01 não criou colunas foi aplicada à H01. Ela não elimina os requisitos explícitos de CLOB/metamodelo presentes no MD da H04.

## Pendências de contrato

1. H01: ETICS-175367 confirma modo 0 sem match e com apresentação informativa, mas não define sua atualização. O relato indica que 0 atualiza no fluxo existente e levanta hipótese de defeito legado. Os casos corrigidos exigem preservar uma referência anterior usando a mesma massa; definir o comportamento funcional definitivo permanece pendente.
2. H03: a descrição Jira ainda apresenta o contrato antigo; os novos casos citam o MD fornecido e a API nova. O texto da história Jira não foi reescrito.
3. H07: falta de/para dos sete campos, objectType final, cardinalidade, identidade e destino. Os testes anteriores de chave composta/prioridade T8078/T8079 não comprovam aprovação dessa identidade; requerem reavaliação após decisão de domínio.
4. H08: faltam de/para, identidade/cardinalidade, atualização dos arrays, destinos e tratamento das chaves de autenticação. Os casos prévios de sincronização continuam dependentes dessas definições.
5. H02: o MD não fornece os textos finais traduzidos dos labels; o caso de idiomas exige o catálogo aprovado.

A existência de casos cadastrados não significa aceite funcional, execução aprovada ou resolução das pendências.

## Correção adicional da H01

Ver [relatório da H01](h01-feedback-revisao.md): cinco casos ajustados (T8036, T8039, T8090, T8091 e T8092) e dois descontinuados (T8088 e T8089). Os 14 casos foram relidos.

Os ciclos ETICS-C646 (50 membros), ETICS-C647 (8 membros) e ETICS-C648 (6 membros históricos) mantêm seus membros e resultados anteriores. T8088/T8089 permanecem no histórico do ciclo de desenvolvimento, mas estão Deprecated e explicitamente não devem ser executados para H01. Casos e ciclos sem pasta específica.

## Mapa de publicação

| ID local | Zephyr | História | Natureza | Comportamento | Fonte |
|---|---|---|---|---|---|
| RECON-H02-MD-01 | ETICS-T8094 | ETICS-252562 | Desenvolvimento | Conferir metadados dos 23 atributos e preservar o layout | h02-md.txt — AC1–3; Campos impactados; Tasks metamodelo |
| RECON-H02-MD-02 | ETICS-T8095 | ETICS-252562 | Sistêmico | Validar labels das listas nos quatro idiomas | h02-md.txt — AC2; Tasks labels multi-idioma |
| RECON-H02-MD-03 | ETICS-T8096 | ETICS-252562 | Desenvolvimento | Atualizar metadados de ambiente existente sem conflito de IDs | h02-md.txt — AC7; Tasks carga em ambientes existentes |
| RECON-H02-MD-04 | ETICS-T8097 | ETICS-252562 | Sistêmico | Preservar bloqueio de alteração de configuração em uso | h02-md.txt — Tasks impacto runtime; VerifyMatchAttributesInUseRuleObject |
| RECON-H02-MD-05 | ETICS-T8098 | ETICS-252562 | Sistêmico | Preservar bloqueio de alteração de configuração nativa | h02-md.txt — Tasks impacto runtime; VerifyMatchAttributesNativeRuleObject |
| RECON-H03-MD-01 | ETICS-T8099 | ETICS-252569 | Desenvolvimento | Inicializar envelope de recurso a partir do schema | h03-md.txt — AC1; Contrato do documento atual |
| RECON-H03-MD-02 | ETICS-T8100 | ETICS-252569 | Desenvolvimento | Aplicar patch global preservando atributos omitidos | h03-md.txt — AC2; Contrato de entrada |
| RECON-H03-MD-03 | ETICS-T8101 | ETICS-252569 | Desenvolvimento | Atualizar recurso por chave exata preservando ID e campos omitidos | h03-md.txt — AC3; Semântica de patch |
| RECON-H03-MD-04 | ETICS-T8102 | ETICS-252569 | Desenvolvimento | Inserir recurso obrigatório com ID gerado pelo contador | h03-md.txt — AC4; Semântica de patch |
| RECON-H03-MD-05 | ETICS-T8103 | ETICS-252569 | Desenvolvimento | Gerar IDs consecutivos e resultados na ordem do lote | h03-md.txt — AC5; API pública proposta |
| RECON-H03-MD-06 | ETICS-T8104 | ETICS-252569 | Desenvolvimento | Compartilhar sequência de IDs entre coleções | h03-md.txt — AC6; IDs únicos em todo o documento |
| RECON-H03-MD-07 | ETICS-T8105 | ETICS-252569 | Desenvolvimento | Substituir array inteiro no patch de recurso | h03-md.txt — AC8 |
| RECON-H03-MD-08 | ETICS-T8106 | ETICS-252569 | Desenvolvimento | Comparar identidade composta como tupla exata | h03-md.txt — AC13; identidade composta |
| RECON-H03-MD-09 | ETICS-T8107 | ETICS-252569 | Desenvolvimento | Não inferir renomeação de identidade do recurso | h03-md.txt — Semântica de patch; identidade imutável |
| RECON-H03-MD-10 | ETICS-T8108 | ETICS-252569 | Desenvolvimento | Rejeitar schema ausente ou inconsistente | h03-md.txt — AC7; Validações e erros |
| RECON-H03-MD-11 | ETICS-T8109 | ETICS-252569 | Desenvolvimento | Rejeitar envelope incompatível com o schema | h03-md.txt — AC9; Validações e erros |
| RECON-H03-MD-12 | ETICS-T8110 | ETICS-252569 | Desenvolvimento | Rejeitar patch inválido ou com múltiplas chaves raiz | h03-md.txt — Contrato de entrada; Validações e erros |
| RECON-H03-MD-13 | ETICS-T8111 | ETICS-252569 | Desenvolvimento | Rejeitar coleção não cadastrada no schema | h03-md.txt — AC7; Validações e erros |
| RECON-H03-MD-14 | ETICS-T8112 | ETICS-252569 | Desenvolvimento | Rejeitar atributo global ou de recurso desconhecido | h03-md.txt — AC7; Validações e erros |
| RECON-H03-MD-15 | ETICS-T8113 | ETICS-252569 | Desenvolvimento | Rejeitar tipo de atributo incompatível com o schema | h03-md.txt — AC7; Validações e erros |
| RECON-H03-MD-16 | ETICS-T8114 | ETICS-252569 | Desenvolvimento | Rejeitar identidade ausente ou inválida em recurso | h03-md.txt — AC7; Validações e erros |
| RECON-H03-MD-17 | ETICS-T8115 | ETICS-252569 | Desenvolvimento | Rejeitar identidade duplicada no documento ou lote | h03-md.txt — AC7; Validações e erros |
| RECON-H03-MD-18 | ETICS-T8116 | ETICS-252569 | Desenvolvimento | Rejeitar ID repetido entre recursos de qualquer coleção | h03-md.txt — AC6; Validações e erros |
| RECON-H03-MD-19 | ETICS-T8117 | ETICS-252569 | Desenvolvimento | Rejeitar contador de recurso ausente ou inválido | h03-md.txt — AC6; Validações e erros |
| RECON-H03-MD-20 | ETICS-T8118 | ETICS-252569 | Desenvolvimento | Rejeitar insert sem atributo obrigatório | h03-md.txt — AC7; Validações e erros |
| RECON-H03-MD-21 | ETICS-T8119 | ETICS-252569 | Desenvolvimento | Rejeitar null em atributo global ou campo de recurso | h03-md.txt — AC8; Validações e erros |
| RECON-H03-MD-22 | ETICS-T8120 | ETICS-252569 | Desenvolvimento | Rejeitar array abaixo da cardinalidade do schema | h03-md.txt — AC7–8; schema minItems |
| RECON-H03-MD-23 | ETICS-T8121 | ETICS-252569 | Desenvolvimento | Exigir todos os componentes da identidade em insert e update | h03-md.txt — AC13; Semântica de patch |
| RECON-H03-MD-24 | ETICS-T8122 | ETICS-252569 | Desenvolvimento | Preservar contador e documento quando o último item falha | h03-md.txt — Semântica de patch; atomicidade |
| RECON-H03-MD-25 | ETICS-T8123 | ETICS-252569 | Desenvolvimento | Ler schema em UTF-8 e fechar os recursos recebidos | h03-md.txt — API pública proposta; parser de schema |
| RECON-H03-MD-26 | ETICS-T8124 | ETICS-252569 | Desenvolvimento | Garantir resultados imutáveis e chamadas sem estado | h03-md.txt — API pública proposta |
| RECON-H03-MD-27 | ETICS-T8125 | ETICS-252569 | Desenvolvimento | Manter compatibilidade binária da API legada no Java 8 | h03-md.txt — AC10–12; build e API pública |
| RECON-H03-MD-28 | ETICS-T8126 | ETICS-252569 | Desenvolvimento | Manter a API de patch genérica e sem payload nos logs | h03-md.txt — AC11; limites de domínio |
| RECON-H04-MD-01 | ETICS-T8127 | ETICS-252611 | Desenvolvimento | Transportar CLOB extenso sem truncamento | h04-md.txt — AC1–2; transporte e persistência intermediária |
| RECON-H04-MD-02 | ETICS-T8128 | ETICS-252611 | Desenvolvimento | Ler CLOB nulo ou vazio como lista vazia | h04-md.txt — AC2; transporte |
| RECON-H04-MD-03 | ETICS-T8129 | ETICS-252611 | Desenvolvimento | Inicializar merge a partir de JSON GP nulo ou em branco | h04-md.txt — AC6; RN5 |
| RECON-H04-MD-04 | ETICS-T8130 | ETICS-252611 | Desenvolvimento | Agrupar múltiplos campos JSON com atualização legada única | h04-md.txt — AC4 e AC7; RN4 e RN7 |
| RECON-H04-MD-05 | ETICS-T8131 | ETICS-252611 | Desenvolvimento | Rejeitar tipo sem destino na allowlist | h04-md.txt — AC5; RN3 |
| RECON-H04-MD-06 | ETICS-T8132 | ETICS-252611 | Desenvolvimento | Validar configuração de destinos antes da atualização | h04-md.txt — RN6; configuração e serviço de atualização |
| RECON-H04-MD-07 | ETICS-T8133 | ETICS-252611 | Desenvolvimento | Preservar JSON bruto com dois-pontos e fluxo legado | h04-md.txt — AC8; RN8–9 |
| RECON-H04-MD-08 | ETICS-T8134 | ETICS-252611 | Desenvolvimento | Abortar todos os destinos quando um campo falha | h04-md.txt — RN6–7; AC5 |
| RECON-H04-MD-09 | ETICS-T8135 | ETICS-252611 | Desenvolvimento | Conferir metamodelo BLOB e instalação da coluna CLOB | h04-md.txt — AC3; alterações técnicas 1–2 |
| RECON-H04-MD-10 | ETICS-T8136 | ETICS-252611 | Desenvolvimento | Evitar XML e JSON completos nos logs do fluxo | h04-md.txt — AC9 |
| RECON-H05-MD-01 | ETICS-T8137 | ETICS-252614 | Desenvolvimento | Preservar cardinalidade, ordem e duplicatas das interfaces de zona | h05-md.txt — AC2; RN4–5 |
| RECON-H05-MD-02 | ETICS-T8138 | ETICS-252614 | Desenvolvimento | Rejeitar cardinalidade inválida de zone-name antes da persistência | h05-md.txt — AC3; RN3 |
| RECON-H05-MD-03 | ETICS-T8139 | ETICS-252614 | Desenvolvimento | Rejeitar interface ausente, vazia ou nula no lote de zonas | h05-md.txt — AC3; RN4 |
| RECON-H05-MD-04 | ETICS-T8140 | ETICS-252614 | Desenvolvimento | Rejeitar zone-name repetido com registryId diferente | h05-md.txt — AC3; RN6 e RN8 |
| RECON-H05-MD-05 | ETICS-T8141 | ETICS-252614 | Desenvolvimento | Excluir labels e registryId do JSON e dos logs | h05-md.txt — AC5; RN6 |
| RECON-H05-MD-06 | ETICS-T8142 | ETICS-252614 | Desenvolvimento | Processar XML legado e ausência do grupo zona | h05-md.txt — AC6; contrato EAI e JAXB |
| RECON-H05-MD-07 | ETICS-T8143 | ETICS-252614 | Desenvolvimento | Distinguir zone-name por caixa e espaços sem normalização | h05-md.txt — RN1 e RN3; AC4 |
| RECON-H05-MD-08 | ETICS-T8144 | ETICS-252614 | Desenvolvimento | Verificar entrega conjunta de contrato, chave e destino da zona | h05-md.txt — AC9; identidade e destino |
| RECON-H05-MD-09 | ETICS-T8145 | ETICS-252614 | Desenvolvimento | Inserir zonas com documento vazio e entregar JSON bruto uma vez | h05-md.txt — AC7–8 |
| RECON-H06-MD-01 | ETICS-T8146 | ETICS-252615 | Desenvolvimento | Conferir de/para HA exato e singleton sem chave artificial | h06-md.txt — AC1 e AC8; RN1 e RN6 |
| RECON-H06-MD-02 | ETICS-T8147 | ETICS-252615 | Desenvolvimento | Preservar monitor como array sem normalizar seus valores | h06-md.txt — AC2; Contrato JSON |
| RECON-H06-MD-03 | ETICS-T8148 | ETICS-252615 | Desenvolvimento | Rejeitar HA parcial e campos single com cardinalidade inválida | h06-md.txt — AC3; RN2 e RN5 |
| RECON-H06-MD-04 | ETICS-T8149 | ETICS-252615 | Desenvolvimento | Rejeitar monitor ausente ou vazio sem aplicar zonas válidas | h06-md.txt — AC3; RN3 e RN5 |
| RECON-H06-MD-05 | ETICS-T8150 | ETICS-252615 | Desenvolvimento | Aceitar ausência completa de HA no XML legado | h06-md.txt — AC4; RN4 |
| RECON-H06-MD-06 | ETICS-T8151 | ETICS-252615 | Desenvolvimento | Falhar para mapeamento HA incompleto ou colisão de destinos | h06-md.txt — RN7; configuração de de/para |
| RECON-H06-MD-07 | ETICS-T8152 | ETICS-252615 | Desenvolvimento | Excluir labels e dados HA dos logs em sucesso e falha | h06-md.txt — AC7; WSDL/JAXB e adaptador |
| RECON-H06-MD-08 | ETICS-T8153 | ETICS-252615 | Desenvolvimento | Inserir device em documento vazio e substituir singleton por inteiro | h06-md.txt — AC5; RN10 |
| RECON-H06-MD-09 | ETICS-T8154 | ETICS-252615 | Desenvolvimento | Validar entrega integrada HA e duas zonas por um único merge | h06-md.txt — AC6 e AC9; transporte e atualização |
| RECON-H07-MD-01 | ETICS-T8155 | ETICS-252629 | Desenvolvimento | Impedir persistência de rota estática enquanto o contrato estiver pendente | h07-md.txt — Regras provisórias 4–5; decisões bloqueadoras |
| RECON-H08-MD-01 | ETICS-T8156 | ETICS-252632 | Desenvolvimento | Impedir persistência de protocolos enquanto os contratos estiverem pendentes | h08-md.txt — Regras provisórias 4; decisões bloqueadoras |

## Evidências locais

- h02-h08-md-before.json: histórias, casos anteriores e ciclo de referência.
- h02-h08-md-plan.json: planejamento inicial dos 63 complementos.
- h02-h08-md-published.json: mapa consolidado de publicação.
- h02-h08-md-progress.json: chaves e progresso por caso.
- h02-h08-md-final-verification.json: releitura dos 77 registros, verificações de conteúdo/vínculos e preservação dos ciclos.
- h02-h08-md-cenarios.feature: cópia dos novos roteiros para consulta, não suíte de automação.
- h01-feedback-before.json, h01-feedback-plan.json e h01-feedback-verification.json: backup, alterações e conferência da H01.

Os arquivos antigos permanecem como histórico e não devem substituir esta revisão.
