# História 06 - Sincronizar atributos HA do IM no objeto JSON Device do Roteador

**Status:** ready-for-dev
**Release:** 13.3.200
**Dependência:** História 04 - Preparar o Recon para sincronização de campos JSON do IM para o GP
**Compatibilidade:** História 05 - Sincronizar o grupo Zona do IM no documento JSON do Roteador
**Componente principal:** `gp/recon`
**Componentes relacionados:** EAI Webservices, OSS Network Resources, DBManager e metamodelo ENG

## História de usuário

Como operador do Recon,
quero que os atributos HA devolvidos pelo IM sejam sincronizados como a configuração `device` do Roteador quando eu executar “Atualizar inventário”,
para manter grupo HA, portas de heartbeat e interfaces monitoradas no mesmo documento JSON que contém as zonas do equipamento.

## Contexto e escopo

O XML representativo retorna os atributos HA diretamente em `equipment/additionalInfo`, fora de qualquer `group`:

```xml
<attribute><key>group-name</key><value>SPO-HA-121</value></attribute>
<attribute><key>hbdev-1</key><value>port1</value></attribute>
<attribute><key>hbdev-2</key><value>port2</value></attribute>
<attribute><key>monitor</key><value>x3</value><value>x4</value></attribute>
```

Esta história trata somente esses quatro atributos. Grupos como `zona`, rota estática, BGP, OSPF, RIP, atributos de porta e qualquer outro atributo de `additionalInfo` não são convertidos para `device` nesta entrega.

`device` e `zona` compartilham o mesmo documento JSON no campo `HW_OBJECTS_JSON`. Isso não cria dependência de ordem entre as histórias: ambas reutilizam a infraestrutura da História 04; o cenário integrado com zonas requer a História 05 disponível.

## Contrato JSON

O resultado é um fragmento singleton `device` dentro do array canônico. Não usar wrapper por tipo.

```json
{
  "objectType": "device",
  "attributes": {
    "device-group": "SPO-HA-121",
    "ha-port-1": "port1",
    "ha-port-2": "port2",
    "ha-monitor-port-range": ["x3", "x4"]
  }
}
```

| Origem XML | Campo JSON de destino | Cardinalidade |
|---|---|---:|
| `additionalInfo/attribute[key=group-name]/value` | `attributes.device-group` | 1 |
| `additionalInfo/attribute[key=hbdev-1]/value` | `attributes.ha-port-1` | 1 |
| `additionalInfo/attribute[key=hbdev-2]/value` | `attributes.ha-port-2` | 1 |
| `additionalInfo/attribute[key=monitor]/value[*]` | `attributes.ha-monitor-port-range` | 1..n, array |

`attribute/label` não é transportado. Valores são preservados como recebidos: não aplicar `trim`, conversão de caixa, deduplicação ou concatenação. O atributo `monitor` é sempre array JSON, inclusive quando houver somente um valor.

## Documento JSON integrado

Quando HA e zonas estiverem presentes, o CLOB intermediário e o valor final do campo do Roteador seguem este formato:

```json
[
  {
    "objectType": "device",
    "attributes": {
      "device-group": "SPO-HA-121",
      "ha-port-1": "port1",
      "ha-port-2": "port2",
      "ha-monitor-port-range": ["x3", "x4"]
    }
  },
  {
    "objectType": "zona",
    "attributes": {
      "zone-name": "underlay",
      "zone-interface": ["wan1"]
    }
  },
  {
    "objectType": "zona",
    "attributes": {
      "zone-name": "overlay",
      "zone-interface": ["hub_spk1.2.2"]
    }
  }
]
```

## Regras de negócio

1. O `objectType` de destino é exatamente `device`; ele é singleton e, portanto, não recebe entrada em `object-key-definitions.json`.
2. Os quatro atributos HA são obrigatórios quando o equipamento possuir qualquer atributo HA selecionado. Ausência, valor vazio ou mais de um valor em `group-name`, `hbdev-1` ou `hbdev-2` invalida o lote.
3. `monitor` deve possuir pelo menos um valor não vazio; todos os valores são mantidos em `ha-monitor-port-range`, na ordem de origem.
4. Se nenhum dos quatro atributos HA existir, esta história não gera fragmento `device`.
5. Se apenas parte dos atributos HA estiver presente, o lote falha. Não emitir `device` parcial, pois um update substitui o objeto inteiro e poderia apagar configurações existentes.
6. A origem técnica é `equipment-ha`, definida em `im-json-object-mappings.json`; ela não é um `objectType` persistido.
7. Campos HA sem regra de de/para e colisões de dois campos para o mesmo atributo de destino falham, sem descarte silencioso.
8. Futuras fontes que também componham `device` devem acrescentar atributos ao mesmo fragmento antes do upsert. Não gerar dois objetos `device` no mesmo lote.
9. O merge ocorre apenas em “Atualizar inventário”. Em sucesso, `NestedRuleCaller` é chamado uma vez por equipamento; em falha, zero vezes.
10. O objeto `device` existente é substituído por completo; objetos `zona` e outros tipos do documento atual não recebidos nesta execução permanecem.

## Alterações técnicas

### 1. Configuração de de/para

Criar ou completar `gp/recon/fontes/components/core/src/main/resources/jsondocument/im-json-object-mappings.json` com:

```json
{
  "schemaVersion": 1,
  "sourceObjects": {
    "equipment-ha": {
      "targetObjectType": "device",
      "attributeMappings": {
        "group-name": { "target": "device-group", "cardinality": "single" },
        "hbdev-1": { "target": "ha-port-1", "cardinality": "single" },
        "hbdev-2": { "target": "ha-port-2", "cardinality": "single" },
        "monitor": { "target": "ha-monitor-port-range", "cardinality": "array" }
      }
    }
  }
}
```

Adicionar também o destino do objeto final em `recon-json-fields.json`:

```json
{
  "device": "HW_OBJECTS_JSON"
}
```

Não adicionar `device` a `object-key-definitions.json`: a ausência de chave o define como singleton.

### 2. WSDL, JAXB e adaptador

- Evoluir o WSDL para expor os atributos de `EquipmentData.additionalInfo` com chave, label e lista de valores; regenerar JAXB sem editar fontes gerados manualmente.
- No adaptador da História 04, selecionar os quatro atributos HA, aplicar o mapa `equipment-ha` e construir diretamente o fragmento final `device`.
- Validar a cardinalidade antes de persistir `HW_OBJECTS_JSON_EXT`.
- Não produzir um objeto intermediário `ha`, não serializar `label` e não fazer parse do XML bruto fora do cliente JAXB.

### 3. Transporte e atualização

- Reutilizar `Equipment` -> `ReconEquipment` -> `ReconEqpt.HW_OBJECTS_JSON_EXT` e o coordenador JSON definidos na História 04.
- Agrupar `device` e `zona` pelo mesmo destino `HW_OBJECTS_JSON` e executar um `upsertAll` para o lote daquele campo.
- Passar o JSON final como valor bruto no mapa do `NestedRuleCaller`; não usar `ObjectUpdate.value` nem `split(": ")`.

## Critérios de aceitação

1. Dado o XML representativo, são gerados `objectType: "device"`, `device-group: "SPO-HA-121"`, `ha-port-1: "port1"`, `ha-port-2: "port2"` e `ha-monitor-port-range: ["x3", "x4"]`.
2. Dado um único valor de `monitor`, o atributo de destino continua sendo array com um item; dados vários valores, todos permanecem ordenados.
3. Dado qualquer atributo HA obrigatório ausente, vazio ou multivalorado indevidamente, ou `monitor` ausente/vazio, não há persistência parcial nem chamada ao `NestedRuleCaller`.
4. Dada ausência completa dos quatro atributos HA, nenhum fragmento `device` é produzido e o XML legado continua processável.
5. Dado `device` existente, o objeto inteiro é atualizado; dado documento atual nulo/vazio, `device` é inserido; objetos de outros tipos não recebidos permanecem.
6. Dado o XML que contém HA e as zonas da História 05, o documento final contém um `device` e as duas zonas no mesmo array JSON.
7. `label`, XML completo, JSON completo e valores HA não são registrados em logs.
8. `device` é aceito pela allowlist para `HW_OBJECTS_JSON`, mas não possui configuração artificial de chave.
9. WSDL/JAXB, configuração de mapeamento, allowlist, fixtures e testes unitários/integrados são entregues juntos.

## Tarefas técnicas

- [ ] Modelar os atributos de `EquipmentData.additionalInfo` no WSDL e regenerar JAXB.
- [ ] Criar o carregador e a validação de `im-json-object-mappings.json` previstos na História 04.
- [ ] Adicionar o mapa `equipment-ha -> device` e a entrada `device -> HW_OBJECTS_JSON` na allowlist.
- [ ] Implementar a seleção/validação dos atributos HA e a montagem de um único fragmento `device`.
- [ ] Transportar o fragmento pelo CLOB e integrar ao coordenador de atualização da História 04.
- [ ] Criar fixtures para HA válido, `monitor` multivalorado, HA ausente, HA parcial e cardinalidade inválida.
- [ ] Cobrir upsert singleton, lote combinado `device` + `zona`, atomicidade e chamada única ao `NestedRuleCaller`.

## Referências

- `gp/docs/dev/13.3.200/recon/04-integracao-recon-campos-json-im-gp.md`
- `gp/docs/dev/13.3.200/recon/05-sincronizacao-json-im-gp-zona.md`
- `gp/docs/dev/13.3.200/recon/03-artefato-compartilhado-upsert-documento-json.md`
- `gp/eai/webservices/contracts/src/main/wsdl/ReconServices.wsdl`
- `gp/recon/fontes/components/core/src/main/java/br/com/cpqd/etics/recon/core/rule/RecoverIMEquipments.java`
- `gp/recon/fontes/components/core/src/main/resources/jsondocument/object-key-definitions.json`
- `/l/disk0/fluis/Downloads/getEquipmentResponse-massa-completa.xml` (fixture de referência; seus comentários não são requisitos)

## Dev Agent Record

### Completion Notes

- História criada para o contrato final `device`; `ha` é somente uma origem técnica e não um objeto persistido.
- A validação de completude evita atualização destrutiva de singleton com um objeto HA parcial.

### Change Log

- 2026-08-31: criada a história para sincronização de atributos HA no objeto `device`.