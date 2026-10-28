# Perto: documentação da atividade

## Problemática e objetivo

Quem procura serviços em uma cidade precisa comparar estabelecimentos, consultar informações e guardar opções de interesse. O Perto reúne seleção de cidade, pesquisa, resultados e detalhes em um fluxo de três telas. O cadastro, a edição e a exclusão permitem manter o catálogo atualizado.

Nesta etapa, a interface e a lógica funcionam com armazenamento local persistente. A avaliação exige Cloud Firestore para a entrega final; essa parte permanece pendente por decisão do pedido atual.

## Requisitos funcionais

| ID | Requisito | Situação nesta etapa |
| --- | --- | --- |
| RF01 | Selecionar São Paulo, Campinas e Jundiaí | Implementado |
| RF02 | Pesquisar por nome ou categoria | Implementado; ignora acentos e caixa |
| RF03 | Consultar Firestore | Adaptador pronto; configuração e validação pendentes |
| RF04 | Filtrar por cidade e categoria | Implementado; inclui favoritos e ordenação |
| RF05 | Cadastrar local | Funciona localmente; gravação remota pendente |
| RF06 | Editar local existente | Funciona localmente; gravação remota pendente |
| RF07 | Excluir após confirmação | Funciona localmente; gravação remota pendente |
| RF08 | Consultar detalhes | Implementado, com atualizações do registro |
| RF09 | Alterar favorito | Funciona localmente; gravação remota pendente |
| RF10 | Navegar entre mapa, resultados e detalhes | Implementado; Ver no mapa seleciona o registro |

## Requisitos não funcionais e tecnologias

Flutter/Dart, Material 3, idioma português, pastas por responsabilidade, validação dos formulários, mensagens de sucesso/erro, estados de carregamento e bloqueio de operações duplicadas. Android e Web são as plataformas geradas. A interface segue diretamente o wireframe em cinza, com a barra Mapa / Favoritos / Perfil: cidade e pesquisa acima do mapa, cartões nos resultados, imagem ilustrada e informações completas nos detalhes. Mapa real é uma extensão opcional do enunciado.

O modo local usa SharedPreferencesAsync. A etapa remota usa firebase_core, cloud_firestore, firebase_auth e configuração via FlutterFire CLI. Não foram usadas fotos externas, APIs de mapa ou rastreamento de localização. As ilustrações são locais, desenhadas com Canvas do Flutter.

## Arquitetura

As telas recebem um LocalRepository e consomem Stream<List<Local>>. O DeviceLocalRepository persiste uma lista JSON e publica alterações somente depois que o salvamento termina. As gravações são serializadas para não perder alterações simultâneas. O FirestoreLocalRepository implementa o mesmo contrato e escuta snapshots da coleção locais. Assim, a troca de armazenamento não altera os fluxos da interface.

A entrada padrão é main.dart, totalmente local. main_firebase.dart é a entrada opcional que inicializa Firebase e uma identidade anônima, sujeita às regras restritivas da demonstração. Falhas de configuração não são mascaradas como sucesso local.

## Modelo da coleção locais

O ID é a chave do documento; não faz parte do conteúdo no Firestore.

| Campo | Tipo | Significado |
| --- | --- | --- |
| nome | String | Nome do estabelecimento |
| categoria | String | Academia, Café, Restaurante, Hospital, Parque ou Cultura |
| cidade | String | São Paulo, Campinas ou Jundiaí |
| avaliacao | Number | De 0 a 5 |
| distancia | Number | Quilômetros, a partir de zero; valor informado |
| horario | String | Horário informado |
| descricao | String | Apresentação do local |
| favorito | Boolean | Favorito do documento, conforme a versão básica do exercício |
| endereco | String | Endereço informado |
| avaliacoes | Number | Quantidade informativa de avaliações da demonstração |
| mapaX, mapaY | Number | Coordenadas normalizadas do mapa ilustrativo; não são latitude/longitude |

Os favoritos são um campo compartilhado do documento na versão básica. Favoritos por usuário são uma extensão, conforme o enunciado.

## Operações CRUD

- Create: o formulário valida os campos e envia o Local sem ID; o repositório gera o identificador.
- Read: cada tela observa o catálogo; pesquisa e filtros são aplicados em memória, como permite o tutorial.
- Update: o mesmo formulário recebe os valores atuais e preserva ID/favorito; o documento existente é alterado.
- Delete: o diálogo informa o nome, permite cancelar e só exclui depois de confirmar.
- Favorito: altera apenas favorito; os detalhes e a lista recebem a atualização.

Os valores decimais aceitam vírgula ou ponto. Avaliações fora de 0 a 5, distâncias negativas, NaN, infinito e campos obrigatórios vazios são recusados. Se houver erro ao salvar, os campos são mantidos para nova tentativa.

## Evidências, testes e conclusão

Consulte TESTES.md e a pasta capturas. Os fluxos locais antecipam o trabalho de interface e lógica. A avaliação completa só poderá ser considerada concluída após configuração FlutterFire, regras revisadas, pelo menos dez documentos no Firestore, testes contra a nuvem e captura do Console. Validação no aparelho Android também deve ser distinguida da compilação do APK e dos testes de widgets.
