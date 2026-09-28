# H01 — Revisão do documento técnico e divisão por equipe

> Histórico: as conclusões sobre novas colunas e atualização do modo 0 foram corrigidas após esclarecimentos do desenvolvedor. Consulte [a revisão posterior](h01-feedback-revisao.md). Os casos T8088 e T8089 estão descontinuados para H01.

História: [ETICS-252410](https://jira.cpqd.com.br/browse/ETICS-252410).
Fonte: arquivo h01-md.txt fornecido pelo usuário, conteúdo de 01-sync-silencioso-im-para-gp.md. Revisão e publicação verificadas em 10/09/2026. A cópia anexada não identifica commit do Bitbucket.

## Testes sistêmicos

Ciclo **ETICS-C647 — CLARO | RECON H01 | Testes sistêmicos | Revisão MD**.
Oito casos: seis reaproveitados (ETICS-T8036 a ETICS-T8041) e dois novos (ETICS-T8086 e ETICS-T8087).
Label: TESTE_SISTEMICO. Casos e ciclo sem pasta específica.

O T8038 foi ampliado para exigir apenas diferença silenciosa, ausência de status de erro e ícone de divergência decorrentes dela e atualização sem selecionar qualquer nó de atributo. Os outros cinco roteiros foram preservados; os seis receberam identificação da equipe em objetivo e label.
Os casos verificam o comportamento via reconciliação e inventário GP. Preparação de respostas IM controladas pode exigir apoio técnico.

## Desenvolvimento

Ciclo **ETICS-C648 — CLARO | RECON H01 | Desenvolvimento | Revisão MD**.
Seis novos casos: ETICS-T8088 a ETICS-T8093.
Label: TESTE_DESENVOLVIMENTO. Casos e ciclo sem pasta específica.
Esta classificação identifica a equipe responsável pela natureza da verificação; não atribui execução a uma pessoa nem envia mensagens.

A normalização de espaços, caixa e null/vazio no modo 1 foi separada no T8093 para execução em harness. O roteiro sistêmico T8037 permanece preservado.

## Novos casos e fontes

| ID | Zephyr | Equipe | Comportamento | Fonte |
|---|---|---|---|---|
| RECON-H01-SYS-07 | ETICS-T8086 | Sistêmico | Inserir equipamento do IM com atributos silenciosos | §13 e critérios de aceite |
| RECON-H01-SYS-08 | ETICS-T8087 | Sistêmico | Atualizar a partir de resultado reaberto posteriormente | §§7 e 10; critérios de aceite |
| RECON-H01-DEV-01 | ETICS-T8088 | Desenvolvimento | Criar esquema com padrão seguro para novas colunas | §2 |
| RECON-H01-DEV-02 | ETICS-T8089 | Desenvolvimento | Aplicar patch preservando configurações legadas | §2 |
| RECON-H01-DEV-03 | ETICS-T8090 | Desenvolvimento | Mapear e persistir todos os atributos silenciosos suportados | §§3, 5, 7 e 13 |
| RECON-H01-DEV-04 | ETICS-T8091 | Desenvolvimento | Enviar atributos silenciosos pelo mecanismo padrão de update | §§10 e 12; critérios de aceite |
| RECON-H01-DEV-05 | ETICS-T8092 | Desenvolvimento | Converter chaves silenciosas para nomes meta do GP | §11 |
| RECON-H01-DEV-06 | ETICS-T8093 | Desenvolvimento | Preservar normalização da comparação no modo 1 | Contexto atual e §8 |

## Escopo e pendências

- Homologar nomes canônicos, matriz de mapeamento, novas colunas, tipos suportados e fixtures antes de executar. As tabelas citadas como prováveis no MD não são uma lista de suporte confirmado.
- Instalação e patch: usar bases descartáveis e versão alvo definida pela equipe. Não foi inferida versão de execução a partir da branch.
- Desenvolvimento requer harness, observação de ObjectUpdate/mapAtributes/NestedRuleCaller e leitura técnica do banco. Nenhuma quantidade exata de chamadas foi imposta à H01.
- Null/vazio no modo 2, falhas/retentativas e efeito de alteração da configuração após coleta não têm resultado esperado suficientemente definido no documento.
- Confirmar as regras aplicáveis de bloqueio de configurações nativas/em uso antes de redigir testes de aceitação específicos.
- Relatórios/auditoria dependem da decisão de escopo prevista no §14; não foi criada exigência de exposição.
- Tela e persistência dos modos estão nos casos H02 T8042–T8046. JSON e chamadas de H04 têm cobertura própria, não substituem a verificação técnica dos atributos de H01.
- Os novos ciclos contêm apenas H01. A classificação dos demais casos H02–H08 não foi alterada.
- O ciclo geral ETICS-C646 mantém os 50 membros e respectivos estados. Os seis casos H01 são reutilizados no novo ciclo sistêmico, sem duplicação de registros.
- Todos os 14 roteiros foram conferidos como BDD e vinculados à história. Os 14 itens dos novos ciclos estão em Not Executed; os casos estão em Draft e prioridade Normal. Não foram executados testes do produto.

## Evidências

- h01-review-before.json: backup dos seis casos existentes antes da alteração.
- h01-review-original-cycle.json: backup do ciclo geral.
- h01-review-plan.json: novos roteiros planejados.
- h01-review-published.json: IDs, chaves e ciclos publicados.
- h01-review-verification.json: releitura dos casos e ciclos, com verificação de preservação.

Consultar no Zephyr Scale → Casos de teste → Roteiro de teste/Test Script e Ciclos/Test Cycles.

## Roteiros novos

### ETICS-T8086 — RECON-H01-SYS-07 — Inserir equipamento do IM com atributos silenciosos

Equipe: Sistêmico. Fonte: §13 e critérios de aceite.

Pré-condições: Equipamento existe somente no IM; tipo suporta inserção pelo fluxo atual; atributos A e B suportados com modo 2; dados obrigatórios válidos; fixture homologada.

```gherkin
Given um equipamento suportado existente somente no IM, com A e B configurados como 2 e valores IM_A e IM_B
When executar a reconciliação e consultar o inventário GP
Then o equipamento ainda não existe no GP
When acionar a inserção pelo fluxo existente de Atualizar inventário
Then o equipamento é criado no GP com A=IM_A e B=IM_B
And os atributos silenciosos não exigem seleção individual em nós de divergência
```

### ETICS-T8087 — RECON-H01-SYS-08 — Atualizar a partir de resultado reaberto posteriormente

Equipe: Sistêmico. Fonte: §§7 e 10; critérios de aceite.

Pré-condições: Equipamento pareado; A=2; GP=GP_A; resposta IM controlada com IM_A; resultado concluído e disponível para reabertura; nenhuma nova reconciliação.

```gherkin
Given um equipamento pareado com A configurado como 2 e valor GP_A no GP
And a reconciliação coletou IM_A para A e foi concluída
When fechar o resultado e encerrar a sessão sem acionar Atualizar inventário
Then A permanece com GP_A no GP
When iniciar outra sessão e reabrir o mesmo resultado sem executar nova reconciliação
And acionar Atualizar inventário
Then A passa a IM_A no GP sem seleção individual do atributo
```

### ETICS-T8088 — RECON-H01-DEV-01 — Criar esquema com padrão seguro para novas colunas

Equipe: Desenvolvimento. Fonte: §2.

Pré-condições: Base descartável vazia; instalador da versão alvo; lista de novas colunas efetivamente implementadas aprovada pelo desenvolvimento.

```gherkin
Given uma base vazia destinada à instalação da versão alvo
When criar o esquema pelo instalador oficial
Then cada nova coluna implementada em RECON_ATRIB_CFG possui DEFAULT 0 e NOT NULL
When criar uma configuração válida omitindo essas novas colunas
Then cada nova coluna assume o valor 0
When persistir o valor 2 em cada nova coluna por operações válidas
Then o valor 2 é aceito e recuperado como 2
```

### ETICS-T8089 — RECON-H01-DEV-02 — Aplicar patch preservando configurações legadas

Equipe: Desenvolvimento. Fonte: §2.

Pré-condições: Cópia descartável de base anterior; snapshot das configurações 0 e 1; patch oficial e novas colunas identificados.

```gherkin
Given uma base da versão anterior com configurações existentes em 0 e 1
When aplicar o patch oficial para as novas colunas de RECON_ATRIB_CFG
Then os valores preexistentes permanecem iguais ao snapshot
And as novas colunas possuem DEFAULT 0 e NOT NULL e os registros anteriores recebem 0
When salvar 2 nas novas colunas de uma configuração editável
Then o valor 2 é persistido e recuperado corretamente
```

### ETICS-T8090 — RECON-H01-DEV-03 — Mapear e persistir todos os atributos silenciosos suportados

Equipe: Desenvolvimento. Fonte: §§3, 5, 7 e 13.

Pré-condições: Harness e banco de teste; matriz aprovada atributo IM → propriedade POJO → chave getAttributesMap → coluna RECON_* → campo GP; incluir apenas tipos implementados e valores distintos por atributo.

```gherkin
Given a matriz aprovada de novos atributos e tipos suportados com todos os atributos configurados como 2
And uma resposta IM válida contendo valores distintos identificáveis para cada atributo
When carregar ReconAttributesConfig e executar a recuperação e persistência da reconciliação
Then getAttributesMap contém cada chave esperada com valor textual 2
And cada valor IM é mapeado ao POJO e persistido na coluna RECON_* correspondente ao objeto correto
When recuperar o resultado em um novo contexto de persistência
Then os valores IM são recuperados integralmente para montagem da atualização
When construir o objeto externo para um tipo suportado na inserção
Then BuildEquipmentExternal disponibiliza os novos valores persistidos sem troca entre atributos ou objetos
```

### ETICS-T8091 — RECON-H01-DEV-04 — Enviar atributos silenciosos pelo mecanismo padrão de update

Equipe: Desenvolvimento. Fonte: §§10 e 12; critérios de aceite.

Pré-condições: Harness/spy de ReconService e NestedRuleCaller; configuração usada na reconciliação; resultado persistido com A=2, B=0 e valores IM distintos; atributos válidos; nenhum update manual selecionado.

```gherkin
Given um resultado persistido com A configurado como 2 e B como 0 e seus valores IM identificáveis
When montar os atributos para Atualizar inventário sem seleção manual de atributos
Then a configuração da reconciliação é carregada e um ObjectUpdate silencioso é criado para A com seu valor IM persistido
And B não é incluído como atualização silenciosa
When executar o update
Then o fluxo padrão chama NestedRuleCaller.execute com o objeto e a operação previstos
And mapAtributes contém o campo de A com o valor IM persistido
And o GP passa a conter esse valor após a execução bem-sucedida
```

### ETICS-T8092 — RECON-H01-DEV-05 — Converter chaves silenciosas para nomes meta do GP

Equipe: Desenvolvimento. Fonte: §11.

Pré-condições: Harness do conversor e update; dois atributos suportados: A cuja chave difere do nome meta e B cuja chave já é o nome meta; mapeamentos reais aprovados antes da execução.

```gherkin
Given dois atributos silenciosos suportados A e B com valores IM_A e IM_B
And a chave de A exige conversão para seu nome meta e a chave de B já corresponde ao seu nome meta
When montar e converter os atributos para atualização do GP
Then A usa o nome meta definido no mapeamento e B mantém o nome meta original
And os valores IM_A e IM_B permanecem associados aos respectivos campos
When executar a atualização pelo mecanismo padrão
Then os dois campos corretos no GP recebem seus valores IM sem criação de campos com nomes de descrição
```

### ETICS-T8093 — RECON-H01-DEV-06 — Preservar normalização da comparação no modo 1

Equipe: Desenvolvimento. Fonte: Contexto atual e §8.

Pré-condições: Harness do comparador com atributo suportado em modo 1; fixtures sintéticas independentes; null representa ausência Java e não a string null.

```gherkin
Given um atributo configurado como 1 em execuções independentes do comparador
When comparar IM="  ABC  " com GP="abc"
Then o comparador considera os valores equivalentes
When comparar IM=null com GP="" e depois IM="" com GP=null
Then o comparador considera os valores equivalentes nas duas execuções
When comparar IM="ABC" com GP="ABD"
Then o comparador identifica diferença
And nenhuma chamada de comparação persiste atualização no inventário
```
