# História 08 - Sincronizar Roteamento Dinâmico do IM no JSON do Roteador

**Status:** draft - aguardando mapeamento IM -> Recon/GP e definição de identidade  
**Release:** 13.3.200  
**Dependência:** História 04 - Preparar o Recon para sincronização de campos JSON do IM para o GP  
**Componente principal:** `gp/recon`  
**Componentes relacionados:** EAI Webservices, OSS Network Resources, DBManager e metamodelo ENG

## História de usuário

Como operador do Recon,
quero que as configurações de roteamento dinâmico retornadas pelo IM sejam sincronizadas no documento JSON do Roteador,
para que os protocolos BGP, OSPF e RIP possam ser atualizados no GP junto aos demais objetos de configuração do equipamento.

## Contexto e escopo

O roteamento dinâmico é uma especialização funcional composta pelos grupos XML `bgp`, `ospf` e `rip`, todos sob `equipment/additionalInfo/group`. Esta história documenta os contratos JSON de origem conhecidos para os três protocolos.

Ainda não há de/para aprovado entre os campos do IM e os campos finais Recon/GP. Portanto, os nomes e `objectType`s exibidos abaixo são provisórios: não implementar adaptador, allowlist, chave de upsert ou persistência desses objetos até que as decisões pendentes sejam resolvidas e esta história seja atualizada.

Fora do escopo: HA/`device`, `zona`, roteamento estático, atributos de porta, DHCP e demais grupos do `getEquipmentResponse`.

## Contratos JSON de origem conhecidos

### BGP

```json
{
  "objectType": "bgp",
  "attributes": {
    "bgp-as": "65000",
    "bgp-router-id": "169.254.159.254",
    "ibgp-multipath": "enable",
    "bgp-redistribute-connected-status": "disable",
    "bgp-redistribute-rip-status": "disable",
    "bgp-redistribute-ospf-status": "disable",
    "bgp-redistribute-static-status": "disable",
    "bgp-redistribute-isis-status": "disable",
    "bgp-neighbor": [
      {
        "bgp-neighbor-ip": "200.231.82.213",
        "bgp-neighbor-as": "4230",
        "bgp-neighbor-update-source": "loopback0",
        "bgp-neighbor-holdtime-timer": "180",
        "bgp-neighbor-keep-alive-timer": "60",
        "bgp-neighbor-weight": "100",
        "bgp-neighbor-route-map-in": "RM_MPLS_IN",
        "bgp-neighbor-route-map-out": "RM_MPLS_OUT",
        "bgp-neighbor-prefix-list-in": "PL_IN",
        "bgp-neighbor-prefix-list-out": "PL_OUT",
        "bgp-neighbor-maximum-prefix": "1000",
        "bgp-neighbor-graceful-restart": "enable",
        "bgp-neighbor-remote-as": "4230"
      }
    ],
    "bgp-neighbor-group": [
      {
        "bgp-neighbor-group-name": "SPOKES",
        "bgp-neighbor-group-as": "65000",
        "bgp-neighbor-group-update-source": "loopback0",
        "bgp-neighbor-group-holdtime-timer": "180",
        "bgp-neighbor-group-keep-alive-timer": "60",
        "bgp-neighbor-group-weight": "100",
        "bgp-neighbor-group-route-map-in": "RM_SPOKES_IN",
        "bgp-neighbor-group-route-map-out": "RM_SPOKES_OUT",
        "bgp-neighbor-group-prefix-list-in": "PL_SPOKES_IN",
        "bgp-neighbor-group-prefix-list-out": "PL_SPOKES_OUT",
        "bgp-neighbor-group-max-prefix": "500",
        "bgp-neighbor-group-graceful-restart": "enable",
        "bgp-neighbor-group-remote-as": "65000"
      }
    ]
  }
}
```

### OSPF

```json
{
  "objectType": "ospf",
  "attributes": {
    "ospf-area-id": "0.0.0.0",
    "ospf-router-id": "10.255.0.1",
    "ospf-hello-interval": "10",
    "ospf-dead-interval": "40",
    "ospf-retransmit-interval": "5",
    "ospf-priority": "10",
    "ospf-cost": "100",
    "ospf-authentication": "text",
    "ospf-authentication-key": "ENC_MD5_KEY",
    "ospf-passive-interface-name": "internal3",
    "ospf-redistribute-connected-status": "disable",
    "ospf-redistribute-rip-status": "disable",
    "ospf-redistribute-bgp-status": "disable",
    "ospf-redistribute-static-status": "disable",
    "ospf-redistribute-isis-status": "disable",
    "ospf-interface-name": "internal2"
  }
}
```

### RIP

```json
{
  "objectType": "rip",
  "attributes": {
    "rip-version": "2",
    "rip-update-timer": "30",
    "rip-interface": [
      {
        "rip-interface-name": "internal3",
        "rip-interface-auth-mode": "text",
        "rip-interface-auth-string": "ENC_RIP_PASS"
      }
    ],
    "rip-network": [
      {
        "rip-network-prefix": "10.10.10.0 255.255.255.0"
      }
    ]
  }
}
```

Os arrays BGP e RIP representam `subGroup/registry` e preservam a ordem recebida. `label` e `registryId` são metadados XML e não pertencem aos contratos provisórios.

## Decisões pendentes — bloqueadoras

1. Definir os `objectType`s finais do GP para BGP, OSPF e RIP. Os três nomes atuais são provisórios.
2. Definir o de/para de cada atributo e de cada array aninhado para os campos finais Recon/GP.
3. Definir cardinalidade, obrigatoriedade e tipo JSON final de cada campo.
4. Confirmar se BGP, OSPF e RIP são singletons por equipamento ou se cada `registry` de nível superior pode gerar várias ocorrências.
5. Definir a identidade dos subgrupos BGP (`bgp-neighbor`, `bgp-neighbor-group`) e RIP (`rip-interface`, `rip-network`) caso eles precisem de atualização individual, em vez de substituição integral do protocolo.
6. Definir como informações sensíveis, como `ospf-authentication-key` e `rip-interface-auth-string`, devem ser persistidas, mascaradas em logs e exibidas no GP.
7. Definir os campos do metamodelo GP de destino e as futuras entradas em `recon-json-fields.json`.
8. Confirmar se a substituição integral dos arrays internos é funcionalmente aceita; o artefato compartilhado não faz merge parcial de listas.

## Regras provisórias

1. O adaptador deve reconhecer somente grupos com `key` exatamente igual a `bgp`, `ospf` ou `rip`.
2. O JSON de origem preserva os valores XML como strings até existir decisão explícita de conversão.
3. BGP e RIP mantêm seus subgrupos como arrays de objetos, um item por `registry` de subgrupo.
4. Nenhum fragmento BGP, OSPF ou RIP deve ser persistido em `HW_OBJECTS_JSON_EXT`, aplicado por `upsertAll` ou enviado ao `NestedRuleCaller` enquanto as decisões bloqueadoras estiverem pendentes.
5. Objetos `device`, `zona`, `route-static` e demais tipos permanecem independentes deste escopo.

## Atualização requerida antes de implementar

Quando o mapeamento IM -> Recon/GP for aprovado, atualizar esta história com:

- tabelas completas `campo XML -> atributo JSON final` para BGP, OSPF e RIP;
- exemplos JSON finais aprovados, incluindo os arrays aninhados;
- cardinalidade e identidade de cada protocolo e de seus subgrupos;
- configuração em `im-json-object-mappings.json`, se houver renomeação ou agregação;
- entradas em `object-key-definitions.json` para todo tipo final multivalorado;
- entradas em `recon-json-fields.json` para cada `objectType` final;
- estratégia de tratamento de credenciais/chaves de autenticação;
- critérios de aceite, fixtures e testes de insert, update, duplicidade, atomicidade e regressão.

## Critérios para sair de draft

1. O de/para dos campos BGP, OSPF e RIP foi aprovado pelo domínio Recon/GP.
2. Os `objectType`s finais, cardinalidades e identidades foram definidos.
3. A semântica de atualização dos arrays internos foi aprovada.
4. O tratamento de chaves de autenticação e sua observabilidade foi definido.
5. Os campos JSON de destino no Roteador e as configurações necessárias foram definidos.
6. XML representativo e JSON final foram revisados pelos responsáveis do IM e do GP.

## Referências

- `gp/docs/dev/13.3.200/recon/04-integracao-recon-campos-json-im-gp.md`
- `gp/docs/dev/13.3.200/recon/03-artefato-compartilhado-upsert-documento-json.md`
- `gp/docs/dev/13.3.200/recon/07-sincronizacao-json-im-gp-route-static.md`
- `/l/disk0/fluis/Downloads/getEquipmentResponse-massa-completa.xml` (fonte de exemplo; comentários XML não são requisitos)

## Dev Agent Record

### Completion Notes

- História criada em modo de descoberta. BGP, OSPF e RIP estão documentados como contratos de origem, mas a implementação está bloqueada por mapeamento, identidade, arrays e tratamento de credenciais.

### Change Log

- 2026-08-31: criada a história provisória para Roteamento Dinâmico (BGP, OSPF e RIP).