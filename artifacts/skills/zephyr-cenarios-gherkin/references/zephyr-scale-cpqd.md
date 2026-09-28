# Compatibilidade observada: Zephyr Scale CPQD

Esta referência registra comportamento observado em setembro de 2026. Conferir o schema disponível e a instalação atual; não aplicar automaticamente ao Zephyr Cloud, Squad ou outro servidor.

## API e MCP

A integração `cpqd_jira` usa Zephyr Scale Server, REST `/rest/atm/1.0`, e pode expor operações de consulta, criação e atualização. A presença das ferramentas não comprova autenticação nem permissão de escrita: validar por leitura e pelo resultado das operações autorizadas.

O contrato de atualização de caso aceita:

```http
PUT /rest/atm/1.0/testcase/{key}
Content-Type: application/json
```

```json
{
  "testScript": {
    "type": "BDD",
    "text": "Given um estado inicial\nWhen executar uma ação\nThen observar o resultado esperado"
  }
}
```

Somente os campos enviados são atualizados. Para converter, enviar apenas `testScript`. Evitar enviar `issueLinks` ou passos antigos: campos de coleção substituem conjuntos, e passos omitidos em um roteiro STEP_BY_STEP podem ser removidos.

O parâmetro `steps` da ferramenta MCP original gera `STEP_BY_STEP`, mesmo que a descrição contenha Given/When/Then. O suporte local acrescentado nesta conversa foi `bdd_script` em `zephyr_update_test`, mapeado para `{type: "BDD", text: ...}` e mutuamente exclusivo com `steps`. Esse parâmetro é uma adaptação local, não um campo da API Zephyr nem uma garantia de presença em sessões futuras.

Quando houver servidor local editável, uma extensão deve manter allowlist de projetos, controles de escrita e credenciais no ambiente. Testar o payload BDD, rejeição de formatos conflitantes e preservação dos demais campos. Um processo MCP já carregado pode continuar com schema antigo; se necessário, iniciar uma instância temporária do mesmo servidor atualizado, usando sua autenticação e controles existentes. Não copiar tokens para argumentos, arquivos ou logs e não usar outro canal para contornar rejeição de aprovação.

## Formato BDD aceito

Foi aceito um corpo contendo apenas passos `Given`, `And`, `When`, `Then`, com o conteúdo em português. O envio de um arquivo completo contendo cabeçalho de idioma, tags, `Funcionalidade` e `Cenário` retornou HTTP 400 `Invalid BDD Script`; a observação não isola qual desses elementos causou a rejeição. Usar o corpo validado como padrão nessa instalação, mantendo título, fonte e pendências nos campos adequados do caso.

Não testar variações às cegas no lote. Após erro, reler o caso e confirmar seu estado; adaptar um caso à forma documentada/observada e só avançar após releitura bem-sucedida.

## Busca, chaves e conferência

- O MCP local limitou `max_results` a 100. Usar paginação com `start_at`; conferir término por tamanho de página e verificar que páginas avançam.
- A busca de casos por nome exato funcionou. A busca de ciclos com `AND name = ...` foi rejeitada: o servidor aceitou apenas `projectKey` e `folder` na query de ciclos. Alternativa validada: consultar pelo projeto, paginar e filtrar o nome no cliente.
- Ciclos dessa instalação usam chaves `PROJETO-Cn`. Uma versão do MCP validava apenas `Rn` em `zephyr_get_cycle`, incompatível com o retorno real. Usar busca paginada para reler ou corrigir a validação com base no contrato; nunca alterar artificialmente a chave retornada.
- A ordem dos passos retornados pode variar; comparar por `index`. Para BDD, comparar o campo `text` integral e `type`.
- Casos/ciclos criados sem `folder` ficaram sem pasta específica. Informar isso ao usuário; não atribuir uma pasta imaginária com base em cliente ou história.
- “Draft” é estado do caso; “Not Executed” é estado de execução no ciclo. Não confundir prioridade proposta com a prioridade real “Normal” aplicada por padrão na instalação observada.

## Referências oficiais

- [API Zephyr Scale Server v1](https://support.smartbear.com/zephyr-scale-server/api-docs/v1/): contrato de `testScript` para criar/atualizar casos.
- [Comparação de recursos Zephyr](https://support.smartbear.com/zephyr/docs/en/zephyr-squad-to-zephyr-migration-guide/feature-comparison-squad-scale.html): distingue suporte a passos Gherkin de criação de arquivos feature completos. Não substituir a validação da instalação por uma conclusão genérica dessa comparação.

Se o workspace disponibilizar `mcp-jira/zephyr-api.raml`, `testcase.schema`, `write-tools.mjs` e seus testes, consultá-los seletivamente para confirmar a implementação. Scripts antigos de lote podem fixar casos, ciclo e quantidade de outra tarefa: não executá-los sem adaptar e revisar os alvos atuais.
