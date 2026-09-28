# História 07 - Sincronizar grupo de Roteamento Estático do IM no JSON do Roteador

**Status:** draft - aguardando mapeamento IM -> Recon/GP e definição de identidade  
**Release:** 13.3.200  
**Dependência:** História 04 - Preparar o Recon para sincronização de campos JSON do IM para o GP  
**Componente principal:** `gp/recon`  
**Componentes relacionados:** EAI Webservices, OSS Network Resources, DBManager e metamodelo ENG

## História de usuário

Como operador do Recon,
quero que as rotas estáticas retornadas pelo IM sejam sincronizadas no documento JSON do Roteador,
para que a configuração de roteamento estático possa ser atualizada no GP junto aos demais objetos de configuração do equipamento.

## Contexto conhecido

O XML representativo contém o grupo `route-static` em `equipment/additionalInfo/group`. Cada `registry` representa uma rota de origem:

```xml
<group>
  <key>route-static</key>
  <registry>
    <attribute><key>dst</key><value>0.0.0.0 0.0.0.0</value></attribute>
    <attribute><key>gateway</key><value>172.16.200.1</value></attribute>
    <attribute><key>device</key><value>underlay</value></attribute>
    <attribute><key>distance</key><value>1</value></attribute>
    <attribute><key>priority</key><value>10</value></attribute>
    <attribute><key>blackhole</key><value>disable</value></attribute>
    <attribute><key>comment</key><value>Rota Default WAN1</value></attribute>
  </registry>
</group>
```

O formato JSON abaixo é somente o contrato de origem conhecido até agora. O de/para para os nomes finais do Recon/GP ainda não foi definido; portanto, não é permitido implementar a conversão, a allowlist ou a identidade com base neste documento sem atualizar esta história.

```json
{
  "objectType": "route-static",
  "attributes": {
    "dst": "0.0.0.0 0.0.0.0",
    "gateway": "172.16.200.1",
    "device": "underlay",
    "distance": "1",
    "priority": "10",
    "blackhole": "disable",
    "comment": "Rota Default WAN1"
  }
}
```

`group/label`, `attribute/label` e `registryId` não fazem parte do contrato JSON de origem, salvo decisão futura explícita.

## Decisões pendentes — bloqueadoras

1. Definir o `objectType` final do GP. O valor provisório `route-static` não deve ser considerado definitivo.
2. Definir o de/para de cada campo do IM para `attributes` do objeto final no GP.
3. Definir se cada `registry` será uma ocorrência independente `0..n` ou se as rotas comporão outro objeto.
4. Definir chave natural única e estável. O `registryId` é técnico e não pode ser usado automaticamente como chave de negócio.
5. Confirmar se uma rota é identificada por uma chave simples disponível no IM. Se a identidade exigir, por exemplo, `dst + gateway + device`, a infraestrutura atual de chave simples precisará de decisão/evolução antes da implementação.
6. Definir obrigatoriedade, tipo JSON final e tratamento de ausência para todos os campos.
7. Definir o campo de metamodelo GP que receberá o objeto final e a entrada correspondente em `recon-json-fields.json`.

## Regras provisórias

1. O adaptador deve localizar o grupo com `key` exatamente igual a `route-static`.
2. Cada `registry` é uma candidata a objeto de rota; a cardinalidade final permanece pendente.
3. Valores XML devem ser preservados como strings até que o contrato final determine conversão de tipo.
4. A rota não deve ser persistida em `HW_OBJECTS_JSON_EXT`, aplicada por `upsertAll` ou enviada ao `NestedRuleCaller` enquanto as decisões bloqueadoras não forem resolvidas.
5. Objetos `device`, `zona` e outros grupos permanecem independentes desta história.

## Atualização requerida antes de implementar

Quando o de/para IM -> Recon/GP estiver disponível, atualizar esta história com:

- tabela completa `campo XML -> atributo JSON final`;
- exemplo JSON final aprovado;
- cardinalidade e chave de negócio;
- entrada em `im-json-object-mappings.json`, se houver renomeação;
- entrada do `objectType` final em `object-key-definitions.json`, se for multivalorado;
- entrada do `objectType` final em `recon-json-fields.json`;
- critérios de aceite, fixtures e testes de insert/update/duplicidade;
- decisão explícita caso seja necessária chave composta ou outro suporte do artefato compartilhado.

## Critérios para sair de draft

1. O de/para de todos os sete campos está aprovado pelo domínio Recon/GP.
2. O `objectType` final, a cardinalidade e a identidade estão aprovados.
3. Está definido se a infraestrutura atual suporta a identidade escolhida ou se há história prévia para sua evolução.
4. O campo JSON de destino no Roteador está definido.
5. O XML representativo e o JSON final foram revisados pelo responsável do IM e pelo responsável do GP.

## Referências

- `gp/docs/dev/13.3.200/recon/04-integracao-recon-campos-json-im-gp.md`
- `gp/docs/dev/13.3.200/recon/03-artefato-compartilhado-upsert-documento-json.md`
- `gp/docs/dev/13.3.200/recon/05-sincronizacao-json-im-gp-zona.md`
- `gp/docs/dev/13.3.200/recon/06-sincronizacao-json-im-gp-device-ha.md`
- `/l/disk0/fluis/Downloads/getEquipmentResponse-massa-completa.xml` (fonte de exemplo; comentários XML não são requisitos)

## Dev Agent Record

### Completion Notes

- História criada em modo de descoberta: o XML e o JSON de origem estão documentados, mas a implementação permanece bloqueada pela definição de mapeamento e identidade.

### Change Log

- 2026-08-31: criada a história provisória para o grupo `route-static`.