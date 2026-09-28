# language: pt
# Cadastros complementares da revisão H02–H08 de 10/09/2026.
# Evidência de cadastro; nenhum teste de produto foi executado.
Funcionalidade: Complementos de cobertura dos MDs de reconciliação

  @H02 @ETICS-T8094 @desenvolvimento
  # História: ETICS-252562
  # Fonte: h02-md.txt — AC1–3; Campos impactados; Tasks metamodelo
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Metamodelo anterior e entregue disponíveis para comparação técnica.
  Cenário: RECON-H02-MD-01 — Conferir metadados dos 23 atributos e preservar o layout
    Dado o objeto ReconConfiguration 194004734 e os 23 campos PACK_MANUFACTURER, PACK_MODEL, PACK_TECHNOLOGY, PACK_SERIAL_NUMBER, PACK_PART_NUMBER, PORT_IP_ADDRESS_IPV4, PORT_IP_ADDRESS_IPV6, PORT_TECHNOLOGY, MAC_ADDRESS, PORT_SERIAL_NUMBER, PORT_SFP, PSEUDOWIRE, VLAN, VRF, VLAN_EQPT, PORT_CIRCUIT, IP_ADDRESS_IPV4, IP_ADDRESS_IPV6, SERIAL_NUMBER, IP_MANUFACTURER, IP_MODEL, IP_TECHNOLOGY, IP_PART_NUMBER
    Quando comparar os metadados entregues com a versão anterior
    Então todos os 23 campos possuem representation_type=2 e apontam para as mesmas colunas de RECON_ATRIB_CFG
    E a nova opção possui sequence=2, lower_value=2 e upper_value vazio
    E painéis, linhas, colunas, layout e operações existentes permanecem preservados

  @H02 @ETICS-T8095 @sistemico
  # História: ETICS-252562
  # Fonte: h02-md.txt — AC2; Tasks labels multi-idioma
  # Pré-condições: Build com catálogos pt_BR, en_US, es e es_PE; acesso à configuração.
  # Pendência: A redação traduzida final deve ser conferida no catálogo aprovado; o MD não especifica os textos traduzidos.
  Cenário: RECON-H02-MD-02 — Validar labels das listas nos quatro idiomas
    Dado os catálogos pt_BR, en_US, es e es_PE do objeto ReconConfiguration
    Quando abrir a configuração em cada idioma e conferir os labels dos 23 atributos configuráveis
    Então cada lista apresenta três rótulos funcionais correspondentes a Ignorar, Comparar IM x GP e Sincronizar IM -> GP
    E os rótulos estão associados respectivamente aos valores numéricos 0, 1 e 2 sem chaves de tradução expostas
    E os rótulos não apresentam semântica de checkbox Não/Sim

  @H02 @ETICS-T8096 @desenvolvimento
  # História: ETICS-252562
  # Fonte: h02-md.txt — AC7; Tasks carga em ambientes existentes
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Cópia controlada de ambiente anterior, backup de metadados e valores 0/1.
  Cenário: RECON-H02-MD-03 — Atualizar metadados de ambiente existente sem conflito de IDs
    Dado um ambiente existente com metadados de checkbox e configurações numéricas 0 e 1
    Quando aplicar a entrega pelo mecanismo padrão de metamodelo ou pelo patch DBManager definido para o ambiente
    Então object_class, field, valid_value e labels necessários às listas ficam atualizados
    E os novos IDs de valid_value não colidem com os existentes
    E os valores funcionais 0 e 1 em RECON_ATRIB_CFG permanecem inalterados
    Quando abrir uma configuração e selecionar o valor 2 em um atributo liberado para edição
    Então a opção pode ser salva e reaberta como lista

  @H02 @ETICS-T8097 @sistemico
  # História: ETICS-252562
  # Fonte: h02-md.txt — Tasks impacto runtime; VerifyMatchAttributesInUseRuleObject
  # Pré-condições: Configuração não nativa em uso por reconciliação, estado anterior registrado.
  Cenário: RECON-H02-MD-04 — Preservar bloqueio de alteração de configuração em uso
    Dado uma configuração não nativa que está em uso
    Quando tentar alterar um atributo pela lista para outro valor dentre 0, 1 e 2 e salvar
    Então a regra de configuração em uso impede a alteração
    E o valor persistido anteriormente em RECON_ATRIB_CFG permanece inalterado

  @H02 @ETICS-T8098 @sistemico
  # História: ETICS-252562
  # Fonte: h02-md.txt — Tasks impacto runtime; VerifyMatchAttributesNativeRuleObject
  # Pré-condições: Configuração nativa identificada e valores anteriores registrados.
  Cenário: RECON-H02-MD-05 — Preservar bloqueio de alteração de configuração nativa
    Dado uma configuração nativa de atributos reconciliáveis
    Quando tentar alterar um atributo pela nova lista e salvar
    Então a regra de configuração nativa impede a alteração
    E os valores persistidos permanecem inalterados

  @H03 @ETICS-T8099 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC1; Contrato do documento atual
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-01 — Inicializar envelope de recurso a partir do schema
    Dado um schema com name=routerConf, valueType=object e schemaVersion=1
    E em execuções independentes o documento atual é null, string vazia ou somente espaços
    Quando aplicar uma lista vazia de patches pela ResourceDocumentPatchService
    Então mergedJson contém o envelope name=routerConf e valueType=object
    E value contém schemaVersion=1, nextResourceId=1, attributes={} e resources={}

  @H03 @ETICS-T8100 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC2; Contrato de entrada
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-02 — Aplicar patch global preservando atributos omitidos
    Dado o envelope válido do MD com device-group=A001, device-ha-role=Active e as zonas existentes
    Quando aplicar a entrada {"attributes":{"device-group":"A002"}}
    Então apenas value.attributes.device-group passa a A002
    E device-ha-role, os demais atributos globais, resources e nextResourceId permanecem iguais ao snapshot

  @H03 @ETICS-T8101 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC3; Semântica de patch
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-03 — Atualizar recurso por chave exata preservando ID e campos omitidos
    Dado o documento do MD com zona underlay de id=1, type=tipo1 e zone-interface=["wan1"]
    Quando aplicar {"zona":{"zone-name":"underlay","zone-interface":["wan1","lan2"]}}
    Então a zona underlay mantém id=1 e type=tipo1 e passa a zone-interface=["wan1","lan2"]
    E a zona layzone e nextResourceId=3 permanecem inalterados
    E o resultado do item informa UPDATE para a identidade underlay

  @H03 @ETICS-T8102 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC4; Semântica de patch
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-04 — Inserir recurso obrigatório com ID gerado pelo contador
    Dado o documento do MD com nextResourceId=3 e sem zona dmz
    Quando aplicar {"zona":{"zone-name":"dmz","type":"tipo1","zone-interface":["dmz1"]}}
    Então a zona dmz é inserida com id=3 e os campos recebidos
    E nextResourceId passa a 4 e os recursos anteriores permanecem
    E o resultado informa INSERT e o ID gerado 3

  @H03 @ETICS-T8103 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC5; API pública proposta
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-05 — Gerar IDs consecutivos e resultados na ordem do lote
    Dado o documento do MD com nextResourceId=3
    E o lote contém nesta ordem insert da zona dmz, update de underlay e insert da zona interna, com campos válidos
    Quando aplicar o lote pela ResourceDocumentPatchService
    Então dmz recebe id=3, underlay mantém id=1 e interna recebe id=4
    E nextResourceId final é 5
    E os resultados preservam os índices 0, 1 e 2, coleção zona, identidades dmz, underlay e interna e operações INSERT, UPDATE e INSERT
    E os resultados de insert incluem os IDs 3 e 4

  @H03 @ETICS-T8104 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC6; IDs únicos em todo o documento
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-06 — Compartilhar sequência de IDs entre coleções
    Dado um schema genérico válido com coleções colecaoA e colecaoB e identidades string nome
    E o documento possui id=1 em colecaoA e nextResourceId=2
    Quando inserir um recurso válido em colecaoB e depois outro em colecaoA no mesmo lote
    Então os novos recursos recebem respectivamente id=2 e id=3
    E nenhum ID se repete entre as coleções e nextResourceId final é 4

  @H03 @ETICS-T8105 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC8
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-07 — Substituir array inteiro no patch de recurso
    Dado a zona underlay com id=1, type=tipo1 e zone-interface=["wan1","lan2"]
    Quando aplicar {"zona":{"zone-name":"underlay","zone-interface":["dmz1"]}}
    Então zone-interface contém somente ["dmz1"]
    E wan1 e lan2 não são retidos por merge de listas
    E id=1 e type=tipo1 permanecem

  @H03 @ETICS-T8106 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC13; identidade composta
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-08 — Comparar identidade composta como tupla exata
    Dado um schema com identity.attributes=["a","b"], ambos strings obrigatórias e sensíveis à caixa
    E a coleção possui recursos com tuplas ("ab","c"), ("a","bc") e ("AB","c"), IDs distintos e atributo valor="antes"
    Quando aplicar um patch para a tupla ("ab","c") com valor="depois"
    Então somente a ocorrência ("ab","c") é atualizada e preserva seu ID
    E ("a","bc") e ("AB","c") permanecem integralmente inalteradas
    E não ocorre colisão por concatenação nem conversão de caixa

  @H03 @ETICS-T8107 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — Semântica de patch; identidade imutável
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-09 — Não inferir renomeação de identidade do recurso
    Dado o documento do MD com zona underlay de id=1 e nextResourceId=3
    Quando aplicar uma entrada completa válida para zone-name=Underlay
    Então é inserida uma nova zona Underlay com id=3
    E a zona underlay de id=1 permanece inalterada
    E o componente não infere renomeação e nextResourceId passa a 4

  @H03 @ETICS-T8108 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC7; Validações e erros
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-10 — Rejeitar schema ausente ou inconsistente
    Dado o contexto da nova API ResourceDocumentPatchService e snapshots das entradas
    E o schema é, em execuções independentes, ausente, JSON malformado ou contém uma identidade que referencia atributo não declarado
    Quando aplicar a entrada ou lote pela nova API, mantendo válidos os demais dados de cada execução
    Então a operação falha com ResourceDocumentPatchException e código INVALID_RESOURCE_DOCUMENT_SCHEMA
    E não devolve mergedJson parcial e não modifica argumentos nem consome contador no documento original
    E a mensagem e os logs não incluem o payload JSON

  @H03 @ETICS-T8109 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC9; Validações e erros
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-11 — Rejeitar envelope incompatível com o schema
    Dado o contexto da nova API ResourceDocumentPatchService e snapshots das entradas
    E o documento atual é, em execuções independentes, JSON malformado ou um envelope com name, valueType ou schemaVersion diferente do schema
    Quando aplicar a entrada ou lote pela nova API, mantendo válidos os demais dados de cada execução
    Então a operação falha com ResourceDocumentPatchException e código INVALID_CURRENT_RESOURCE_DOCUMENT
    E não devolve mergedJson parcial e não modifica argumentos nem consome contador no documento original
    E a mensagem e os logs não incluem o payload JSON

  @H03 @ETICS-T8110 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — Contrato de entrada; Validações e erros
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-12 — Rejeitar patch inválido ou com múltiplas chaves raiz
    Dado o contexto da nova API ResourceDocumentPatchService e snapshots das entradas
    E a entrada é, em execuções independentes, JSON malformado, uma raiz escalar ou {"attributes":{"device-group":"A002"},"zona":{"zone-name":"underlay"}}
    Quando aplicar a entrada ou lote pela nova API, mantendo válidos os demais dados de cada execução
    Então a operação falha com ResourceDocumentPatchException e código INVALID_RESOURCE_PATCH
    E não devolve mergedJson parcial e não modifica argumentos nem consome contador no documento original
    E a mensagem e os logs não incluem o payload JSON

  @H03 @ETICS-T8111 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC7; Validações e erros
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-13 — Rejeitar coleção não cadastrada no schema
    Dado o contexto da nova API ResourceDocumentPatchService e snapshots das entradas
    E a entrada usa a coleção naoCadastrada ausente do schema
    Quando aplicar a entrada ou lote pela nova API, mantendo válidos os demais dados de cada execução
    Então a operação falha com ResourceDocumentPatchException e código UNKNOWN_RESOURCE
    E não devolve mergedJson parcial e não modifica argumentos nem consome contador no documento original
    E a mensagem e os logs não incluem o payload JSON

  @H03 @ETICS-T8112 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC7; Validações e erros
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-14 — Rejeitar atributo global ou de recurso desconhecido
    Dado o contexto da nova API ResourceDocumentPatchService e snapshots das entradas
    E em execuções independentes uma entrada attributes ou uma entrada da zona underlay contém o campo naoDeclarado ausente do schema
    Quando aplicar a entrada ou lote pela nova API, mantendo válidos os demais dados de cada execução
    Então a operação falha com ResourceDocumentPatchException e código UNKNOWN_ATTRIBUTE
    E não devolve mergedJson parcial e não modifica argumentos nem consome contador no documento original
    E a mensagem e os logs não incluem o payload JSON

  @H03 @ETICS-T8113 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC7; Validações e erros
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-15 — Rejeitar tipo de atributo incompatível com o schema
    Dado o contexto da nova API ResourceDocumentPatchService e snapshots das entradas
    E em execuções independentes ha-group recebe a string "1024", zone-interface recebe uma string no lugar de array ou um array com item numérico
    Quando aplicar a entrada ou lote pela nova API, mantendo válidos os demais dados de cada execução
    Então a operação falha com ResourceDocumentPatchException e código INVALID_ATTRIBUTE_TYPE
    E não devolve mergedJson parcial e não modifica argumentos nem consome contador no documento original
    E a mensagem e os logs não incluem o payload JSON

  @H03 @ETICS-T8114 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC7; Validações e erros
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-16 — Rejeitar identidade ausente ou inválida em recurso
    Dado o contexto da nova API ResourceDocumentPatchService e snapshots das entradas
    E em execuções independentes a entrada zona possui zone-name ausente, null, string vazia ou valor numérico
    Quando aplicar a entrada ou lote pela nova API, mantendo válidos os demais dados de cada execução
    Então a operação falha com ResourceDocumentPatchException e código MISSING_RESOURCE_IDENTITY
    E não devolve mergedJson parcial e não modifica argumentos nem consome contador no documento original
    E a mensagem e os logs não incluem o payload JSON

  @H03 @ETICS-T8115 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC7; Validações e erros
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-17 — Rejeitar identidade duplicada no documento ou lote
    Dado o contexto da nova API ResourceDocumentPatchService e snapshots das entradas
    E em execuções independentes o documento contém duas zonas com zone-name=underlay e IDs distintos ou o lote contém duas entradas para zone-name=underlay
    Quando aplicar a entrada ou lote pela nova API, mantendo válidos os demais dados de cada execução
    Então a operação falha com ResourceDocumentPatchException e código DUPLICATE_RESOURCE_IDENTITY
    E não devolve mergedJson parcial e não modifica argumentos nem consome contador no documento original
    E a mensagem e os logs não incluem o payload JSON

  @H03 @ETICS-T8116 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC6; Validações e erros
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-18 — Rejeitar ID repetido entre recursos de qualquer coleção
    Dado o contexto da nova API ResourceDocumentPatchService e snapshots das entradas
    E em execuções independentes dois recursos da mesma coleção ou de coleções distintas possuem id=1 no documento atual, com identidades distintas e contador válido
    Quando aplicar a entrada ou lote pela nova API, mantendo válidos os demais dados de cada execução
    Então a operação falha com ResourceDocumentPatchException e código DUPLICATE_RESOURCE_ID
    E não devolve mergedJson parcial e não modifica argumentos nem consome contador no documento original
    E a mensagem e os logs não incluem o payload JSON

  @H03 @ETICS-T8117 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC6; Validações e erros
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-19 — Rejeitar contador de recurso ausente ou inválido
    Dado o contexto da nova API ResourceDocumentPatchService e snapshots das entradas
    E com maior ID existente igual a 2, nextResourceId é, em execuções independentes, ausente, zero, negativo, fracionário, string, 1 ou 2
    Quando aplicar a entrada ou lote pela nova API, mantendo válidos os demais dados de cada execução
    Então a operação falha com ResourceDocumentPatchException e código INVALID_NEXT_RESOURCE_ID
    E não devolve mergedJson parcial e não modifica argumentos nem consome contador no documento original
    E a mensagem e os logs não incluem o payload JSON

  @H03 @ETICS-T8118 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC7; Validações e erros
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-20 — Rejeitar insert sem atributo obrigatório
    Dado o contexto da nova API ResourceDocumentPatchService e snapshots das entradas
    E em execuções independentes a entrada de uma nova zona dmz tem zone-name válido mas omite type ou zone-interface
    Quando aplicar a entrada ou lote pela nova API, mantendo válidos os demais dados de cada execução
    Então a operação falha com ResourceDocumentPatchException e código MISSING_REQUIRED_ATTRIBUTE
    E não devolve mergedJson parcial e não modifica argumentos nem consome contador no documento original
    E a mensagem e os logs não incluem o payload JSON

  @H03 @ETICS-T8119 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC8; Validações e erros
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-21 — Rejeitar null em atributo global ou campo de recurso
    Dado o contexto da nova API ResourceDocumentPatchService e snapshots das entradas
    E em execuções independentes a entrada tenta atribuir null a device-group global, ao campo type de underlay ou ao array zone-interface de underlay
    Quando aplicar a entrada ou lote pela nova API, mantendo válidos os demais dados de cada execução
    Então a operação falha com ResourceDocumentPatchException e código NULL_ATTRIBUTE_VALUE
    E não devolve mergedJson parcial e não modifica argumentos nem consome contador no documento original
    E a mensagem e os logs não incluem o payload JSON

  @H03 @ETICS-T8120 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC7–8; schema minItems
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  # Pendência: O MD não fixa qual código deve representar violação de minItems; verificar a falha sem inventar código.
  Cenário: RECON-H03-MD-22 — Rejeitar array abaixo da cardinalidade do schema
    Dado o schema de zona com zone-interface de minItems=1 e um documento válido
    Quando aplicar um patch para underlay com zone-interface=[]
    Então a validação rejeita o array sem devolver resultado parcial
    E o documento e o contador originais permanecem inalterados

  @H03 @ETICS-T8121 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC13; Semântica de patch
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-23 — Exigir todos os componentes da identidade em insert e update
    Dado um schema com identity.attributes=["a","b"] e um recurso existente de tupla ("x","y")
    Quando aplicar, em execuções independentes de insert e update, uma entrada que fornece a mas omite b
    Então a operação falha com MISSING_RESOURCE_IDENTITY
    E não localiza por chave parcial, não insere recurso e preserva o documento original

  @H03 @ETICS-T8122 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — Semântica de patch; atomicidade
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-24 — Preservar contador e documento quando o último item falha
    Dado o documento do MD com nextResourceId=3
    E o lote tem dois inserts válidos seguidos de um insert que omite type obrigatório
    Quando aplicar o lote completo
    Então a operação falha com MISSING_REQUIRED_ATTRIBUTE e não devolve documento parcial
    E o snapshot do documento mantém nextResourceId=3 e nenhum dos novos recursos
    Quando aplicar somente os dois inserts válidos sobre o documento original
    Então eles recebem id=3 e id=4 e nextResourceId final é 5

  @H03 @ETICS-T8123 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — API pública proposta; parser de schema
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-25 — Ler schema em UTF-8 e fechar os recursos recebidos
    Dado um schema genérico válido com nomes de atributos acentuados e doubles de InputStream e Reader que registram fechamento
    Quando construir JsonResourceDocumentSchema em execuções independentes usando o InputStream UTF-8 e o Reader
    Então os nomes acentuados são lidos corretamente
    E o stream ou reader recebido é fechado em cada execução
    E o schema carregado valida e aplica um patch que usa esses nomes

  @H03 @ETICS-T8124 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — API pública proposta
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-26 — Garantir resultados imutáveis e chamadas sem estado
    Dado uma mesma instância de ResourceDocumentPatchService, um schema válido, documento inicial e lote com insert
    Quando executar duas chamadas com os mesmos argumentos originais
    Então os dois resultados possuem documentos, operações e IDs equivalentes
    E o documento, a lista de patches e o schema de entrada permanecem iguais aos snapshots
    Quando tentar modificar as estruturas expostas pelo resultado
    Então elas não permitem alteração de seu conteúdo

  @H03 @ETICS-T8125 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC10–12; build e API pública
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Consumidor já compilado contra JsonDocumentUpsertService anterior; suíte legada; Java 8 e Jackson gerenciado.
  Cenário: RECON-H03-MD-27 — Manter compatibilidade binária da API legada no Java 8
    Dado um consumidor binário da API JsonDocumentUpsertService anterior e o novo artefato com ResourceDocumentPatchService
    Quando substituir somente o JAR pelo novo e executar a suíte legada de upsert
    Então não ocorre quebra de ligação binária e os resultados de INSERT, UPDATE e substituição integral permanecem compatíveis
    Quando executar o build isolado e no reator cpqd-utils-json com Java 8 e Jackson do ambiente legado
    Então os testes da API nova e da API legada passam
    E a assinatura pública da nova API não expõe tipos Jackson

  @H03 @ETICS-T8126 @desenvolvimento
  # História: ETICS-252569
  # Fonte: h03-md.txt — AC11; limites de domínio
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness da API ResourceDocumentPatchService, schema consumidor válido do exemplo H03 e snapshots dos argumentos; testes em memória.
  Cenário: RECON-H03-MD-28 — Manter a API de patch genérica e sem payload nos logs
    Dado um schema de teste com nomes genéricos de domínio e um valor sentinela JSON_SINTETICO_SIGILOSO
    Quando executar insert e update válidos e uma falha de validação pela nova API sem GP, IM, CDK ou banco
    Então as operações válidas funcionam somente em memória
    E a falha não expõe JSON_SINTETICO_SIGILOSO nem o payload completo em mensagem ou logs
    Quando inspecionar código e dependências do artefato
    Então o domínio routerConf, zona e Huawei não está embutido na implementação genérica
    E não há dependência de banco, JPA, XML/JAXB ou geração UUID

  @H04 @ETICS-T8127 @desenvolvimento
  # História: ETICS-252611
  # Fonte: h04-md.txt — AC1–2; transporte e persistência intermediária
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Ambiente controlado ou harness do coordenador JSON H04; destinos de teste cadastrados; snapshots GP/CLOB e spies de upsertAll e NestedRuleCaller.
  Cenário: RECON-H04-MD-01 — Transportar CLOB extenso sem truncamento
    Dado um array de fragmentos canônicos válidos cujo conteúdo UTF-8 excede o limite VARCHAR2 do ambiente, com pelo menos 40000 caracteres e sentinelas no início e no fim
    Quando transportar Equipment -> ReconEquipment -> ReconEqpt, gravar e reler HW_OBJECTS_JSON_EXT
    Então o conteúdo completo retorna com as sentinelas, acentos, quantidade de fragmentos e valores preservados
    E o mapeamento e o acesso usam CLOB sem conversão para VARCHAR2
    E a coleta não modifica o JSON do GP

  @H04 @ETICS-T8128 @desenvolvimento
  # História: ETICS-252611
  # Fonte: h04-md.txt — AC2; transporte
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Ambiente controlado ou harness do coordenador JSON H04; destinos de teste cadastrados; snapshots GP/CLOB e spies de upsertAll e NestedRuleCaller.
  Cenário: RECON-H04-MD-02 — Ler CLOB nulo ou vazio como lista vazia
    Dado em execuções independentes HW_OBJECTS_JSON_EXT com NULL, conteúdo vazio e []
    Quando recuperar a coleção de fragmentos pelo fluxo ReconEqpt -> coordenador
    Então cada representação resulta em lista vazia sem erro de parsing
    E o documento existente no GP não recebe inserções artificiais nem exclusões por ausência de fragmentos

  @H04 @ETICS-T8129 @desenvolvimento
  # História: ETICS-252611
  # Fonte: h04-md.txt — AC6; RN5
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Ambiente controlado ou harness do coordenador JSON H04; destinos de teste cadastrados; snapshots GP/CLOB e spies de upsertAll e NestedRuleCaller.
  Cenário: RECON-H04-MD-03 — Inicializar merge a partir de JSON GP nulo ou em branco
    Dado um fragmento canônico válido e destino configurado
    E em execuções independentes o valor atual do campo GP é null, string vazia ou somente espaços
    Quando acionar Atualizar inventário
    Então upsertAll recebe [] como documento inicial em cada execução
    E o fragmento é inserido e o JSON final chega ao NestedRuleCaller uma vez por equipamento

  @H04 @ETICS-T8130 @desenvolvimento
  # História: ETICS-252611
  # Fonte: h04-md.txt — AC4 e AC7; RN4 e RN7
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Ambiente controlado ou harness do coordenador JSON H04; destinos de teste cadastrados; snapshots GP/CLOB e spies de upsertAll e NestedRuleCaller.
  Cenário: RECON-H04-MD-04 — Agrupar múltiplos campos JSON com atualização legada única
    Dado dois tipos de teste destinados ao campo JSON A e um terceiro tipo ao campo JSON B, ambos válidos no metamodelo
    E há uma atualização legada válida do mesmo equipamento
    Quando acionar Atualizar inventário
    Então upsertAll é chamado uma vez para A com os dois fragmentos e uma vez para B com seu fragmento
    E os JSONs finais de A e B e a atualização legada compõem o mesmo mapa
    E NestedRuleCaller é chamado exatamente uma vez para o equipamento

  @H04 @ETICS-T8131 @desenvolvimento
  # História: ETICS-252611
  # Fonte: h04-md.txt — AC5; RN3
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Ambiente controlado ou harness do coordenador JSON H04; destinos de teste cadastrados; snapshots GP/CLOB e spies de upsertAll e NestedRuleCaller.
  Cenário: RECON-H04-MD-05 — Rejeitar tipo sem destino na allowlist
    Dado um lote com um tipo conhecido e outro objectType não cadastrado em recon-json-fields.json
    Quando acionar Atualizar inventário
    Então o tipo não cadastrado gera erro e não é descartado silenciosamente
    E nenhum campo GP é alterado e NestedRuleCaller recebe zero chamadas

  @H04 @ETICS-T8132 @desenvolvimento
  # História: ETICS-252611
  # Fonte: h04-md.txt — RN6; configuração e serviço de atualização
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Ambiente controlado ou harness do coordenador JSON H04; destinos de teste cadastrados; snapshots GP/CLOB e spies de upsertAll e NestedRuleCaller.
  Cenário: RECON-H04-MD-06 — Validar configuração de destinos antes da atualização
    Dado em execuções independentes recon-json-fields.json malformado, versão não suportada, mapa com tipo inválido ou nome de tipo ou destino vazio
    Quando carregar a configuração e tentar coordenar uma atualização JSON
    Então a configuração inválida é rejeitada
    E não há atualização parcial nem chamada ao NestedRuleCaller
    Quando carregar uma configuração válida em UTF-8 e processar dois equipamentos
    Então a estrutura carregada é reutilizada e imutável

  @H04 @ETICS-T8133 @desenvolvimento
  # História: ETICS-252611
  # Fonte: h04-md.txt — AC8; RN8–9
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Ambiente controlado ou harness do coordenador JSON H04; destinos de teste cadastrados; snapshots GP/CLOB e spies de upsertAll e NestedRuleCaller.
  Cenário: RECON-H04-MD-07 — Preservar JSON bruto com dois-pontos e fluxo legado
    Dado um fragmento válido contendo uma string com "texto: valor: final", aspas escapadas, acentos e espaços nas extremidades
    E uma atualização legada válida no mesmo equipamento
    Quando acionar Atualizar inventário e inspecionar o mapa recebido pelo CDK
    Então o valor JSON recebido é igual ao JSON final do coordenador, sem split, trim ou alteração de conteúdo
    E o caminho JSON não utiliza ObjectUpdate.value nem conversão de descrição para nome de metamodelo
    E a atualização legada mantém os mesmos campo e valor do fluxo anterior

  @H04 @ETICS-T8134 @desenvolvimento
  # História: ETICS-252611
  # Fonte: h04-md.txt — RN6–7; AC5
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Ambiente controlado ou harness do coordenador JSON H04; destinos de teste cadastrados; snapshots GP/CLOB e spies de upsertAll e NestedRuleCaller.
  Cenário: RECON-H04-MD-08 — Abortar todos os destinos quando um campo falha
    Dado fragmentos válidos destinados a dois campos JSON do mesmo equipamento
    E o primeiro campo possui documento válido e o segundo possui JSON atual malformado
    Quando montar as atualizações pelo coordenador
    Então a falha do segundo campo impede aplicar o resultado do primeiro
    E ambos os campos preservam os snapshots e NestedRuleCaller recebe zero chamadas

  @H04 @ETICS-T8135 @desenvolvimento
  # História: ETICS-252611
  # Fonte: h04-md.txt — AC3; alterações técnicas 1–2
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Ambientes de instalação nova e de atualização; metamodelo/DDL e SQLs de RECON_EQPT disponíveis.
  Cenário: RECON-H04-MD-09 — Conferir metamodelo BLOB e instalação da coluna CLOB
    Dado o pacote da infraestrutura H04 para instalação nova e atualização de ambiente existente
    Quando aplicar respectivamente create schema e patch DBManager e consultar os metadados
    Então RECON_EQPT possui HW_OBJECTS_JSON_EXT como CLOB e os SQLs de colunas explícitas incluem o campo
    E o Roteador 152000333 possui HW_OBJECTS_JSON string com persistência extensa/BLOB e labels exigidos pelo build
    Quando salvar um JSON extenso pelo campo e reler pelo CDK
    Então o conteúdo é preservado integralmente
    E o campo não aparece na árvore comum de divergências

  @H04 @ETICS-T8136 @desenvolvimento
  # História: ETICS-252611
  # Fonte: h04-md.txt — AC9
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Ambiente controlado ou harness do coordenador JSON H04; destinos de teste cadastrados; snapshots GP/CLOB e spies de upsertAll e NestedRuleCaller.
  Cenário: RECON-H04-MD-10 — Evitar XML e JSON completos nos logs do fluxo
    Dado fragmentos com sentinela JSON_FLUXO_TESTE e uma resposta XML de teste identificável
    Quando executar coleta e atualização em um fluxo válido e em outro com falha de validação
    Então os logs não contêm o XML completo nem o JSON completo
    E o erro pode ser identificado sem despejar os documentos

  @H05 @ETICS-T8137 @desenvolvimento
  # História: ETICS-252614
  # Fonte: h05-md.txt — AC2; RN4–5
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H05 e fluxo integrado H04 em ambiente controlado; zone-name registrado como chave; zona -> HW_OBJECTS_JSON; snapshots e spies.
  Cenário: RECON-H05-MD-01 — Preservar cardinalidade, ordem e duplicatas das interfaces de zona
    Dado execuções independentes com uma zona underlay contendo zone-interface=["wan1"] e zone-interface=["wan1","lan2","wan1"]
    Quando converter cada resposta XML e reler o CLOB intermediário
    Então cada registry produz exatamente um fragmento objectType=zona sem wrapper por tipo
    E zone-interface é array em ambos os casos e mantém respectivamente ["wan1"] e ["wan1","lan2","wan1"]
    E os valores não são deduplicados nem reordenados

  @H05 @ETICS-T8138 @desenvolvimento
  # História: ETICS-252614
  # Fonte: h05-md.txt — AC3; RN3
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H05 e fluxo integrado H04 em ambiente controlado; zone-name registrado como chave; zona -> HW_OBJECTS_JSON; snapshots e spies.
  Cenário: RECON-H05-MD-02 — Rejeitar cardinalidade inválida de zone-name antes da persistência
    Dado uma zona válida seguida de uma zona cujo zone-name é, em execuções independentes, ausente, null, vazio ou possui dois valores
    Quando converter o XML e processar o lote do equipamento
    Então o lote inválido é rejeitado antes de persistir fragmentos parciais em HW_OBJECTS_JSON_EXT
    E o GP mantém o snapshot e NestedRuleCaller recebe zero chamadas

  @H05 @ETICS-T8139 @desenvolvimento
  # História: ETICS-252614
  # Fonte: h05-md.txt — AC3; RN4
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H05 e fluxo integrado H04 em ambiente controlado; zone-name registrado como chave; zona -> HW_OBJECTS_JSON; snapshots e spies.
  Cenário: RECON-H05-MD-03 — Rejeitar interface ausente, vazia ou nula no lote de zonas
    Dado uma zona válida seguida de outra com zone-interface ausente, sem valores ou contendo item null ou string vazia em execuções independentes
    Quando processar o XML do equipamento
    Então o conjunto inválido não é persistido parcialmente no CLOB
    E nenhuma zona é aplicada ao GP e NestedRuleCaller recebe zero chamadas

  @H05 @ETICS-T8140 @desenvolvimento
  # História: ETICS-252614
  # Fonte: h05-md.txt — AC3; RN6 e RN8
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H05 e fluxo integrado H04 em ambiente controlado; zone-name registrado como chave; zona -> HW_OBJECTS_JSON; snapshots e spies.
  Cenário: RECON-H05-MD-04 — Rejeitar zone-name repetido com registryId diferente
    Dado duas registry do grupo zona com zone-name=underlay, interfaces válidas e registryId diferentes
    Quando converter e processar a resposta do equipamento
    Então a duplicidade de zone-name causa falha atômica
    E registryId não torna as zonas distintas
    E não há persistência parcial no CLOB nem chamada ao NestedRuleCaller

  @H05 @ETICS-T8141 @desenvolvimento
  # História: ETICS-252614
  # Fonte: h05-md.txt — AC5; RN6
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H05 e fluxo integrado H04 em ambiente controlado; zone-name registrado como chave; zona -> HW_OBJECTS_JSON; snapshots e spies.
  Cenário: RECON-H05-MD-05 — Excluir labels e registryId do JSON e dos logs
    Dado o XML representativo com labels sentinela LABEL_ZONA_TESTE e registryId REG_ZONA_TESTE
    Quando converter, gravar o CLOB e atualizar o inventário
    Então os fragmentos intermediários e o JSON final contêm apenas objectType=zona, zone-name e zone-interface previstos no contrato
    E LABEL_ZONA_TESTE e REG_ZONA_TESTE não aparecem no CLOB, JSON final nem logs
    E a chave de upsert é attributes.zone-name

  @H05 @ETICS-T8142 @desenvolvimento
  # História: ETICS-252614
  # Fonte: h05-md.txt — AC6; contrato EAI e JAXB
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H05 e fluxo integrado H04 em ambiente controlado; zone-name registrado como chave; zona -> HW_OBJECTS_JSON; snapshots e spies.
  Cenário: RECON-H05-MD-06 — Processar XML legado e ausência do grupo zona
    Dado em execuções independentes um XML legado sem additionalInfo, um XML sem grupo zona e outro com grupo Zona em caixa diferente
    Quando processar as respostas pelo cliente JAXB e conversor H05
    Então não são gerados fragmentos de zona em nenhum dos três casos
    E equipamento, placas, portas, VLANs e pseudowires mantêm seu mapeamento legado
    E a ausência de zona não impede o processamento do equipamento

  @H05 @ETICS-T8143 @desenvolvimento
  # História: ETICS-252614
  # Fonte: h05-md.txt — RN1 e RN3; AC4
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H05 e fluxo integrado H04 em ambiente controlado; zone-name registrado como chave; zona -> HW_OBJECTS_JSON; snapshots e spies.
  Cenário: RECON-H05-MD-07 — Distinguir zone-name por caixa e espaços sem normalização
    Dado o GP com zona underlay e uma zona não recebida chamada preservada
    E o IM retorna zonas com nomes Underlay e " underlay " e interfaces válidas
    Quando acionar Atualizar inventário
    Então Underlay e " underlay " são inseridas como identidades distintas
    E underlay e preservada permanecem inalteradas
    E os nomes são mantidos exatamente como recebidos

  @H05 @ETICS-T8144 @desenvolvimento
  # História: ETICS-252614
  # Fonte: h05-md.txt — AC9; identidade e destino
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Pacote H05 e build de integração disponíveis para revisão técnica.
  Cenário: RECON-H05-MD-08 — Verificar entrega conjunta de contrato, chave e destino da zona
    Dado o pacote entregue de H05 e o XML representativo com underlay e overlay
    Quando validar o WSDL, gerar o cliente JAXB pelo build e processar a fixture
    Então group, registry, attribute e múltiplos value são aceitos pelo contrato
    E object-key-definitions.json contém zona -> attributes.zone-name preservando as entradas anteriores
    E recon-json-fields.json contém zona -> HW_OBJECTS_JSON
    E WSDL, cliente gerado, fixture e testes acompanham a mesma entrega

  @H05 @ETICS-T8145 @desenvolvimento
  # História: ETICS-252614
  # Fonte: h05-md.txt — AC7–8
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H05 e fluxo integrado H04 em ambiente controlado; zone-name registrado como chave; zona -> HW_OBJECTS_JSON; snapshots e spies.
  Cenário: RECON-H05-MD-09 — Inserir zonas com documento vazio e entregar JSON bruto uma vez
    Dado em execuções independentes o JSON GP é null, vazio ou branco
    E o XML representativo contém underlay/["wan1"] e overlay/["hub_spk1.2.2"]
    Quando coletar e acionar Atualizar inventário
    Então o documento inicial do merge é [] e o resultado contém exatamente as duas zonas do contrato
    E o valor é entregue como JSON bruto sem ObjectUpdate.value nem split baseado em ": "
    E NestedRuleCaller é chamado uma vez por equipamento

  @H06 @ETICS-T8146 @desenvolvimento
  # História: ETICS-252615
  # Fonte: h06-md.txt — AC1 e AC8; RN1 e RN6
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H06 com mapa equipment-ha válido e device -> HW_OBJECTS_JSON; H04 disponível; snapshots CLOB/GP e spies.
  Cenário: RECON-H06-MD-01 — Conferir de/para HA exato e singleton sem chave artificial
    Dado atributos diretos group-name=SPO-HA-121, hbdev-1=port1, hbdev-2=port2 e monitor=["x3","x4"]
    Quando converter com o mapa equipment-ha
    Então o resultado é um único objectType=device com device-group=SPO-HA-121, ha-port-1=port1, ha-port-2=port2 e ha-monitor-port-range=["x3","x4"]
    E não são persistidos objectType=ha ou objectType=equipment-ha nem nomes de origem como campos de destino
    E device é aceito para HW_OBJECTS_JSON sem entrada em object-key-definitions.json

  @H06 @ETICS-T8147 @desenvolvimento
  # História: ETICS-252615
  # Fonte: h06-md.txt — AC2; Contrato JSON
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H06 com mapa equipment-ha válido e device -> HW_OBJECTS_JSON; H04 disponível; snapshots CLOB/GP e spies.
  Cenário: RECON-H06-MD-02 — Preservar monitor como array sem normalizar seus valores
    Dado todos os atributos HA válidos e monitor=["x3"] em uma execução e [" x3 ","X4"," x3 "] em outra
    Quando converter os atributos HA
    Então ha-monitor-port-range é array em ambas as execuções
    E seu conteúdo é respectivamente ["x3"] e [" x3 ","X4"," x3 "]
    E ordem, caixa, espaços e duplicatas permanecem sem concatenação

  @H06 @ETICS-T8148 @desenvolvimento
  # História: ETICS-252615
  # Fonte: h06-md.txt — AC3; RN2 e RN5
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H06 com mapa equipment-ha válido e device -> HW_OBJECTS_JSON; H04 disponível; snapshots CLOB/GP e spies.
  Cenário: RECON-H06-MD-03 — Rejeitar HA parcial e campos single com cardinalidade inválida
    Dado uma fixture HA válida
    E em cada execução é alterado um de group-name, hbdev-1 ou hbdev-2 para ausente, vazio ou dois valores, mantendo os demais campos válidos
    Quando converter e processar o equipamento
    Então o lote falha sem emitir device parcial
    E nenhum conjunto parcial é persistido no CLOB nem aplicado no GP
    E NestedRuleCaller recebe zero chamadas

  @H06 @ETICS-T8149 @desenvolvimento
  # História: ETICS-252615
  # Fonte: h06-md.txt — AC3; RN3 e RN5
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H06 com mapa equipment-ha válido e device -> HW_OBJECTS_JSON; H04 disponível; snapshots CLOB/GP e spies.
  Cenário: RECON-H06-MD-04 — Rejeitar monitor ausente ou vazio sem aplicar zonas válidas
    Dado uma zona válida e os três atributos HA single válidos
    E monitor está ausente, sem valores ou contém um valor vazio em execuções independentes
    Quando processar o lote do equipamento
    Então o lote é rejeitado sem emitir device parcial
    E a zona válida também não é persistida ou aplicada parcialmente
    E NestedRuleCaller recebe zero chamadas

  @H06 @ETICS-T8150 @desenvolvimento
  # História: ETICS-252615
  # Fonte: h06-md.txt — AC4; RN4
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H06 com mapa equipment-ha válido e device -> HW_OBJECTS_JSON; H04 disponível; snapshots CLOB/GP e spies.
  Cenário: RECON-H06-MD-05 — Aceitar ausência completa de HA no XML legado
    Dado um XML legado sem nenhum dos quatro atributos HA selecionados
    Quando processar a resposta pelo cliente JAXB e conversor H06
    Então nenhum fragmento device é produzido
    E o equipamento continua processável e seu mapeamento legado permanece
    E um device preexistente no GP não é removido pela ausência de HA

  @H06 @ETICS-T8151 @desenvolvimento
  # História: ETICS-252615
  # Fonte: h06-md.txt — RN7; configuração de de/para
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H06 com mapa equipment-ha válido e device -> HW_OBJECTS_JSON; H04 disponível; snapshots CLOB/GP e spies.
  Cenário: RECON-H06-MD-06 — Falhar para mapeamento HA incompleto ou colisão de destinos
    Dado todos os quatro atributos HA válidos
    E em execuções independentes o mapa não define destino para um campo HA selecionado ou mapeia dois campos de origem para o mesmo atributo de destino
    Quando carregar o mapa e converter HA
    Então a inconsistência causa erro sem descarte silencioso nem sobrescrita por colisão
    E não há persistência parcial nem chamada ao NestedRuleCaller

  @H06 @ETICS-T8152 @desenvolvimento
  # História: ETICS-252615
  # Fonte: h06-md.txt — AC7; WSDL/JAXB e adaptador
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H06 com mapa equipment-ha válido e device -> HW_OBJECTS_JSON; H04 disponível; snapshots CLOB/GP e spies.
  Cenário: RECON-H06-MD-07 — Excluir labels e dados HA dos logs em sucesso e falha
    Dado uma resposta HA sintética com label=LABEL_HA_TESTE e valores sentinela identificáveis nos quatro atributos
    Quando coletar e atualizar uma resposta válida e depois processar outra com cardinalidade inválida
    Então label não é transportado para o CLOB nem para o JSON final
    E os logs não contêm os valores HA sentinela, o label, o XML completo ou o JSON completo
    E o diagnóstico da falha não revela esses conteúdos

  @H06 @ETICS-T8153 @desenvolvimento
  # História: ETICS-252615
  # Fonte: h06-md.txt — AC5; RN10
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Harness JAXB/conversor H06 com mapa equipment-ha válido e device -> HW_OBJECTS_JSON; H04 disponível; snapshots CLOB/GP e spies.
  Cenário: RECON-H06-MD-08 — Inserir device em documento vazio e substituir singleton por inteiro
    Dado em execuções independentes documento GP null e vazio e HA completo válido
    Quando acionar Atualizar inventário
    Então o documento contém exatamente um device com os quatro atributos mapeados
    Quando repetir a atualização sobre um documento com device antigo contendo atributo adicional obsoleto e uma zona não recebida
    Então o device inteiro é substituído pelo novo fragmento e o atributo obsoleto não permanece
    E a zona não recebida permanece integralmente inalterada

  @H06 @ETICS-T8154 @desenvolvimento
  # História: ETICS-252615
  # Fonte: h06-md.txt — AC6 e AC9; transporte e atualização
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. H04, H05 e H06 disponíveis; fixture com HA do MD e zonas underlay e overlay; spies e pacote de build.
  Cenário: RECON-H06-MD-09 — Validar entrega integrada HA e duas zonas por um único merge
    Dado o cliente JAXB gerado pelo build a partir do WSDL entregue, os mapas HA, allowlist e fixtures da mesma entrega
    Quando coletar a fixture completa e acionar Atualizar inventário
    Então CLOB e documento final usam o mesmo array canônico com um device e as duas zonas underlay e overlay
    E os três fragmentos são agrupados em HW_OBJECTS_JSON e upsertAll é chamado uma vez para esse campo
    E o JSON bruto é enviado em uma única chamada ao NestedRuleCaller
    E não há segundo documento, campo ou fluxo exclusivo para HA

  @H07 @ETICS-T8155 @desenvolvimento
  # História: ETICS-252629
  # Fonte: h07-md.txt — Regras provisórias 4–5; decisões bloqueadoras
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. Versão da H07 em draft, sem aprovação de objectType, de/para, cardinalidade, identidade e destino; fixture route-static; spies.
  # Pendência: Caso de proteção do estado draft, não de sincronização definitiva. Insert/update/duplicidade continuam dependentes do de/para e da identidade aprovados.
  Cenário: RECON-H07-MD-01 — Impedir persistência de rota estática enquanto o contrato estiver pendente
    Dado que as decisões bloqueadoras da H07 continuam pendentes
    E o XML contém o grupo route-static representativo do MD
    Quando processar a coleta e solicitar Atualizar inventário
    Então os dados provisórios da rota não são persistidos em HW_OBJECTS_JSON_EXT
    E nenhum fragmento de rota é aplicado por upsertAll ou enviado ao NestedRuleCaller
    E nenhum objectType final ou chave de negócio é inferido a partir de route-static ou registryId

  @H08 @ETICS-T8156 @desenvolvimento
  # História: ETICS-252632
  # Fonte: h08-md.txt — Regras provisórias 4; decisões bloqueadoras
  # Pré-condições: VALIDAÇÃO TÉCNICA / DESENVOLVIMENTO: não executável integralmente apenas pela interface. H08 em draft; ausência de aprovação de mapeamento, identidade, arrays, destinos e tratamento de credenciais; fixtures sintéticas BGP/OSPF/RIP; spies.
  # Pendência: Caso de proteção do estado draft. Contratos finais, semântica dos arrays e tratamento de dados de autenticação continuam pendentes; não usar dados reais sensíveis na fixture.
  Cenário: RECON-H08-MD-01 — Impedir persistência de protocolos enquanto os contratos estiverem pendentes
    Dado que as decisões bloqueadoras da H08 continuam pendentes
    E o XML contém, em execuções independentes e em conjunto, os grupos bgp, ospf e rip representativos do MD
    Quando processar a coleta e solicitar Atualizar inventário
    Então nenhum fragmento provisório BGP, OSPF ou RIP é persistido em HW_OBJECTS_JSON_EXT
    E nenhum desses fragmentos é aplicado por upsertAll ou enviado ao NestedRuleCaller
    E não são inferidos objectTypes finais, chaves de upsert ou destinos para os protocolos
