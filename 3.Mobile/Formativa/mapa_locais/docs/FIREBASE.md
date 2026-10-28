# Etapa final: Firebase

Status em 28/10/2026: o projeto remoto NÃO foi configurado nesta atividade. O aplicativo padrão usa dados locais. As dependências e o adaptador Firestore estão preparados; a integração precisa de configuração e validação reais.

## 1. Configurar quando for a hora de conectar

Na pasta do aplicativo, usando o mesmo SDK configurado no VS Code:

```powershell
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Instale a Firebase CLI caso `firebase` ainda não esteja disponível. Escolha o projeto desejado e Android (Web também, se for demonstrar no navegador). O pacote Android é `br.com.atividade.mapa_locais`. O CLI deve substituir `lib/firebase_options.dart` pelo arquivo gerado e configurar os arquivos de plataforma. O arquivo atual só avisa que a configuração está pendente: não contém chaves inventadas. Não reaproveite configurações de outro projeto por suposição.

No Console, habilite Cloud Firestore e Authentication > método Anônimo. O login anônimo é usado somente para obter uma identidade da instalação de demonstração. Autenticação sozinha não concede permissão administrativa.

## 2. Autorizar explicitamente a instalação de demonstração

Execute a entrada preparada:

```powershell
flutter run -t lib/main_firebase.dart
```

O log do Flutter informa `Perto - UID de demonstração: ...`. Essa identidade precisa ser autorizada no modelo de regras `firestore.rules.example`. O modelo bloqueia acesso enquanto o UID de exemplo não for substituído. Não publique regras permitindo escrita para qualquer pessoa ou para qualquer sessão anônima.

Revise o modelo, substitua o UID, copie-o para as regras do projeto e publique somente nessa etapa final, no projeto escolhido. Cada instalação/navegador tem uma identidade distinta; outras instalações precisam de autorização separada. A limpeza dos dados pode gerar nova identidade. Essa estratégia é uma restrição simples para apresentação escolar, não um painel de gestão de usuários. Login e papéis de usuário seriam uma evolução.

O adaptador usa exatamente a coleção `locais`: `snapshots()` na leitura, `add()` no cadastro, `update()` na edição/favoritos e `delete()` na exclusão. Os erros são apresentados nas telas. Não existe fallback silencioso para os dados locais se o Firestore falhar.

## 3. Carga inicial

Os 15 documentos fictícios estão em `docs/locais-exemplo.json`. O arquivo é uma referência de campos/valores, não um backup Firestore para `gcloud import`. No Console é possível cadastrar os documentos manualmente, ou usar a carga abaixo após autorizar a instalação.

```powershell
flutter run -t lib/main_seed_firebase.dart
```

Essa entrada é uma ferramenta de desenvolvimento separada. Mostra uma confirmação dentro do aplicativo; só insere dados quando a coleção está vazia e usa IDs determinísticos com transação para evitar duplicação concorrente. Não substitui os dados locais nem migra automaticamente alterações feitas no modo local. Cadastre/edite os registros reais pela interface depois da conexão.

## 4. Validar antes da entrega

1. Abrir a entrada Firebase e verificar o selo Firestore nas telas.
2. Conferir os documentos no Console (mínimo 10).
3. Executar T01 a T11 de `TESTES.md`, incluindo CRUD com confirmação no Console.
4. Fechar/reabrir o aplicativo e verificar a persistência remota.
5. Testar negação de acesso com UID não autorizado.
6. Capturar as três telas no modo conectado e o Console com os documentos. Não apresentar capturas do modo local como prova do Firestore.

Para continuar trabalhando sem conexão, use `flutter run` (entrada padrão `lib/main.dart`).

Fontes oficiais consultadas: [configuração FlutterFire](https://firebase.google.com/docs/flutter/setup), [gravação de documentos](https://firebase.google.com/docs/firestore/manage-data/add-data), [persistência local Flutter](https://docs.flutter.dev/cookbook/persistence/key-value).
