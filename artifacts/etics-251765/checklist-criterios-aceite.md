# Critérios de aceite — ETICS-251765 / HU-38

História: [ETICS-251765](https://jira.cpqd.com.br/browse/ETICS-251765)

Documento: GP-Visao-CLARO-FlexibilizacaoProjeto (1).doc, versão 01.01.

Ciclo: **ETICS-C649 — CLARO | HU-38 | Corrigir inventário do Lance de Cabo Óptico | ETICS-251765**

27 casos BDD cadastrados, vinculados à história e conferidos. Execução: **Não executado**. Pasta: **sem pasta específica**. Estado dos casos: Draft; prioridade: Normal.

O checklist foi transferido para o campo Checklist da história; a lista foi removida da descrição. Itens desmarcados: o cadastro não representa execução nem aprovação do aceite.

- [ ] **CT01 / ETICS-T8194** — AMPLIAÇÃO / EXISTENTE — Todos os atributos não bloqueados permitem edição e persistem sem OT.
- [ ] **CT02 / ETICS-T8195** — AMPLIAÇÃO / PROJETADO — Campos adicionais persistem em Projetado/Modificação sem mudar situação ou vínculo original.
- [ ] **CT03 / ETICS-T8196** — BLOQUEIOS — Atributos bloqueados permanecem protegidos e inalterados.
- [ ] **CT04 / ETICS-T8197** — REGRESSÃO / ROTA — Edição válida permanece disponível e persiste sem OT.
- [ ] **CT05 / ETICS-T8198** — REGRESSÃO / COMPRIMENTO REAL TOTAL (M) — Edição válida permanece disponível e persiste sem OT.
- [ ] **CT06 / ETICS-T8199** — REGRESSÃO / PROPRIEDADE — Edição válida permanece disponível e persiste sem OT.
- [ ] **CT07 / ETICS-T8200** — REGRESSÃO / PROPRIETÁRIO — Edição válida permanece disponível e persiste sem OT.
- [ ] **CT08 / ETICS-T8201** — REGRESSÃO / TIPO DE REDE — Edição válida permanece disponível e persiste sem OT.
- [ ] **CT09 / ETICS-T8202** — REGRESSÃO / OBSERVAÇÕES — Edição válida permanece disponível e persiste sem OT.
- [ ] **CT10 / ETICS-T8203** — REGRESSÃO / CONFIGURAÇÃO DE COR — Edição válida permanece disponível e persiste sem OT.
- [ ] **CT11 / ETICS-T8204** — REGRESSÃO / TIPO — Edição válida permanece disponível e persiste sem OT.
- [ ] **CT12 / ETICS-T8205** — OT CORRENTE — A correção ignora tanto a OT do lance quanto outra OT corrente.
- [ ] **CT13 / ETICS-T8206** — CONSISTÊNCIA — Validações vigentes rejeitam valores inválidos e aceitam valores válidos.
- [ ] **CT14 / ETICS-T8207** — TIPO / CAPACIDADE IGUAL — Aceita troca e preserva fibras, contagens e conexões.
- [ ] **CT15 / ETICS-T8208** — TIPO / CAPACIDADE MAIOR — Cria apenas fibras faltantes e preserva a rede existente.
- [ ] **CT16 / ETICS-T8209** — TIPO / CAPACIDADE MENOR — Rejeita redução e mantém a rede original.
- [ ] **CT17 / ETICS-T8210** — HISTÓRICO — Correção rastreável por atributo, antes/depois, usuário e data/hora, sem OT.
- [ ] **CT18 / ETICS-T8211** — ATRIBUTOS DISTINTOS / IMPLANTAR OT — Rota corrigida permanece ABC; lote fica 456.
- [ ] **CT19 / ETICS-T8212** — ATRIBUTOS DISTINTOS / CANCELAR OT — Rota corrigida permanece ABC; lote fica 123.
- [ ] **CT20 / ETICS-T8213** — ATRIBUTOS DISTINTOS / DESFAZER ALTERAÇÕES DE OT — Rota corrigida permanece ABC; lote fica 123.
- [ ] **CT21 / ETICS-T8214** — MESMO ATRIBUTO / IMPLANTAR OT — Correção para 20,00 permanece e o histórico mantém 15,00 → 20,00.
- [ ] **CT22 / ETICS-T8215** — MESMO ATRIBUTO / CANCELAR OT — Correção para 20,00 permanece e o histórico mantém 15,00 → 20,00.
- [ ] **CT23 / ETICS-T8216** — MESMO ATRIBUTO / DESFAZER ALTERAÇÕES DE OT — Correção para 20,00 permanece e o histórico mantém 15,00 → 20,00.
- [ ] **CT24 / ETICS-T8217** — ORDEM / CORREÇÃO APÓS IMPLANTAÇÃO — Valor final 20,00 e sequência histórica preservada.
- [ ] **CT25 / ETICS-T8218** — ORDEM / OT POSTERIOR À CORREÇÃO — Alteração posterior implantada prevalece com valor final 15,00.
- [ ] **CT26 / ETICS-T8219** — PERFIL AUTORIZADO — Usuário do perfil CLARO consegue corrigir atributos elegíveis.
- [ ] **CT27 / ETICS-T8220** — PERFIL NÃO AUTORIZADO — Usuário fora do perfil não executa nem grava correção.

## Pré-condições e limites de cobertura

- A matriz completa de atributos editáveis/bloqueados e regras vigentes deve ser preparada na execução; o documento não enumera todos os campos ampliados.
- Nome/ID do perfil autorizado depende de definição/configuração CLARO.
- Para capacidade igual, seguem-se as regras detalhadas de §6.2.3 e §7.2 que permitem a troca, apesar da frase resumida do §7.2 mencionar somente aumento.
- Escopo limitado ao Lance de Cabo Óptico e às regressões de Corrigir inventário; não inclui TFO, Sobra, reposicionamento ou outras operações de fibras.

## Localização no Zephyr

Projeto ETICS → Zephyr Scale → Casos de teste → pesquisar ETICS-251765 → Roteiro de teste/Test Script.

Zephyr Scale → Ciclos/Test Cycles → pesquisar ETICS-C649 ou o nome do ciclo.


