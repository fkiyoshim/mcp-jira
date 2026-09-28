# História 09 - Reconciliar Versão de Software do Roteador

**Status:** ready-for-dev  
**Release:** 13.3.200  
**Componente principal:** `gp/recon`  
**Componentes relacionados:** EAI Webservices, OSS Network Resources, DBManager e metamodelo ENG

## História de usuário

Como operador do Recon,
quero configurar e reconciliar a **Versão de Software** dos Roteadores,
para identificar diferenças entre o IM e o inventário GP e, quando solicitado, atualizar o GP com o valor do IM.

## Contexto

O campo já existe no Roteador/`IP_NE`: nome técnico `SOFTWARE_VERSION`, texto de até 50 caracteres. Não criar novamente o atributo no Roteador.

Usar o fluxo já existente de `SERIAL_NUMBER` como referência. A nova opção deve iniciar **desabilitada** (`0`) nas configurações existentes e nas novas configurações, evitando que agendamentos atuais passem a apontar divergências inesperadas.

Fora de escopo: versão de firmware, versão de hardware, placas, portas e qualquer outro tipo de equipamento que não seja Roteador.

## Fluxo esperado

```text
IM envia softwareVersion
  -> Recon lê softwareVersion do IM e SOFTWARE_VERSION do GP
  -> configuração SOFTWARE_VERSION define se compara
  -> diferença vira resultado de Recon
  -> “Atualizar inventário” grava o valor IM em IP_NE.SOFTWARE_VERSION
```

## Passo a passo de implementação

### 1. Expor o valor no contrato do IM

- Em `gp/eai/webservices/contracts/src/main/wsdl/ReconServices.wsdl`, adicionar `softwareVersion` opcional ao tipo `EquipmentData`, próximo a `serialNumber`.
- Regenerar as classes JAXB do contrato; não editar arquivos em `target/` manualmente.
- Solicitar ao time responsável pelo IM que publique `softwareVersion` no serviço. O código do provedor desse serviço não está neste repositório; validar a entrega com uma resposta real do serviço.

### 2. Transportar os valores no Recon

- Em `core/.../pojo/Equipment.java`, criar `softwareVersion`, getter e setter.
- Em `core/.../rule/RecoverIMEquipments.java`, copiar `elemEquip.getSoftwareVersion()` para `Equipment`.
- Em `core/.../repository/InventoryRepository.java`, selecionar `ne.software_version` e preencher o mesmo campo do `Equipment` vindo do GP.

### 3. Criar a configuração do atributo

- Em `gp/oss/.../ReconAttributesConfig.java`, adicionar a propriedade `softwareVersion`, mapeada para a coluna `SOFTWARE_VERSION`, e incluí-la em `getAttributesMap()` com a chave `SOFTWARE_VERSION`.
- No DBManager, adicionar `SOFTWARE_VERSION NUMBER(1)` à criação de `RECON_ATRIB_CFG` e criar um patch idempotente para instalações existentes. O valor padrão e o preenchimento de registros existentes devem ser `0`.
- No metamodelo ENG da configuração de atributos de reconciliação, adicionar o campo e o label **Versão de Software**.

### 4. Comparar e guardar o resultado

- Em `ReconConstants`, criar a constante de configuração `SOFTWARE_VERSION`.
- Em `ReconEquipments.compareEquipmentPhysicalAttributes`, comparar as versões usando o método `compare(...)`, como é feito para `SERIAL_NUMBER`. A comparação só deve ocorrer quando a configuração estiver em `1`.
- Criar campos ISP e EXT para a versão nas entidades, tabelas e consultas de resultado de reconciliação, seguindo o padrão `IP_NE_SERIAL_NUMBER_ISP` e `IP_NE_SERIAL_NUMBER_EXT`.
- Exibir os dois valores no resultado, árvore e CSV quando houver divergência.

### 5. Atualizar o inventário GP

- Em `ReconService`, incluir `SOFTWARE_VERSION: <valor EXT/IM>` entre os atributos gerados para a atualização completa do equipamento.
- Reutilizar o mesmo mecanismo já usado pelo Número de Série. Não alterar o fluxo das atualizações existentes.

### 6. Testar

- Criar testes unitários para valores iguais, diferentes, nulos e espaços nas extremidades.
- Cobrir configuração desligada (`0`): valores diferentes não geram divergência.
- Cobrir configuração ligada (`1`): valores diferentes geram divergência e aparecem no resultado.
- Cobrir atualização: o valor IM é enviado para `SOFTWARE_VERSION` do Roteador.
- Executar os testes existentes de `ReconEquipments` e da atualização de inventário para confirmar que Número de Série continua funcionando.

## Critérios de aceitação

1. Dado um Roteador com versões iguais no IM e GP, quando `SOFTWARE_VERSION` estiver configurado como `1`, então a versão não gera divergência.
2. Dado um Roteador com versões diferentes, quando `SOFTWARE_VERSION` estiver configurado como `1`, então o resultado mostra os valores ISP e IM e marca a divergência.
3. Dado um Roteador com versões diferentes, quando `SOFTWARE_VERSION` estiver configurado como `0`, então a versão não altera o resultado da reconciliação.
4. Dado um resultado divergente selecionado para atualização, quando o operador executar “Atualizar inventário”, então `IP_NE.SOFTWARE_VERSION` recebe o valor vindo do IM.
5. Dada uma base já existente após o patch, quando uma configuração de atributos for lida, então `SOFTWARE_VERSION` vale `0` e a base continua utilizável.
6. Dado o contrato do IM sem valor de versão, quando a reconciliação executar, então o Recon trata o valor como vazio e não falha.

## Dependência externa

O IM deve publicar o elemento opcional `softwareVersion` no serviço de Recon. Sem esse valor, as demais partes podem ser implementadas e testadas, mas não haverá comparação real contra o IM.

## Referências

- `gp/recon/fontes/components/core/src/main/java/br/com/cpqd/etics/recon/core/rule/ReconEquipments.java`
- `gp/recon/fontes/components/core/src/main/java/br/com/cpqd/etics/recon/core/repository/InventoryRepository.java`
- `gp/recon/fontes/components/core/src/main/java/br/com/cpqd/etics/recon/core/rule/RecoverIMEquipments.java`
- `gp/recon/fontes/components/core/src/main/java/br/com/cpqd/etics/recon/core/service/ReconService.java`
- `gp/oss/fontes/components/networkresources/src/main/java/br/com/cpqd/oss/commons/etics/networkresources/entities/recon/ReconAttributesConfig.java`
- `gp/eai/webservices/contracts/src/main/wsdl/ReconServices.wsdl`
- `gp/eng/fontes/components/model/src/main/xml/152000333_object_class.xml`