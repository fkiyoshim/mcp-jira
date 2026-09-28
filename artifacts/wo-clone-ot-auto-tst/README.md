# Clonagem de cadastros da OT `OT_AUTO_TST`

Origem: `WO-TRANSFER-04` (`CR_PROJECT.ID = 12128`). Destino na mesma base:
`OT_AUTO_TST` (`CR_PROJECT.ID = 12771`). Ponto central em SRID 4326:
longitude `-38.44606614`, latitude `-12.98624034`.

## Estado confirmado em 28/09/2026

O script `clonar_objetos_commit.sql` foi executado com `COMMIT` e terminou sem
erro. Uma segunda sessão Oracle confirmou:

| Registro | Quantidade |
| --- | ---: |
| `PROJECT`, `CR_PROJECT`, `PROJECT_VERSION`, `CR_PROJECT_F` | 1 cada |
| `CR_PROJECT_HIST` | 1 |
| `CR_PROJECTED_OBJECT` | 378 |
| `VERSION_CONTENT` | 891 |
| Geometrias de objetos validadas | 103 |
| Linhas de conexão excluídas | 0 na nova versão |
| Símbolos `VWS_*` atualizados depois da clonagem | 37 |

Foram copiados objetos das 38 tabelas versionadas selecionadas, entre eles
sites, postes, caixas, equipamentos, portas, cabos, fibras e trechos. Os IDs
dos objetos e suas referências declaradas e conhecidas sem FK foram remapeados.
O ensaio final detectou zero referências aos IDs versionados da OT de origem
nas colunas auditadas. O centro do polígono da nova OT foi confirmado no ponto
pedido. A OT foi gravada com o estado `8` da origem, uma entrada de histórico
com esse estado e datas de criação/início atualizadas para 28/09/2026.

## Limites da cópia

Nenhum vínculo de conexão foi clonado: as tabelas `IP_NE_CONNECTION`,
`CR_EDGE`, `CR_NODE`, `CR_JUMPER`, `NET_LINE_ROUTE` e
`CR_AVAILABLE_TR_UNIT_EQ` ficaram sem linhas da nova OT. Também foram
excluídas 145 unidades de transmissão que representavam conexões.

A origem contém 277 entradas em `VERSION_CONTENT` sem registro na tabela de
objeto correspondente; 49 delas também constam em `CR_PROJECTED_OBJECT`.
Esses apontamentos órfãos não foram clonados. Entre os 49 estão 47 fibras,
1 `IP_NE_TR_MEAN` e 1 `IP_NE_TR_UNIT`. Por isso a nova OT contém 378 dos
557 apontamentos projetados da origem: 130 são tipos de conexão e 49 não
possuem registro-fonte. A verificação pela interface do GP ainda não foi
realizada.

## Correção da simbologia

Os cadastros `FEATURE` e as geometrias existiam, mas as tabelas de cache
espacial `VWS_*` não tinham linhas para os novos FIDs. As views `UWS_*`
geravam 37 símbolos para a nova OT. `SIMBCACHETOOLS.REFRESH_VWS_ROWS` foi
testada com `ROLLBACK` e depois executada com `COMMIT` apenas para esses FIDs.
Uma segunda sessão confirmou as quantidades em `VWS_*`: `POLE` 6,
`MANHOLE` 3, `OPT_CABLE` 5, `ROUTE` 9, `DUCT` 4, `OPT_COTO` 1,
`OTH_BLG` 1 e `OP_TERMINAL` 8. Dois `FEATURE` do tipo `percurso` não aparecem
nem em `UWS_ROUTE` na OT original, por isso não geram símbolos nesta cópia.
A interface do GP não foi acessível pelo navegador desta sessão, então a
conferência visual continua pendente.

## Diagnóstico adicional: contorno e objetos ainda não aparecem

O usuário confirmou que nem o contorno da OT aparece no mapa. A geometria do
contorno existe em `CR_PROJECT_F` e `VWS_WORK_ORDER` (`FID = 7408253`), mas
`FEATURE_CELL` não contém nenhuma linha para esse FID nem para os FIDs dos
símbolos clonados. A OT de origem tem linhas nessa tabela para contorno e
objetos. `FEATURE_CELL` é o índice de células usado pelo renderizador do GP;
copiar as células antigas não serve porque as coordenadas mudaram.

O pacote local do dataloader contém `CacheGenerator.updateCache`, que pode
gerar `FEATURE_CELL` a partir de uma lista de `EntityKey`. Foi feito um ensaio
apenas com o FID do contorno. Ele terminou sem gerar linha, pois o processo
local não dispõe da configuração do servidor GP (JNDI, `config-ds.xml`,
cache de planos e definição efetiva das camadas). O gerador também retorna
mensagem de sucesso quando nenhum elemento foi efetivamente gerado, por isso
é necessário conferir as linhas em `FEATURE_CELL` após qualquer tentativa.

O menu de administração do GP expõe `Regerar Cache Espacial` no código da
suíte antiga. Não foi acionado: sem acesso à interface e sem confirmar o
escopo, ele pode reconstruir o cache de toda a base. A correção requer um
mecanismo do servidor GP que aceite os FIDs desta OT, ou acesso à configuração
do renderizador para executar uma geração parcial. Ainda não houve
comprovação visual na aplicação.

## Scripts

- `ensaio_ot.sql`: primeiro ensaio somente com cabeçalho e polígono; faz
  `ROLLBACK`.
- `ensaio_objetos.sql`: clonagem dos cadastros com todas as verificações; faz
  `ROLLBACK`.
- `clonar_objetos_commit.sql`: mesmo conteúdo do ensaio de objetos, com
  `COMMIT` após as verificações. **Já foi executado**. Protegido por uma
  verificação que interrompe a execução se `OT_AUTO_TST` existir.
- `ensaio_simbologia.sql`: atualização direcionada do cache espacial, com
  `ROLLBACK`.
- `atualizar_simbologia_commit.sql`: atualização direcionada e validada do
  cache espacial, com `COMMIT`. **Já foi executado**.

Os scripts não contêm senha nem dados de conexão.
