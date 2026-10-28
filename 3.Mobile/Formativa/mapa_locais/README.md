# Perto - mapa de locais

Aplicativo Flutter da avaliação, com as três telas do wireframe: mapa, resultados e detalhes. A revisão atual reproduz a paleta cinza, as miniaturas neutras, os cartões compactos e a barra Mapa / Favoritos / Perfil da referência.

## Executar agora (sem Firebase)

Abra esta pasta no VS Code e execute F5, ou:

```powershell
.\iniciar.ps1
# Para um Android conectado/emulador:
.\iniciar.ps1 -Dispositivo ID_DO_DISPOSITIVO
```

Também é possível usar `flutter pub get` e `flutter run` com Flutter 3.47.6 / Dart 3.13.5 ou versão compatível. O SDK selecionado está em `.vscode/settings.json`; o script usa o SDK existente nesta máquina.

## O que funciona localmente

- Mapa ilustrativo com marcadores selecionáveis e seleção de São Paulo, Campinas e Jundiaí.
- 15 estabelecimentos fictícios (cinco por cidade), carregados no primeiro uso. São Paulo contém Academia Fitness, Smart Fit, Body Center, Proforma Academia e Iron Gym, como na referência.
- Pesquisa por nome ou categoria, ignorando caixa e acentos.
- Filtros de cidade, categoria e favoritos; ordenação por distância, avaliação ou nome.
- Cadastro e edição em formulário, confirmação de exclusão, mensagens e bloqueio de envio duplicado.
- Detalhes com imagem neutra, galeria deslizante, categoria, avaliação, distância, horário, descrição e ações da referência.
- Favoritos e alterações persistidos no dispositivo/navegador; reabrir mantém os registros.
- Botão Ver no mapa retorna ao mapa e seleciona o estabelecimento, inclusive de outra cidade.
- Estados de carregamento, lista vazia, erro e recuperação.

O modo local usa SharedPreferencesAsync para um pequeno conjunto didático. No navegador, os dados ficam vinculados à origem (host/porta); limpar os dados do navegador remove os registros. Não há sincronização com a nuvem. Apagar todos os locais mantém o banco vazio: os exemplos não são reinseridos automaticamente.

As ilustrações são desenhadas pelo próprio Flutter. O mapa é esquemático, não fornece geolocalização ou rotas. Avaliações, distâncias, nomes e endereços iniciais são fictícios. A distância é informada manualmente no cadastro. O PDF torna mapa real uma extensão opcional.

## Como usar a interface

- Cidade: toque no nome ou no seletor para escolher São Paulo, Campinas ou Jundiaí.
- Pesquisa: digite e pressione a lupa ou Pesquisar no teclado para abrir os resultados.
- Mapa: arraste ou amplie; os marcadores selecionam o local e o rótulo abre os detalhes. Centralizar e Camadas ficam à direita.
- Cadastro: Perfil > Novo local, ou botão Novo local no final da lista.
- Edição/exclusão: pressione um cartão por alguns instantes; nos detalhes, pressione a imagem ou use Perfil > Gerenciar este local.
- Favoritos: coração nos detalhes; a aba Favoritos mostra os registros salvos.
- Fotos: deslize a imagem, toque nos indicadores ou abra Ver todas. As imagens são as miniaturas neutras do wireframe, sem fotos externas.
- Compartilhar: copia as informações para a área de transferência. Ligar informa quando não há telefone cadastrado. Como chegar retorna ao mapa ilustrativo.
- Agendar: salva um lembrete local de visita, consultável em Perfil > Meus lembretes. Não efetua reserva nem agenda notificações no sistema.

## Responsividade e preservação

A composição ocupa a largura do telefone e é centralizada com limite de 430 px em telas amplas. Listas e detalhes rolam quando a altura é pequena; formulários e seletores têm rolagem própria. A galeria se ajusta também em paisagem. A barra inferior permanece acessível nas três telas.

Foram verificados os tamanhos 320x568, 320x640, 360x800, 390x844, 430x932, 768x1024, 844x390 e 1366x900, com navegação, cinco marcadores, perfil, seleção de cidade e galeria. O favicon e os ícones Web têm fundo preto, com versão na URL para renovar o cache.

A atualização dos exemplos só substitui registros originais sem edição e preserva seus favoritos. Cadastros, exclusões e edições do usuário são mantidos. Antes de migrar os exemplos já salvos, o armazenamento guarda uma cópia em `perto.backup.before-reference.v1`. A versão anterior dos fontes também está em `../backups/Perto-antes-do-wireframe.zip`.

## Organização

- `lib/models`: modelo Local, pesquisa/filtros, ordenação e validação.
- `lib/data`: dados de exemplo.
- `lib/services`: contrato de armazenamento e implementações local/Firestore.
- `lib/screens`: mapa, resultados e detalhes.
- `lib/widgets`: formulário, cartões, favoritos, ilustrações e mapa.
- `lib/dialogs`: confirmação e tratamento de falhas na exclusão.
- `test`: persistência, filtros, validações e fluxos da interface.
- `docs`: documentação da atividade, configuração final do Firebase, testes e capturas.

A interface recebe um LocalRepository. Não contém consultas de banco. Todos os repositórios expõem o mesmo Stream de locais e os métodos salvar/excluir/favoritar. Uma atualização bem-sucedida reflete nas telas abertas.

## Verificação

```powershell
flutter analyze
flutter test
flutter build web --release
flutter build apk --debug --target-platform android-arm64
```

Consulte `docs/TESTES.md` para os resultados efetivamente verificados e as pendências de Firebase. A configuração do projeto remoto, as regras publicadas, a carga inicial no Firestore e os testes contra a nuvem ficam para a etapa final, conforme solicitado.
