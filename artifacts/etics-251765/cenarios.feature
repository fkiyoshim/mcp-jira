# language: pt
Funcionalidade: HU-38 - Corrigir inventário do Lance de Cabo Óptico

  # CT01; §4 (escopo adicional), §7.2 e histórico da versão 01.01
  Cenário: ETICS-251765 | HU-38 | CT01 | Editar todos os atributos não bloqueados em lance Existente
    Dado um Lance de Cabo Óptico na situação Existente e nenhuma OT corrente
    E a matriz de atributos do lance foi conferida contra o modelo e a configuração da versão, identificando todos os atributos não bloqueados e seus valores válidos
    Quando abrir Corrigir inventário
    Então todos os atributos classificados como não bloqueados na matriz permitem edição, inclusive os adicionais à lista original da seção 7.2
    Quando alterar cada atributo não bloqueado com um valor válido, salvar e consultar novamente o lance após cada alteração
    Então cada valor informado permanece gravado no respectivo atributo
    E os atributos não alterados preservam seus valores e a situação permanece Existente
    E a correção não cria vínculo do lance com uma OT

  # CT02; §4, §6.2 e §7.2
  Cenário: ETICS-251765 | HU-38 | CT02 | Editar atributos adicionais em lance Projetado/Modificação
    Dado um Lance de Cabo Óptico na situação Projetado/Modificação vinculado à OT A
    E não há OT definida como corrente
    E a matriz de atributos identifica os campos não bloqueados adicionais à lista original da seção 7.2
    Quando alterar cada campo adicional por Corrigir inventário com um valor válido e salvar
    Então cada alteração persiste ao consultar novamente o lance
    E a situação continua Projetado/Modificação e o vínculo original com a OT A é preservado
    E a correção é registrada sem associação a uma OT

  # CT03; HU-38, §4 e §7.2
  Cenário: ETICS-251765 | HU-38 | CT03 | Manter atributos bloqueados protegidos
    Dado um Lance de Cabo Óptico com valores registrados nos atributos classificados como bloqueados pelo modelo e pela configuração
    Quando abrir Corrigir inventário e verificar cada atributo bloqueado
    Então a operação não permite editar esses atributos
    Quando alterar um atributo não bloqueado com valor válido e salvar
    Então todos os atributos bloqueados mantêm os valores anteriores

  # CT04; §7.2
  Cenário: ETICS-251765 | HU-38 | CT04 | Preservar edição de Rota
    Dado um Lance de Cabo Óptico Existente e nenhuma OT corrente
    E há um valor válido para Rota diferente do valor atual, respeitando os cadastros e dependências existentes
    Quando alterar Rota por Corrigir inventário para o novo valor válido e salvar
    Então Rota apresenta o novo valor ao consultar novamente o lance
    E a situação permanece Existente e os demais atributos não envolvidos na regra da alteração preservam seus valores

  # CT05; §7.2
  Cenário: ETICS-251765 | HU-38 | CT05 | Preservar edição de Comprimento Real Total (m)
    Dado um Lance de Cabo Óptico Existente e nenhuma OT corrente
    E o Comprimento Real Total (m) é 10,00 e o novo valor válido é 20,00
    Quando alterar Comprimento Real Total (m) por Corrigir inventário para o novo valor válido e salvar
    Então Comprimento Real Total (m) apresenta o novo valor ao consultar novamente o lance
    E a situação permanece Existente e os demais atributos não envolvidos na regra da alteração preservam seus valores

  # CT06; §7.2
  Cenário: ETICS-251765 | HU-38 | CT06 | Preservar edição de Propriedade
    Dado um Lance de Cabo Óptico Existente e nenhuma OT corrente
    E há um valor válido para Propriedade diferente do valor atual, respeitando os cadastros e dependências existentes
    Quando alterar Propriedade por Corrigir inventário para o novo valor válido e salvar
    Então Propriedade apresenta o novo valor ao consultar novamente o lance
    E a situação permanece Existente e os demais atributos não envolvidos na regra da alteração preservam seus valores

  # CT07; §7.2
  Cenário: ETICS-251765 | HU-38 | CT07 | Preservar edição de Proprietário
    Dado um Lance de Cabo Óptico Existente e nenhuma OT corrente
    E há um valor válido para Proprietário diferente do valor atual, respeitando os cadastros e dependências existentes
    Quando alterar Proprietário por Corrigir inventário para o novo valor válido e salvar
    Então Proprietário apresenta o novo valor ao consultar novamente o lance
    E a situação permanece Existente e os demais atributos não envolvidos na regra da alteração preservam seus valores

  # CT08; §7.2
  Cenário: ETICS-251765 | HU-38 | CT08 | Preservar edição de Tipo de Rede
    Dado um Lance de Cabo Óptico Existente e nenhuma OT corrente
    E há um valor válido para Tipo de Rede diferente do valor atual, respeitando os cadastros e dependências existentes
    Quando alterar Tipo de Rede por Corrigir inventário para o novo valor válido e salvar
    Então Tipo de Rede apresenta o novo valor ao consultar novamente o lance
    E a situação permanece Existente e os demais atributos não envolvidos na regra da alteração preservam seus valores

  # CT09; §7.2
  Cenário: ETICS-251765 | HU-38 | CT09 | Preservar edição de Observações
    Dado um Lance de Cabo Óptico Existente e nenhuma OT corrente
    E há um valor válido para Observações diferente do valor atual, respeitando os cadastros e dependências existentes
    Quando alterar Observações por Corrigir inventário para o novo valor válido e salvar
    Então Observações apresenta o novo valor ao consultar novamente o lance
    E a situação permanece Existente e os demais atributos não envolvidos na regra da alteração preservam seus valores

  # CT10; §7.2
  Cenário: ETICS-251765 | HU-38 | CT10 | Preservar edição de Configuração de Cor
    Dado um Lance de Cabo Óptico Existente e nenhuma OT corrente
    E há um valor válido para Configuração de Cor diferente do valor atual, respeitando os cadastros e dependências existentes
    Quando alterar Configuração de Cor por Corrigir inventário para o novo valor válido e salvar
    Então Configuração de Cor apresenta o novo valor ao consultar novamente o lance
    E a situação permanece Existente e os demais atributos não envolvidos na regra da alteração preservam seus valores

  # CT11; §7.2 e §6.2.3
  Cenário: ETICS-251765 | HU-38 | CT11 | Preservar edição de Tipo
    Dado um Lance de Cabo Óptico Existente e nenhuma OT corrente
    E há um tipo alternativo válido com a mesma quantidade de fibras do tipo atual
    Quando alterar Tipo por Corrigir inventário para o novo valor válido e salvar
    Então Tipo apresenta o novo valor ao consultar novamente o lance
    E a situação permanece Existente e os demais atributos não envolvidos na regra da alteração preservam seus valores

  # CT12; §7.2
  Cenário: ETICS-251765 | HU-38 | CT12 | Ignorar OT corrente na correção
    Dado um lance Projetado/Modificação vinculado à OT A
    E um atributo não bloqueado possui valor válido para correção
    Quando definir a própria OT A como corrente, corrigir o atributo e salvar
    Então a correção persiste sem associação à OT corrente e mantém a situação e o vínculo original do lance
    Quando repetir em dados independentes com uma OT B diferente da OT A definida como corrente
    Então a correção também persiste sem associação à OT B e mantém a situação e o vínculo original do lance

  # CT13; §7.2
  Cenário: ETICS-251765 | HU-38 | CT13 | Manter validações de consistência dos campos
    Dado a matriz de atributos não bloqueados contém as regras de consistência vigentes e exemplos de valores inválidos
    E os valores persistidos do lance foram registrados antes da tentativa
    Quando tentar salvar por Corrigir inventário um valor que viola uma regra vigente, repetindo para cada regra aplicável
    Então o sistema apresenta a validação correspondente e impede persistir o valor inválido
    E o atributo permanece com seu valor anterior ao consultar novamente o lance
    Quando informar um valor válido para o mesmo atributo e salvar
    Então o valor válido persiste

  # CT14; §6.2.3 e regras detalhadas do §7.2
  Cenário: ETICS-251765 | HU-38 | CT14 | Alterar tipo conectado com capacidade igual
    Dado um lance conectado de tipo com 12 fibras, com identificadores, contagens e conexões registrados
    E existe um tipo alternativo válido com 12 fibras
    Quando solicitar por Corrigir inventário a mudança para o tipo de 12 fibras e salvar
    Então o tipo é alterado para o novo tipo de 12 fibras
    E as 12 fibras existentes preservam seus identificadores, contagens e conexões
    Quando consultar novamente o lance e suas fibras
    Então o estado persistido corresponde ao resultado verificado

  # CT15; §6.2.3 e regras detalhadas do §7.2
  Cenário: ETICS-251765 | HU-38 | CT15 | Alterar tipo conectado com capacidade maior
    Dado um lance conectado de tipo com 12 fibras, com identificadores, contagens e conexões registrados
    E existe um tipo alternativo válido com 24 fibras
    Quando solicitar por Corrigir inventário a mudança para o tipo de 24 fibras e salvar
    Então o tipo é alterado para o novo tipo de 24 fibras
    E as fibras de 1 a 12 preservam seus identificadores, contagens e conexões
    E somente as fibras faltantes de 13 a 24 são criadas automaticamente
    E as novas fibras ficam disponíveis para criação manual de contagem e conexão, sem herdar automaticamente as contagens e conexões existentes
    Quando consultar novamente o lance e suas fibras
    Então o estado persistido corresponde ao resultado verificado

  # CT16; §6.2.3 e regras detalhadas do §7.2
  Cenário: ETICS-251765 | HU-38 | CT16 | Alterar tipo conectado com capacidade menor
    Dado um lance conectado de tipo com 12 fibras, com identificadores, contagens e conexões registrados
    E existe um tipo alternativo válido com 6 fibras
    Quando solicitar por Corrigir inventário a mudança para o tipo de 6 fibras e salvar
    Então o sistema apresenta uma mensagem de erro e impede a alteração
    E o tipo original de 12 fibras permanece
    E nenhuma fibra, contagem ou conexão existente é removida ou alterada
    Quando consultar novamente o lance e suas fibras
    Então o estado persistido corresponde ao resultado verificado

  # CT17; §6.2.1, §6.2.2 e §7.2
  Cenário: ETICS-251765 | HU-38 | CT17 | Registrar histórico da correção
    Dado um lance com um atributo não bloqueado de valor anterior conhecido e usuário autorizado identificado
    Quando corrigir o atributo para um novo valor válido e salvar
    Então o histórico registra Corrigir inventário, atributo, valor anterior e novo valor
    E registra o usuário responsável e a data e hora compatíveis com a operação
    E o registro da correção não fica associado a uma OT
    Quando consultar novamente o histórico do lance
    Então o registro permanece disponível com os mesmos dados

  # CT18; §6.2.1 e §7.2
  Cenário: ETICS-251765 | HU-38 | CT18 | Preservar correção em atributo distinto ao implantar ot
    Dado um lance com Lote de Fabricação 123 e Rota XYZ
    E Modificar atributos com a OT A alterou Lote de Fabricação para 456
    Quando executar Corrigir inventário sem OT e alterar Rota para ABC
    E executar Implantar OT para a OT A
    Então a Rota permanece ABC
    E Lote de Fabricação fica 456
    E o histórico preserva as alterações e registra Implantar OT com usuário e data/hora
    Quando repetir com dados independentes executando a correção de Rota antes da alteração com OT
    Então os valores finais são os mesmos para a respectiva operação de OT

  # CT19; §6.2.1 e §7.2
  Cenário: ETICS-251765 | HU-38 | CT19 | Preservar correção em atributo distinto ao cancelar ot
    Dado um lance com Lote de Fabricação 123 e Rota XYZ
    E Modificar atributos com a OT A alterou Lote de Fabricação para 456
    Quando executar Corrigir inventário sem OT e alterar Rota para ABC
    E executar Cancelar OT para a OT A
    Então a Rota permanece ABC
    E Lote de Fabricação fica 123
    E o histórico preserva as alterações e registra Cancelar OT com usuário e data/hora
    Quando repetir com dados independentes executando a correção de Rota antes da alteração com OT
    Então os valores finais são os mesmos para a respectiva operação de OT

  # CT20; §6.2.1 e §7.2
  Cenário: ETICS-251765 | HU-38 | CT20 | Preservar correção em atributo distinto ao desfazer alterações de ot
    Dado um lance com Lote de Fabricação 123 e Rota XYZ
    E Modificar atributos com a OT A alterou Lote de Fabricação para 456
    Quando executar Corrigir inventário sem OT e alterar Rota para ABC
    E executar Desfazer alterações de OT para a OT A
    Então a Rota permanece ABC
    E Lote de Fabricação fica 123
    E o histórico preserva as alterações e registra Desfazer alterações de OT com usuário e data/hora
    Quando repetir com dados independentes executando a correção de Rota antes da alteração com OT
    Então os valores finais são os mesmos para a respectiva operação de OT

  # CT21; §6.2.2 e §7.2
  Cenário: ETICS-251765 | HU-38 | CT21 | Preservar última correção no mesmo atributo ao implantar ot
    Dado um lance com Comprimento Real Total (m) igual a 10,00
    E Modificar atributos com a OT A alterou o comprimento para 15,00
    Quando executar Corrigir inventário sem OT e alterar o comprimento de 15,00 para 20,00
    E executar Implantar OT para a OT A
    Então o Comprimento Real Total (m) permanece 20,00
    E o histórico de Corrigir inventário mantém a alteração de 15,00 para 20,00 sem reescrever o valor anterior
    E o histórico registra Implantar OT com usuário responsável e data/hora

  # CT22; §6.2.2 e §7.2
  Cenário: ETICS-251765 | HU-38 | CT22 | Preservar última correção no mesmo atributo ao cancelar ot
    Dado um lance com Comprimento Real Total (m) igual a 10,00
    E Modificar atributos com a OT A alterou o comprimento para 15,00
    Quando executar Corrigir inventário sem OT e alterar o comprimento de 15,00 para 20,00
    E executar Cancelar OT para a OT A
    Então o Comprimento Real Total (m) permanece 20,00
    E o histórico de Corrigir inventário mantém a alteração de 15,00 para 20,00 sem reescrever o valor anterior
    E o histórico registra Cancelar OT com usuário responsável e data/hora

  # CT23; §6.2.2 e §7.2
  Cenário: ETICS-251765 | HU-38 | CT23 | Preservar última correção no mesmo atributo ao desfazer alterações de ot
    Dado um lance com Comprimento Real Total (m) igual a 10,00
    E Modificar atributos com a OT A alterou o comprimento para 15,00
    Quando executar Corrigir inventário sem OT e alterar o comprimento de 15,00 para 20,00
    E executar Desfazer alterações de OT para a OT A
    Então o Comprimento Real Total (m) permanece 20,00
    E o histórico de Corrigir inventário mantém a alteração de 15,00 para 20,00 sem reescrever o valor anterior
    E o histórico registra Desfazer alterações de OT com usuário responsável e data/hora

  # CT24; §6.2.2
  Cenário: ETICS-251765 | HU-38 | CT24 | Corrigir atributo após implantação da OT
    Dado um lance com Comprimento Real Total (m) igual a 10,00
    E Modificar atributos com a OT A alterou o comprimento para 15,00
    Quando implantar a OT A e depois executar Corrigir inventário sem OT alterando o comprimento para 20,00
    Então o comprimento persistido é 20,00 e o lance permanece Existente
    E o histórico apresenta Modificar atributos 10,00 para 15,00, Implantar OT e Corrigir inventário 15,00 para 20,00 nessa ordem

  # CT25; §6.2.2
  Cenário: ETICS-251765 | HU-38 | CT25 | Respeitar alteração por OT posterior à correção
    Dado um lance Existente com Comprimento Real Total (m) igual a 10,00
    Quando executar Corrigir inventário sem OT alterando o comprimento para 20,00
    E executar Modificar atributos com a OT A alterando o comprimento de 20,00 para 15,00
    E implantar a OT A
    Então o comprimento persistido é 15,00
    E o histórico apresenta Corrigir inventário 10,00 para 20,00, Modificar atributos 20,00 para 15,00 e Implantar OT nessa ordem

  # CT26; §4 (escopo adicional) e §7.2
  Cenário: ETICS-251765 | HU-38 | CT26 | Disponibilizar operação ao perfil autorizado
    Dado um usuário associado ao perfil específico informado pela CLARO para Corrigir inventário
    E existe um lance elegível e um atributo não bloqueado com valor válido para alteração
    Quando acessar o lance com esse usuário e executar Corrigir inventário
    Então a operação está disponível e permite salvar a alteração válida
    E o valor persiste e o histórico identifica o usuário responsável

  # CT27; §4 (escopo adicional) e §7.2
  Cenário: ETICS-251765 | HU-38 | CT27 | Impedir operação para usuário sem perfil autorizado
    Dado um usuário que pode consultar o lance mas não pertence ao perfil autorizado para Corrigir inventário
    E os valores atuais do lance foram registrados
    Quando acessar as operações do lance com esse usuário
    Então Corrigir inventário não está disponível para execução
    E o usuário não consegue gravar uma correção por essa operação
    E os valores persistidos do lance permanecem inalterados
