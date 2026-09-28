---
name: zephyr-cenarios-gherkin
description: "Criar, cadastrar, revisar e converter cenários de teste em Gherkin/BDD no Zephyr Scale, com rastreabilidade às histórias Jira, prevenção de duplicidades e conferência após publicação. Use também para retomar cadastros e converter casos existentes; não se aplica à execução de testes ou à criação de automação Playwright."
---

# Cenários Gherkin no Zephyr

Padronizar cenários com conteúdo em português, critérios verificáveis e roteiro BDD/Gherkin no Zephyr. Respeitar formato, produto e escopo explicitamente escolhidos pelo usuário.

## Interpretar o pedido e recuperar o contexto

- Distinguir elaboração local, criação no Zephyr e conversão de casos existentes. Se a conversa trata de casos já cadastrados e o usuário pede conversão, atualizar esses registros; um arquivo `.feature` local não conclui o pedido.
- A instrução para cadastrar ou converter já autoriza a operação correspondente. Não pedir confirmação redundante. Um pedido apenas para descrever cenários não autoriza publicação; usar o contexto para resolver o destino ou esclarecer somente o que faltar.
- Ao retomar após reinício, consultar ferramentas MCP disponíveis e executar uma leitura real. Recuperar o mapa de IDs e o estado local, mas reconciliá-los com o Zephyr antes de escrever.
- Obter do contexto projeto, histórias, escopo funcional, ciclo e pasta de destino. Não reutilizar chaves, quantidade de casos, cliente ou ciclo de outro trabalho. Na integração CPQD, ETICS é o projeto padrão somente quando a configuração e o contexto sustentarem isso.
- Preferir o MCP do Jira/Zephyr. Ler [compatibilidade CPQD](references/zephyr-scale-cpqd.md) ao usar essa instalação, investigar limitações do MCP ou publicar/converter BDD via API.

## Elaborar cenários

Usar histórias, critérios de aceitação, comentários e documentos fornecidos como fontes. Relacionar cada cenário à história que fundamenta seu comportamento. Identificar lacunas de contrato, fixtures e regras como pendências, sem inventar resultados nem declarar cobertura integral de um documento a partir de apenas algumas histórias.

Para cada caso, manter identificador estável, título que descreva o comportamento, história, fonte, contexto/pré-condições, dados, ações, resultados esperados e pendências relevantes. Prioridade proposta e prioridade efetivamente cadastrada são informações diferentes; não converter uma proposta em valor do Zephyr sem conferir os valores aceitos.

Redigir o roteiro com:

- `Given`: contexto e estado inicial necessários.
- `And`: dados ou condições adicionais, com valores concretos quando a fonte permitir.
- `When`: ação observável do usuário, sistema ou componente.
- `Then`: efeito esperado verificável; evitar apenas “sucesso” ou “funcionou”.

Usar texto em português e keywords aceitas pelo Zephyr de destino. Preferir um comportamento por cenário. Ao converter um caso existente, preservar todas as ações, verificações, dados e condições relevantes; se necessário, manter pares adicionais `When`/`Then` dentro do mesmo caso. Não dividir registros nem criar outros casos sem necessidade indicada pelo pedido. Preservar caixa de identificadores técnicos, como o atributo `A`, e nomes canônicos.

Exemplo de corpo BDD para um caso que ignora um atributo:

```gherkin
Given um roteador pareado e consistente fisicamente
And o atributo A está configurado como 0 — Ignorar
And A possui valor_GP no GP e valor_IM no IM
When executar a reconciliação e abrir o detalhamento
Then a diferença no atributo A não gera divergência
When acionar Atualizar inventário e consultar o roteador
Then A permanece com valor_GP
```

O título do caso identifica o cenário no Zephyr. Um `.feature` local pode usar `# language: pt`, `Funcionalidade` e `Cenário`; esse documento completo não é necessariamente um payload aceito pelo editor BDD remoto.

## Criar ou converter no Zephyr

1. Conferir casos e ciclo existentes antes de criar. Usar ID estável, nome, história e contexto para detectar duplicatas; tratar paginação e não considerar a primeira página como busca completa. Se houver múltiplos candidatos, esclarecer a identidade antes de alterar.
2. Na criação, publicar BDD diretamente quando suportado. Se a integração exigir primeiro criar o caso e depois converter seu roteiro, executar ambas as operações e só considerar concluído após verificar `testScript.type = BDD`.
3. Na conversão, ler e salvar uma cópia do registro remoto anterior. Atualizar somente o roteiro dos casos solicitados. Preservar chaves, nomes, histórias, labels, prioridades, pré-condições, objetivos, pastas e associação ao ciclo, salvo alteração pedida.
4. Se o schema MCP não expuser BDD, conferir a capacidade real do servidor. Adaptar uma integração local autorizada ou usar uma API/navegador disponível; não passar texto Gherkin como passos tradicionais e anunciar conversão BDD. Não exigir reinício do Codex se houver alternativa autorizada funcional.
5. Em lote, validar primeiro um caso e relê-lo antes de continuar. Registrar progresso por chave. Diante de timeout, consultar o estado remoto antes de qualquer repetição; se já corresponde ao desejado, marcar como concluído. Em erro de validação, corrigir a causa demonstrada. Parar as escritas afetadas quando o estado estiver ambíguo ou a falha persistir sem correção fundamentada.
6. Associar ao ciclo solicitado e às histórias pertinentes. Não executar os testes nem registrar aprovação de execução durante cadastro/conversão. Não inferir versão, datas ou ambiente a partir de branch ou cliente.

## Conferir e entregar

Reler todos os registros alterados. Conferir tipo BDD, texto integral, quantidade, chaves e vínculos. Comparar os campos preservados com o backup; listas sem ordem semântica podem ser comparadas como conjuntos. Quando conferir passos anteriores, ordenar por `index`, pois a API pode retorná-los fora de ordem.

Conferir separadamente os membros do ciclo e os estados de execução. Manter “Não executado” em novos cadastros; não zerar resultados anteriores ao converter um caso com histórico.

Salvar no workspace um mapa compacto de ID local → chave Zephyr → história → ciclo, progresso e evidências de releitura. Manter backup anterior à conversão. Usar JSON UTF-8 e confirmar a estrutura ao serializar, especialmente arrays via PowerShell. Não guardar tokens ou credenciais nesses arquivos.

Na resposta, informar o que foi efetivamente publicado ou convertido, quantidade, chaves, projeto, nome/chave do ciclo e pasta exata. Se estiver na raiz, dizer “sem pasta específica”. Indicar **Zephyr Scale → Casos de teste → Roteiro de teste/Test Script** e **Ciclos/Test Cycles**, usando os rótulos disponíveis. Fornecer links reais quando confirmados, sem inventar URLs de casos Zephyr como se fossem issues Jira. Distinguir evidências locais de registros remotos e mencionar pendências que impeçam execução.
