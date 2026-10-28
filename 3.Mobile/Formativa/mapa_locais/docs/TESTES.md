# Testes e evidências

Data: 28/10/2026. Os testes desta etapa usam armazenamento local. Nenhum resultado abaixo comprova conexão com o Firebase.

## Verificações automatizadas

A suíte `test/app_test.dart` contém 20 testes: modelo e conversão de números; 15 exemplos em três cidades; busca por nome/categoria sem acentos; filtros e ordenação; validação de campos e decimais; CRUD/favoritos com reabertura do repositório; unicidade de IDs em operações concorrentes; manutenção de uma base vazia; recuperação após falha de gravação; oito tamanhos de tela (320x568, 320x640, 360x800, 390x844, 430x932, 768x1024, 844x390 e 1366x900), incluindo cinco marcadores, perfil, seleção de cidade e galeria; pesquisa/cidade/estado vazio; favoritos na interface; cadastro/edição/cancelamento/confirmação de exclusão pela interface; erro de leitura com nova tentativa.

O armazenamento dos testes Dart é substituído por memória para controlar falhas. A persistência efetiva do navegador também foi conferida com Chrome e Playwright: três telas renderizadas, favorito gravado no localStorage, reload e recuperação pelo filtro Favoritos, sem pageerrors. O teste de navegador usa um contexto isolado e não modifica dados de um perfil pessoal.

Comandos e resultados finais constam também em `VALIDACAO.txt`.

## Roteiro obrigatório do enunciado

| ID | Procedimento | Resultado nesta etapa | Validação Firebase |
| --- | --- | --- | --- |
| T01 | Abrir e verificar dados do Firestore | Catálogo local funciona | Pendente: conexão real |
| T02 | Pesquisar Academia | Aprovado nos testes locais | Repetir com dados remotos |
| T03 | Selecionar Campinas | Aprovado nos testes locais | Repetir com dados remotos |
| T04 | Selecionar categoria | Aprovado no teste de filtros | Repetir com dados remotos |
| T05 | Cadastrar e verificar no Firestore | Cadastro local aprovado na interface | Pendente: conferir Console |
| T06 | Fechar/reabrir e verificar registro | Repositório reaberto; favorito também preservado após reload do navegador | Pendente: persistência remota |
| T07 | Editar nome ou horário | Edição de nome aprovada na interface | Pendente: conferir Console |
| T08 | Excluir e conferir ausência | Cancelamento e confirmação aprovados na interface | Pendente: conferir Console |
| T09 | Marcar/desmarcar favorito | Aprovado; persistência Web também verificada | Pendente: campo remoto |
| T10 | Abrir resultados, detalhes e retornar | Aprovado em três resoluções; Ver no mapa retorna ao marcador | Repetir no Android conectado |
| T11 | Simular ausência de dados/erro | Busca vazia, falha de leitura e recuperação aprovadas; falha de gravação não publica alteração | Pendente: erro de rede/permissão remota |

## Capturas

- `capturas/01-mapa.png`: entrada, seleção de cidade, pesquisa e marcadores.
- `capturas/02-resultados.png`: filtros e lista de estabelecimentos.
- `capturas/03-detalhes.png`: informações do local.

São capturas reais da versão Web local, em viewport 390x860 com escala 2. Não são capturas de um telefone físico. A tela de detalhes é rolável em alturas menores. O botão Ver no mapa e a navegação ficam na área inferior fixa.

## Pendências finais

- Configuração FlutterFire CLI e habilitação dos serviços no projeto escolhido.
- Revisão/publicação das regras e autorização da instalação da apresentação.
- Carga de no mínimo dez documentos e captura do Console.
- Repetição de T01 a T11 na entrada Firebase.
- Execução e conferência visual em aparelho/emulador Android; nenhum dispositivo Android estava conectado nesta etapa.
- O modelo `firestore.rules.example` e a carga Firebase ainda não foram executados contra um serviço real/emulador.


A revisão visual foi comparada com a imagem fornecida pelo usuário. A migração conservadora dos exemplos também possui teste de preservação de edições, favoritos, exclusões e cópia anterior.
