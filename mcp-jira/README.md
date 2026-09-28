# MCP Jira CPQD

Servidor MCP local para Jira Data Center e Zephyr Scale em
`https://jira.cpqd.com.br`, limitado por padrao ao projeto `ETICS`.
O modo de escrita e ativado explicitamente pelo argumento `--write`.
O registro deste workspace em `.codex/config.toml` usa esse argumento e
solicita aprovacao para ferramentas de escrita.

## Pre-requisitos

- Node.js 20 ou mais recente.
- Um Personal Access Token do Jira com permissoes de leitura e, para escrita,
  criacao/edicao/vinculos no projeto ETICS e permissoes correspondentes no Zephyr.
  Use uma conta com acesso apenas aos projetos necessarios e, se possivel, um
  token com prazo de validade. O token herda as permissoes da conta; a allowlist
  do MCP nao restringe o uso do token fora deste servidor.
  O MCP nao concede permissoes no servidor Jira.

Configure a credencial no ambiente do Windows sem gravar o token no repositorio:

```powershell
.\mcp-jira\configure-token.ps1
```

O script grava `JIRA_TOKEN` nas variaveis do usuario do Windows, de forma
persistente. Outros processos executados por esse usuario podem receber a
variavel. Para usar apenas na sessao atual do PowerShell, defina a variavel
antes de abrir o Codex a partir dessa mesma sessao:

```powershell
$env:JIRA_TOKEN = "seu-token"
```

Feche e reabra o Codex depois de configurar uma variavel persistente. Se a
instalacao corporativa usa uma CA privada, defina `NODE_EXTRA_CA_CERTS` com o
caminho do certificado PEM.

Como alternativa ao token, o servidor aceita `JIRA_USERNAME` e `JIRA_PASSWORD`
via Basic Auth, caso o Jira corporativo permita.

## Ferramentas

- `jira_get_issue`: consulta uma issue, como `ETICS-239275`.
- `jira_search_issues`: pesquisa com JQL dentro da allowlist.
- `jira_get_comments`: lista comentarios de uma issue.
- `jira_get_project`: consulta os detalhes de um projeto autorizado.

- `jira_get_permissions`, `jira_get_create_metadata`, `jira_get_link_types`:
  consultas auxiliares para preparar escritas.
- `jira_create_issue`, `jira_update_issue`, `jira_link_issues`:
  criacao, edicao e vinculos de issues.
- `zephyr_get_test`, `zephyr_search_tests`, `zephyr_get_cycle`,
  `zephyr_search_cycles`: consulta de testes, passos e ciclos.
- `zephyr_create_test`: cria teste com passos e `issue_links` para as historias.
- `zephyr_update_test`: atualiza campos de teste; `steps` substitui o roteiro
  completo e `issue_links` substitui a lista de vinculos. Consultar antes de editar.
- `zephyr_create_cycle`: cria ciclo com `test_keys` existentes. Os itens sao
  criados com status `Not Executed`; nenhum resultado aprovado e fabricado.

As seis ferramentas de escrita so aparecem quando iniciado com `--write`.
Sem esse argumento, permanecem as consultas. Nao existem ferramentas de exclusao,
administracao de permissoes ou movimento de issues neste servidor.

A allowlist padrao contem apenas `ETICS` e e validada tambem nas referencias a
historias e testes. Para autorizar outros projetos, defina
`JIRA_ALLOWED_PROJECTS=ETICS,OUTRO`. O transporte nao segue redirecionamentos,
nao repete POST/PUT automaticamente e preserva erros HTTP. Se houver timeout,
consulte o destino antes de tentar criar novamente: a escrita pode ter ocorrido.

Esta instalacao usa **Zephyr Scale** (`/rest/atm/1.0`), e nao Zephyr Squad
(`/rest/zapi`). Testes Scale possuem chaves como `ETICS-T1` e ciclos `ETICS-R1`;
nao devem ser criados como issues Jira do tipo Test.

## Codex

Abra a raiz deste repositorio (`gp-vivo-regressao`) como workspace e marque o
projeto como confiavel no Codex. O arquivo `.codex/config.toml` usa caminhos
relativos a essa raiz para iniciar `node mcp-jira/server.mjs --write`; nao contem
credenciais nem caminhos especificos de uma maquina. Cada colaborador deve
configurar sua propria credencial conforme as instrucoes acima.

Reinicie o Codex/IDE apos configurar a credencial e confira a conexao pela tela
de servidores MCP ou pelo comando `/mcp`. As consultas ficam disponiveis sem
aprovacao individual; criacao e edicao solicitam aprovacao antes da chamada.
Se quiser executar o servidor manualmente para diagnostico, rode o comando
acima a partir da raiz. Isso nao conecta o processo manual a uma conversa do
Codex.

Teste local:

```powershell
node --test mcp-jira/server.test.mjs mcp-jira/write-tools.test.mjs
node mcp-jira/check.mjs
```

O primeiro comando testa escritas contra mocks, sem alterar o Jira.
O segundo inicializa o MCP com escrita habilitada, lista as ferramentas e faz
somente consultas reais de permissoes, testes e ciclos. Nao cria dados de teste.
Em 25/09/2026, 15 testes locais passaram. Em 09/09/2026, CREATE_ISSUES,
EDIT_ISSUES e LINK_ISSUES foram confirmadas para ETICS e as consultas Zephyr
responderam com sucesso. Gravacao real no Zephyr ainda precisa ser verificada
durante o cadastro solicitado.

Os scripts locais `convert-recon-bdd.mjs` e `refine-recon-h01-04.mjs` executam
alteracoes em casos Zephyr especificos da reconciliacao. Eles ficam fora do
commit do servidor por meio de `.gitignore`; nao fazem parte da instalacao
compartilhada.

Depois de alterar o argumento ou codigo, reconecte o servidor MCP ou reabra o
Codex para substituir a instancia carregada e atualizar a lista de ferramentas.

## Referencias

- [Configuracao MCP do Codex](https://developers.openai.com/codex/mcp/)
- [API Jira Data Center](https://developer.atlassian.com/server/jira/platform/rest-apis/)
- [API publica Zephyr Scale Server v1](https://support.smartbear.com/zephyr-scale-server/api-docs/v1/)
- Os arquivos `zephyr-api.raml`, `*.schema` e `*.example` neste diretorio sao
  copias de referencia da documentacao publica SmartBear consultada em 09/09/2026;
  nao sao executados pelo MCP.
