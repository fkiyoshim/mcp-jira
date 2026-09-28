# H01 — Correção após esclarecimentos do desenvolvedor

História: [ETICS-252410](https://jira.cpqd.com.br/browse/ETICS-252410). Revisão de 10/09/2026.

## Fontes e interpretação

O usuário trouxe o relato de Francisco Guarnieri Bueno: atributos em 0 não participam do match, mas são atualizados pelo fluxo existente; a H01 não criou colunas; verificações internas não podem ser executadas integralmente pela interface.

O [ETICS-175367](https://jira.cpqd.com.br/browse/ETICS-175367) especifica ausência de match e apresentação informativa para NÃO/0. Não especifica a atualização de inventário. O comentário de 28/08/2026 da H01 exige preservar 0/1 e, para 2, não gerar divergência, não aparecer na árvore e atualizar com o valor IM.

Por isso, os testes não afirmam mais que 0 nunca atualiza. Eles comparam o resultado da versão alvo com uma referência anterior à H01 usando a mesma massa. O comportamento observado de atualizar 0 não foi promovido a uma regra geral de produto: o próprio desenvolvedor levantou a hipótese de efeito indesejado. A decisão funcional permanece pendente.

## Alterações publicadas

| Caso | Correção |
|---|---|
| ETICS-T8036 | Modo 0 sem match, com apresentação informativa; atualização comparada ao comportamento registrado na versão de referência. |
| ETICS-T8039 | Cenário misto 0/1/2 corrigido; retirado o resultado obrigatório de manter A em valor_GP após atualizar. |
| ETICS-T8088 | Deprecated / não aplicável à H01: pressupunha criação de colunas. |
| ETICS-T8089 | Deprecated / não aplicável à H01: pressupunha patch para novas colunas. |
| ETICS-T8090 | Matriz de atributos e persistência existentes; retiradas as premissas de novos atributos/colunas; execução técnica. |
| ETICS-T8091 | Validação técnica do fluxo real do modo 2; retirado o controle negativo não fundamentado para modo 0. |
| ETICS-T8092 | Harness e mapeamentos reais de atributos existentes; variantes não implementadas explicitamente não aplicáveis. |

Os demais sete casos da H01 foram preservados. ETICS-T8093 já estava classificado como desenvolvimento e continua exigindo harness do comparador.

Os casos técnicos ETICS-T8090–T8093 não são roteiros de execução integral pela aplicação. Preparação da massa IM para testes sistêmicos também pode exigir apoio técnico.

## Ciclos e histórico

- ETICS-C647 — CLARO | RECON H01 | Testes sistêmicos | Revisão MD: oito membros preservados.
- ETICS-C648 — CLARO | RECON H01 | Desenvolvimento | Revisão MD: seis membros históricos preservados, dos quais T8088/T8089 estão descontinuados e não devem ser executados para H01.
- ETICS-C646 — CLARO | RECON lógico | H01–H08 | Visão 01.01: 50 membros preservados.

Não foram alterados resultados de execução, labels de equipe, vínculos, prioridades ou pastas. Casos e ciclos citados estão sem pasta específica. Nenhum teste de produto foi executado.

## Evidências

- h01-feedback-before.json: registros anteriores e ciclos.
- h01-feedback-plan.json: campos alterados.
- h01-feedback-verification.json: releitura após cada edição.
- h02-h08-md-final-verification.json: conferência consolidada posterior.

Esta revisão substitui as conclusões anteriores sobre criação de colunas e bloqueio de atualização para modo 0. Os arquivos anteriores permanecem como histórico.
