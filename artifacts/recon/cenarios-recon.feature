# language: pt
# Especificação descritiva; exige implementação de steps para automação.
@CLARO_RECON @RECON_H01_H08 @ETICS-C646
Funcionalidade: Reconciliação lógica CLARO entre IM e GP
  Cobrir as histórias H01 a H08 da visão 01.01.
  Preservar os critérios e as pendências dos casos cadastrados no Zephyr.

  @RECON-H01-01 @ETICS-252410 @ETICS-T8036
  Cenário: RECON-H01-01 — Ignorar atributo configurado com 0
    # Fonte: H01; comentário de 28/08/2026
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.
      """
    E os seguintes dados de teste:
      """
      Atributo reconciliável A: GP=valor_GP, IM=valor_IM; configuração A=0.
      """
    Quando executar a reconciliação e abrir o detalhamento.
    Então A diferença em A não gera divergência.
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então A permanece com valor_GP; o atributo ignorado não é sincronizado.

  @RECON-H01-02 @ETICS-252410 @ETICS-T8037
  Cenário: RECON-H01-02 — Comparar atributo configurado com 1
    # Fonte: H01; comentário de 28/08/2026
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.
      """
    E os seguintes dados de teste:
      """
      Atributo A: GP=valor_GP, IM=valor_IM; A=1.
      """
    Quando executar a reconciliação e detalhar o equipamento.
    Então A diferença aparece na comparação IM x GP.
    Quando consultar o inventário sem acionar atualização.
    Então O GP mantém valor_GP; a comparação não efetiva atualização.

  @RECON-H01-03 @ETICS-252410 @ETICS-T8038
  Cenário: RECON-H01-03 — Sincronizar atributo 2 sem divergência nem exibição
    # Fonte: H01; comentário de 28/08/2026
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.
      """
    E os seguintes dados de teste:
      """
      Atributo A: GP=valor_GP, IM=valor_IM; A=2.
      """
    Quando executar a reconciliação e abrir a árvore.
    Então A não gera divergência nem aparece na árvore.
    Quando consultar o GP antes de atualizar.
    Então A permanece com valor_GP.
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então A passa a valor_IM.

  @RECON-H01-04 @ETICS-252410 @ETICS-T8039
  Cenário: RECON-H01-04 — Aplicar os três modos no mesmo equipamento
    # Fonte: H01/H02; visão 01.01, seções 3 e 9
    Dado o contexto de teste: Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. B é um atributo cuja atualização pelo fluxo existente é permitida; os valores recebidos são válidos e nenhuma regra de negócio impede a atualização do roteador.
    E os dados de teste: A=0, B=1, C=2; GP: A=valor_GP_A, B=valor_GP_B, C=valor_GP_C; IM: A=valor_IM_A, B=valor_IM_B, C=valor_IM_C; valores GP e IM diferentes para cada atributo.
    Quando executar a reconciliação e abrir o detalhamento do roteador.
    Então Somente B apresenta divergência na comparação IM x GP, com valor_GP_B e valor_IM_B; A e C não geram divergência e C não aparece na árvore.
    Quando consultar o inventário antes de acionar Atualizar inventário.
    Então A=valor_GP_A, B=valor_GP_B e C=valor_GP_C; a comparação e a consulta não alteram os valores no GP.
    Quando selecionar a divergência de B para resolução com o dado do IM pelo fluxo existente, acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então A permanece com valor_GP_A; B passa a valor_IM_B pela atualização da divergência selecionada; C passa a valor_IM_C silenciosamente, sem exigir seleção de C na árvore.

  @RECON-H01-05 @ETICS-252410 @ETICS-T8040
  Cenário: RECON-H01-05 — Manter atributos silenciosos inalterados durante consultas
    # Fonte: H01; visão §§3 e 8
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.
      """
    E os seguintes dados de teste:
      """
      A=2 e valores diferentes no GP e IM.
      """
    Quando executar reconciliação e abrir/fechar o detalhamento duas vezes.
    Então A não aparece nem gera divergência.
    Quando executar Consultar inventário e conferir A.
    Então Valor GP original preservado até Atualizar inventário.

  @RECON-H01-06 @ETICS-252410 @ETICS-T8041
  Cenário: RECON-H01-06 — Reexecutar sincronização com o mesmo valor
    # Fonte: H01
    # Pendência/observação: Teste de regressão derivado da semântica de atualização.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.
      """
    E os seguintes dados de teste:
      """
      A=2; valor IM já aplicado no GP.
      """
    Quando executar novamente a reconciliação com a mesma resposta.
    Então Não há divergência de A nem exibição de A.
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então A mantém o valor IM, sem duplicação do objeto atualizado.

  @RECON-H02-01 @ETICS-252562 @ETICS-T8042
  Cenário: RECON-H02-01 — Apresentar lista com as três opções por atributo
    # Fonte: H02 AC1–2
    Dado o seguinte contexto de teste:
      """
      Usuário com acesso à configuração de atributos.
      """
    E os seguintes dados de teste:
      """
      Configuração de teste existente.
      """
    Quando abrir Configuração/Atributos reconciliáveis e editar.
    Então Cada atributo configurável é apresentado como lista de seleção.
    Quando abrir a lista de cada categoria de atributo disponível.
    Então Opções exatamente 0=Ignorar, 1=Comparar IM x GP, 2=Sincronizar IM -> GP; seleção única.

  @RECON-H02-02 @ETICS-252562 @ETICS-T8043
  Cenário: RECON-H02-02 — Persistir os valores numéricos 0, 1 e 2
    # Fonte: H02 AC2–3
    Dado o seguinte contexto de teste:
      """
      Usuário autorizado; consulta técnica de RECON_ATRIB_CFG disponível.
      """
    E os seguintes dados de teste:
      """
      Três atributos A, B e C.
      """
    Quando selecionar A=0, B=1, C=2 e salvar.
    Então Gravação concluída.
    Quando reabrir a configuração e consultar os valores persistidos.
    Então Seleções preservadas; valores numéricos 0, 1 e 2 em RECON_ATRIB_CFG.

  @RECON-H02-03 @ETICS-252562 @ETICS-T8044
  Cenário: RECON-H02-03 — Abrir e salvar configuração legada sem migração
    # Fonte: H02 AC4
    Dado o seguinte contexto de teste:
      """
      Configuração criada antes da alteração, contendo valores 0 e 1.
      """
    E os seguintes dados de teste:
      """
      Cópia de configuração legada, sem conversão prévia de dados.
      """
    Quando abrir a configuração legada.
    Então Valores 0 e 1 aparecem nas opções correspondentes.
    Quando salvar sem alterar e reabrir.
    Então Valores e comportamento existentes preservados sem migração.

  @RECON-H02-04 @ETICS-252562 @ETICS-T8045
  Cenário: RECON-H02-04 — Alterar sucessivamente o modo de um atributo
    # Fonte: H02 AC2–3
    Dado o seguinte contexto de teste:
      """
      Usuário autorizado; configuração de teste.
      """
    E os seguintes dados de teste:
      """
      A inicialmente 0.
      """
    Quando alterar A para 1, salvar e reabrir.
    Então A=1 persistido e selecionado.
    Quando alterar A para 2, salvar e reabrir.
    Então A=2 persistido e selecionado.
    Quando alterar A para 0, salvar e reabrir.
    Então A=0 persistido e selecionado, sem múltiplas opções ativas.

  @RECON-H02-05 @ETICS-252562 @ETICS-T8046
  Cenário: RECON-H02-05 — Comparar somente atributos com valor 1
    # Fonte: H02 AC5–6
    # Pendência/observação: A sincronização funcional de C é coberta pela H01.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.
      """
    E os seguintes dados de teste:
      """
      Configuração com A=0, B=1, C=2; valores diferentes entre GP e IM.
      """
    Quando salvar a configuração pela nova lista e executar reconciliação.
    Então Configuração aceita pelo consumidor atual.
    Quando abrir o detalhamento.
    Então Somente B gera divergência por comparação; A e C não são comparados.

  @RECON-H03-01 @ETICS-252569 @ETICS-T8047
  Cenário: RECON-H03-01 — Inserir singleton inexistente
    # Fonte: H03
    Dado o seguinte contexto de teste:
      """
      Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.
      """
    E os seguintes dados de teste:
      """
      Tipo S registrado sem chave; documento válido sem S; fragmento S com attributes={valor:'novo'}.
      """
    Quando aplicar upsert unitário de S.
    Então Documento final contém uma ocorrência de S com os atributos recebidos.
    Quando inspecionar o resultado da operação.
    Então Resultado estruturado informa INSERT para S.

  @RECON-H03-02 @ETICS-252569 @ETICS-T8048
  Cenário: RECON-H03-02 — Substituir singleton inteiro sem merge parcial
    # Fonte: H03
    Dado o seguinte contexto de teste:
      """
      Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.
      """
    E os seguintes dados de teste:
      """
      S existente com attributes={valor:'antigo',obsoleto:true,lista:[1,2]}; entrada S={valor:'novo',lista:[3]}.
      """
    Quando aplicar upsert de S.
    Então Uma ocorrência de S permanece.
    Quando inspecionar atributos e resultado.
    Então valor=novo, lista=[3], obsoleto ausente; resultado UPDATE.

  @RECON-H03-03 @ETICS-252569 @ETICS-T8049
  Cenário: RECON-H03-03 — Inserir e atualizar objetos por chave natural
    # Fonte: H03
    Dado o seguinte contexto de teste:
      """
      Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.
      """
    E os seguintes dados de teste:
      """
      Tipo T com chave registrada id; documento T/id=A; entradas T/id=A e T/id=B.
      """
    Quando aplicar lote com A atualizado e B novo.
    Então A substituído integralmente; B inserido.
    Quando inspecionar resultados por item.
    Então UPDATE para A e INSERT para B, com os respectivos objetos finais.

  @RECON-H03-04 @ETICS-252569 @ETICS-T8050
  Cenário: RECON-H03-04 — Preservar objetos ausentes do lote
    # Fonte: H03
    Dado o seguinte contexto de teste:
      """
      Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.
      """
    E os seguintes dados de teste:
      """
      Documento contém T/id=A e T/id=B; lote altera somente A.
      """
    Quando aplicar lote com nova versão de A.
    Então Operação concluída.
    Quando comparar B com o snapshot.
    Então B preservado integralmente; não há exclusão por ausência na entrada.

  @RECON-H03-05 @ETICS-252569 @ETICS-T8051
  Cenário: RECON-H03-05 — Validar o lote inteiro antes de qualquer alteração
    # Fonte: H03
    Dado o seguinte contexto de teste:
      """
      Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.
      """
    E os seguintes dados de teste:
      """
      Primeiro fragmento válido; segundo fragmento viola formato canônico.
      """
    Quando aplicar os dois fragmentos no mesmo lote.
    Então Lote rejeitado com erro tipado.
    Quando inspecionar documento e snapshots.
    Então Nenhuma alteração parcial é aplicada; primeiro item não deixa resultado persistido.

  @RECON-H03-06 @ETICS-252569 @ETICS-T8052
  Cenário: RECON-H03-06 — Rejeitar documento JSON malformado
    # Fonte: H03
    Dado o seguinte contexto de teste:
      """
      Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.
      """
    E os seguintes dados de teste:
      """
      Documento atual com sintaxe JSON inválida e fragmento válido.
      """
    Quando invocar upsert.
    Então Erro tipado identifica documento inválido.
    Quando verificar diagnóstico e ausência de resultado de sucesso.
    Então Nenhum documento final parcialmente atualizado; mensagem útil sem despejar conteúdo sensível.

  @RECON-H03-07 @ETICS-252569 @ETICS-T8053
  Cenário: RECON-H03-07 — Rejeitar ausência de chave natural obrigatória
    # Fonte: H03
    Dado o seguinte contexto de teste:
      """
      Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.
      """
    E os seguintes dados de teste:
      """
      Tipo T tem chave id; fragmento T contém attributes sem id.
      """
    Quando aplicar fragmento sem id.
    Então Falha de validação de chave; não deve tratar T como singleton.
    Quando comparar documento com snapshot.
    Então Documento inalterado e erro tipado.

  @RECON-H03-08 @ETICS-252569 @ETICS-T8054
  Cenário: RECON-H03-08 — Executar componente sem dependências de infraestrutura
    # Fonte: H03
    Dado o seguinte contexto de teste:
      """
      Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.
      """
    E os seguintes dados de teste:
      """
      Consumidor mínimo com JAR e dependências declaradas; sem GP, IM, CDK ou banco configurados.
      """
    Quando resolver o artefato via gerenciamento de dependências do OSS Commons.
    Então Módulo disponível no reator e para o consumidor.
    Quando executar INSERT e UPDATE válidos.
    Então Operações funcionam em memória sem exigir serviços externos.

  @RECON-H03-09 @ETICS-252569 @ETICS-T8055
  Cenário: RECON-H03-09 — Produzir resultado determinístico em chamadas independentes
    # Fonte: H03
    Dado o seguinte contexto de teste:
      """
      Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.
      """
    E os seguintes dados de teste:
      """
      Mesmo documento inicial e mesmo lote em duas execuções novas.
      """
    Quando executar duas vezes a mesma operação a partir de cópias do documento inicial.
    Então Ambas terminam com sucesso.
    Quando comparar documentos finais e resultados por item.
    Então Resultados equivalentes; uma execução não contamina a outra.

  @RECON-H03-10 @ETICS-252569 @ETICS-T8056
  Cenário: RECON-H03-10 — Não validar regras de domínio no componente genérico
    # Fonte: H03 exclusões
    Dado o seguinte contexto de teste:
      """
      Harness do JAR compartilhado; documento e fragmentos canônicos conforme contrato publicado; registro global de tipos configurado; snapshots das entradas.
      """
    E os seguintes dados de teste:
      """
      Tipo registrado; chave válida; atributo interno opaco com texto que não representa um IPv4.
      """
    Quando aplicar fragmento estruturalmente válido.
    Então Componente aceita o atributo interno sem validar IPv4.
    Quando consultar o resultado.
    Então Valor opaco preservado; validação de domínio permanece no consumidor.

  @RECON-H04-01 @ETICS-252611 @ETICS-T8057
  Cenário: RECON-H04-01 — Coletar fragmentos em CLOB sem alterar GP
    # Fonte: H04 RN2–3,11
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Acesso técnico somente de consulta a RECON_EQPT.
      """
    E os seguintes dados de teste:
      """
      GP contém objeto antigo X; IM retorna dois fragmentos novos Y e Z.
      """
    Quando executar a reconciliação.
    Então Coleta concluída.
    Quando inspecionar CLOB de RECON_EQPT e JSON do GP.
    Então CLOB contém array apenas de Y e Z, cada fragmento com objectType e attributes; não contém cópia de X; GP mantém snapshot inicial.

  @RECON-H04-02 @ETICS-252611 @ETICS-T8058
  Cenário: RECON-H04-02 — Aplicar lote misto com única atualização
    # Fonte: H04 RN4–8
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Contador/spy de NestedRuleCaller disponível.
      """
    E os seguintes dados de teste:
      """
      GP contém singleton S e T/id=A; IM atualiza S e A e insere T/id=B.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então S e A substituídos integralmente; B inserido.
    Quando inspecionar o contador e o argumento do NestedRuleCaller.
    Então Exatamente uma chamada para o equipamento, contendo JSON final com os três resultados.

  @RECON-H04-03 @ETICS-252611 @ETICS-T8059
  Cenário: RECON-H04-03 — Abortar lote quando qualquer fragmento é inválido
    # Fonte: H04 RN7,9
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Contador/spy de NestedRuleCaller disponível.
      """
    E os seguintes dados de teste:
      """
      Lote com fragmento válido seguido de fragmento inválido.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Atualização rejeitada; nenhum fragmento aplicado.
    Quando conferir GP e contador.
    Então Snapshot original preservado; zero chamadas ao NestedRuleCaller.

  @RECON-H04-04 @ETICS-252611 @ETICS-T8060
  Cenário: RECON-H04-04 — Abortar atualização com documento GP inválido
    # Fonte: H04 RN9
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Contador/spy disponível; fixture controlada para JSON inválido.
      """
    E os seguintes dados de teste:
      """
      Documento GP malformado e lote IM válido.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Falha diagnosticada sem aplicar fragmentos.
    Quando conferir contador e inventário.
    Então Zero chamadas ao NestedRuleCaller; conteúdo anterior não substituído parcialmente.

  @RECON-H04-05 @ETICS-252611 @ETICS-T8061
  Cenário: RECON-H04-05 — Distinguir chaves por maiúsculas e minúsculas
    # Fonte: H04 RN5–6
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.
      """
    E os seguintes dados de teste:
      """
      Tipo T registrado com chave id; GP tem id=abc; IM retorna id=ABC.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Objeto id=ABC inserido separadamente; id=abc preservado.
    Quando inspecionar o documento final.
    Então Não há conversão de caixa nem colisão entre as duas identidades.

  @RECON-H04-06 @ETICS-252611 @ETICS-T8062
  Cenário: RECON-H04-06 — Não normalizar objectType
    # Fonte: H04 RN6
    # Pendência/observação: Requer dois tipos válidos registrados; não presumir aceitação de tipo desconhecido.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Registro com dois tipos válidos que diferem somente em caixa.
      """
    E os seguintes dados de teste:
      """
      Tipos T e t registrados; GP contém T/id=A; IM retorna t/id=A.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então T/id=A preservado; t/id=A tratado como identidade distinta.
    Quando comparar nomes dos tipos no JSON final.
    Então Caixa original mantida.

  @RECON-H04-07 @ETICS-252611 @ETICS-T8063
  Cenário: RECON-H04-07 — Preservar configurações ausentes na resposta IM
    # Fonte: H04 RN10
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.
      """
    E os seguintes dados de teste:
      """
      GP contém A e B; IM retorna somente atualização de A.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então A atualizado.
    Quando conferir B no GP.
    Então B permanece integralmente, sem exclusão por ausência na resposta.

  @RECON-H04-08 @ETICS-252611 @ETICS-T8064
  Cenário: RECON-H04-08 — Aceitar resposta IM sem objetos HW
    # Fonte: H04 RN1,10
    # Pendência/observação: Quantidade de chamadas para lote vazio não definida; não impor esse resultado.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.
      """
    E os seguintes dados de teste:
      """
      GP com configurações existentes; resposta IM válida sem fragmentos HW.
      """
    Quando executar a reconciliação e consultar resultado.
    Então Ausência de objetos HW não causa erro de parsing.
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Configurações existentes preservadas, sem inserção artificial nem exclusão.

  @RECON-H04-09 @ETICS-252611 @ETICS-T8065
  Cenário: RECON-H04-09 — Combinar com inventário atual no momento da atualização
    # Fonte: H04 contexto; visão §8
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois.
      """
    E os seguintes dados de teste:
      """
      Coletar atualização de A; após coleta, inserir objeto B no GP por operação permitida.
      """
    Quando concluir coleta e inserir B no GP antes de Atualizar inventário.
    Então GP contém B novo; CLOB contém somente fragmentos coletados.
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então A atualizado e B preservado: merge usa documento GP atual, não snapshot da coleta.

  @RECON-H04-10 @ETICS-252611 @ETICS-T8066
  Cenário: RECON-H04-10 — Rejeitar chave inválida sem atualizar equipamento
    # Fonte: H04 RN9
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Contador/spy disponível.
      """
    E os seguintes dados de teste:
      """
      Lote canônico de tipo com chave registrada, mas fragmento sem a chave.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Lote rejeitado por chave inválida.
    Quando verificar GP e contador.
    Então GP preservado; zero chamadas ao NestedRuleCaller.

  @RECON-H05-01 @ETICS-252614 @ETICS-T8067
  Cenário: RECON-H05-01 — Converter cada registry de zona em um objeto
    # Fonte: H05
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H04 e H05 disponíveis; fixture XML validada pelo contrato de zona.
      """
    E os seguintes dados de teste:
      """
      equipment/additionalInfo/group/key=zona com duas registry de zonas distintas e suas interfaces.
      """
    Quando executar reconciliação e consultar CLOB.
    Então Dois fragmentos de zona correspondem às duas registry, preservando a associação de interfaces.
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então As duas zonas são inseridas no mesmo documento JSON do roteador.

  @RECON-H05-02 @ETICS-252614 @ETICS-T8068
  Cenário: RECON-H05-02 — Atualizar zona existente integralmente
    # Fonte: H05; H04 RN5
    # Pendência/observação: Nome da chave de zona depende do contrato técnico referenciado, ainda não acessível.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Chave de zona confirmada no contrato de H05.
      """
    E os seguintes dados de teste:
      """
      Zona já existente; IM retorna mesma identidade com outra lista de interfaces.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Zona substituída pela versão recebida.
    Quando comparar zona e interfaces.
    Então Uma ocorrência para a identidade; lista final igual à recebida, sem merge com interfaces antigas.

  @RECON-H05-03 @ETICS-252614 @ETICS-T8069
  Cenário: RECON-H05-03 — Manter zonas fora da árvore de divergências
    # Fonte: H05
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H05 disponível.
      """
    E os seguintes dados de teste:
      """
      Zona existente no GP com interfaces diferentes das retornadas no IM.
      """
    Quando executar reconciliação e detalhar.
    Então Zona não aparece na árvore de divergências.
    Quando consultar GP antes e depois de Atualizar inventário.
    Então Antes mantém valor original; depois reflete zona recebida.

  @RECON-H05-04 @ETICS-252614 @ETICS-T8070
  Cenário: RECON-H05-04 — Restringir conversor de zona ao grupo zona
    # Fonte: H05 escopo
    # Pendência/observação: No fluxo integrado, outros conversores habilitados podem tratar seus próprios grupos.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Harness do conversor H05.
      """
    E os seguintes dados de teste:
      """
      XML contendo zona, HA, rotas, BGP, OSPF, RIP, port, card, vlan e pseudowire.
      """
    Quando executar o conversor de H05 isoladamente.
    Então Somente registry do grupo zona geram fragmentos.
    Quando inspecionar os fragmentos produzidos.
    Então Nenhum fragmento produzido por H05 para os demais grupos.

  @RECON-H05-05 @ETICS-252614 @ETICS-T8071
  Cenário: RECON-H05-05 — Abortar conjunto de zonas diante de fragmento inválido
    # Fonte: H05 infraestrutura H04
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H04/H05; spy disponível.
      """
    E os seguintes dados de teste:
      """
      Uma zona válida e outra que gere fragmento inválido conforme contrato.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Lote do equipamento rejeitado integralmente.
    Quando consultar GP e spy.
    Então Nenhuma das zonas aplicada; zero chamadas ao NestedRuleCaller.

  @RECON-H06-01 @ETICS-252615 @ETICS-T8072
  Cenário: RECON-H06-01 — Converter os quatro atributos HA de additionalInfo
    # Fonte: H06 exemplo XML
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H04/H06 disponíveis.
      """
    E os seguintes dados de teste:
      """
      group-name=SPO-HA-121; hbdev-1=port1; hbdev-2=port2; monitor=[x3,x4], diretamente em additionalInfo.
      """
    Quando executar reconciliação e inspecionar fragmento.
    Então Configuração device contém os quatro atributos e ambos os valores de monitor.
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Configuração device persistida no campo HW_OBJECTS_JSON do roteador.

  @RECON-H06-02 @ETICS-252615 @ETICS-T8073
  Cenário: RECON-H06-02 — Atualizar device preservando zonas existentes
    # Fonte: H06
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H05/H06 disponíveis.
      """
    E os seguintes dados de teste:
      """
      GP contém device antigo e zona válida; IM retorna novos quatro atributos HA.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Configuração device atualizada no documento compartilhado.
    Quando comparar zona com snapshot.
    Então Zona preservada; não é criado documento paralelo para HA.

  @RECON-H06-03 @ETICS-252615 @ETICS-T8074
  Cenário: RECON-H06-03 — Converter somente os quatro atributos HA previstos
    # Fonte: H06 escopo
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Harness do conversor H06.
      """
    E os seguintes dados de teste:
      """
      additionalInfo com quatro atributos HA e atributo extra; grupos zona/BGP; atributos HA homônimos dentro de port.
      """
    Quando executar conversor H06.
    Então Somente os quatro atributos diretos de equipment/additionalInfo alimentam device.
    Quando inspecionar attributes de device.
    Então Atributo extra, grupos e atributos da porta não foram indevidamente convertidos.

  @RECON-H06-04 @ETICS-252615 @ETICS-T8075
  Cenário: RECON-H06-04 — Persistir HA e zonas no mesmo lote
    # Fonte: H06; H04 RN8
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H04/H05/H06 disponíveis; spy de NestedRuleCaller.
      """
    E os seguintes dados de teste:
      """
      Resposta IM com zona válida e quatro atributos HA válidos.
      """
    Quando executar reconciliação e acionar Atualizar inventário.
    Então Documento final contém zona e device.
    Quando inspecionar chamadas por equipamento.
    Então Uma chamada ao NestedRuleCaller com o documento combinado.

  @RECON-H06-05 @ETICS-252615 @ETICS-T8076
  Cenário: RECON-H06-05 — Substituir lista de interfaces monitoradas
    # Fonte: H06; H04 substituição integral
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H06 disponível.
      """
    E os seguintes dados de teste:
      """
      device contém monitor=[x3,x4]; IM retorna monitor=[x5] e demais atributos HA válidos.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então device atualizado.
    Quando inspecionar monitor.
    Então Lista final contém apenas x5; x3 e x4 não são retidos por merge parcial.

  @RECON-H07-01 @ETICS-252629 @ETICS-T8077
  Cenário: RECON-H07-01 — Inserir rota estática recebida do IM
    # Fonte: H07; visão §6.30
    # Pendência/observação: Fixture XML e objectType canônico ainda dependem do contrato técnico.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H07 disponível; XML e mapeamento de rota aprovados.
      """
    E os seguintes dados de teste:
      """
      Rota de teste: destination-address-mask=192.0.2.0/24, priority=10, ip-address=192.0.2.1; demais campos obrigatórios conforme contrato.
      """
    Quando coletar rota via reconciliação.
    Então GP permanece inalterado antes do comando de atualização.
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Rota recebida está presente no documento JSON do roteador com valores mapeados corretamente.

  @RECON-H07-02 @ETICS-252629 @ETICS-T8078
  Cenário: RECON-H07-02 — Atualizar rota com a mesma chave composta
    # Fonte: H07; visão §6.30
    # Pendência/observação: Confirmar correspondência entre chave do modelo da visão e chave do JSON.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Mapeamento da chave da visão confirmado para H07.
      """
    E os seguintes dados de teste:
      """
      GP e IM com destino 192.0.2.0/24 e prioridade 10; próximo salto muda de 192.0.2.1 para 192.0.2.2.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Rota existente atualizada, sem duplicação.
    Quando verificar destino, prioridade e próximo salto.
    Então Mesma chave composta; próximo salto final 192.0.2.2.

  @RECON-H07-03 @ETICS-252629 @ETICS-T8079
  Cenário: RECON-H07-03 — Distinguir rotas por prioridade
    # Fonte: H07; visão §6.30
    # Pendência/observação: Confirmar chave no contrato do JSON.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. Mapeamento da chave da visão confirmado para H07.
      """
    E os seguintes dados de teste:
      """
      Duas rotas com destino 192.0.2.0/24, prioridades 10 e 20 e próximos saltos distintos.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Duas rotas persistidas.
    Quando conferir identidades e atributos.
    Então Não há colisão por considerar somente o destino; prioridade participa da identidade.

  @RECON-H07-04 @ETICS-252629 @ETICS-T8080
  Cenário: RECON-H07-04 — Atualizar rotas junto das demais configurações
    # Fonte: H07; H04 RN10
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H04–H07 disponíveis.
      """
    E os seguintes dados de teste:
      """
      GP contém device e zona; IM retorna rota estática nova.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Rota inserida no documento compartilhado.
    Quando comparar device e zona com snapshot.
    Então Configurações não alteradas pelo lote permanecem intactas.

  @RECON-H08-01 @ETICS-252632 @ETICS-T8081
  Cenário: RECON-H08-01 — Sincronizar configuração BGP do IM
    # Fonte: H08
    # Pendência/observação: A visão §6.28 marca diversos atributos Discovery=NÃO, enquanto H08 solicita sincronização; confirmar mapeamento antes de executar.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H08 disponível; fixture BGP homologada e mapeamento canônico definido.
      """
    E os seguintes dados de teste:
      """
      Configuração BGP válida para equipamento suportado, com valores distintos do GP.
      """
    Quando executar reconciliação com a resposta controlada.
    Então Coleta concluída sem alterar o documento GP.
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Configuração BGP recebida presente no documento JSON do roteador com os valores previstos no mapeamento.

  @RECON-H08-02 @ETICS-252632 @ETICS-T8082
  Cenário: RECON-H08-02 — Sincronizar configuração OSPF do IM
    # Fonte: H08
    # Pendência/observação: A visão §6.28 marca diversos atributos Discovery=NÃO, enquanto H08 solicita sincronização; confirmar mapeamento antes de executar.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H08 disponível; fixture OSPF homologada e mapeamento canônico definido.
      """
    E os seguintes dados de teste:
      """
      Configuração OSPF válida para equipamento suportado, com valores distintos do GP.
      """
    Quando executar reconciliação com a resposta controlada.
    Então Coleta concluída sem alterar o documento GP.
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Configuração OSPF recebida presente no documento JSON do roteador com os valores previstos no mapeamento.

  @RECON-H08-03 @ETICS-252632 @ETICS-T8083
  Cenário: RECON-H08-03 — Sincronizar configuração RIP do IM
    # Fonte: H08
    # Pendência/observação: A história inclui RIP; detalhamento ausente na visão. Fixture e critérios de mapeamento pendentes.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H08 disponível; fixture RIP homologada e mapeamento canônico definido.
      """
    E os seguintes dados de teste:
      """
      Configuração RIP válida para equipamento suportado, com valores distintos do GP.
      """
    Quando executar reconciliação com a resposta controlada.
    Então Coleta concluída sem alterar o documento GP.
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Configuração RIP recebida presente no documento JSON do roteador com os valores previstos no mapeamento.

  @RECON-H08-04 @ETICS-252632 @ETICS-T8084
  Cenário: RECON-H08-04 — Sincronizar BGP, OSPF e RIP no mesmo equipamento
    # Fonte: H08; H04 RN7–8
    # Pendência/observação: Confirmar cardinalidade e identidade de cada protocolo no contrato.
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H08 e os três contratos de conversão disponíveis; spy.
      """
    E os seguintes dados de teste:
      """
      IM retorna configurações válidas de BGP, OSPF e RIP para equipamento suportado.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então As três configurações são aplicadas ao documento JSON do equipamento.
    Quando inspecionar configurações e chamadas.
    Então Nenhum protocolo sobrescreve outro indevidamente; uma chamada final por equipamento.

  @RECON-H08-05 @ETICS-252632 @ETICS-T8085
  Cenário: RECON-H08-05 — Preservar rotas estáticas, zonas e HA ao atualizar protocolo
    # Fonte: H08; H04 RN10
    Dado o seguinte contexto de teste:
      """
      Ambiente de teste GP/IM; usuário autorizado; roteador pareado sem divergência física; modelo reconciliável; resposta IM controlada; registrar inventário antes e depois. H04–H08 disponíveis.
      """
    E os seguintes dados de teste:
      """
      GP contém rota estática, zona, device e protocolo; IM altera somente o protocolo.
      """
    Quando acionar Atualizar inventário e consultar novamente o roteador no ISP.
    Então Protocolo atualizado.
    Quando comparar os demais objetos com snapshot.
    Então Rotas estáticas, zonas e HA preservados integralmente.

