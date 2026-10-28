import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapa_locais/widgets/local_card.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mapa_locais/app.dart';
import 'package:mapa_locais/data/demo_locais.dart';
import 'package:mapa_locais/models/local.dart';
import 'package:mapa_locais/models/validators.dart';
import 'package:mapa_locais/services/local_repository.dart';

class MemoryPreferences implements LocalStorage {
  final Map<String, String> values = {};
  bool fail = false;
  @override
  Future<String?> getString(String key) async {
    if (fail) throw StateError('Falha simulada');
    return values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    if (fail) throw StateError('Falha simulada');
    values[key] = value;
  }
}

void main() {
  test('15 exemplos, três cidades e cinco marcadores por cidade', () {
    final locais = demoLocais();
    expect(locais.length, 15);
    for (final cidade in cidades) {
      expect(filtrarLocais(locais, cidade: cidade).length, 5);
    }
    expect(locais.map((l) => l.id).toSet().length, 15);
  });
  test('Modelo aceita números inteiros e preserva dados após conversão', () {
    final local = Local.fromMap('id', {
      ...demoLocais().first.toMap(),
      'avaliacao': 5,
      'distancia': 2,
    });
    expect(local.avaliacao, 5.0);
    expect(Local.fromMap(local.id, local.toMap()).toMap(), local.toMap());
    expect(local.copyWith(favorito: true).favorito, isTrue);
  });
  test('Pesquisa por nome e categoria ignora caixa, espaço e acentos', () {
    expect(filtrarLocais(demoLocais(), pesquisa: '  CAFE  ').length, 2);
    expect(
      filtrarLocais(
        demoLocais(),
        pesquisa: 'academia',
        cidade: 'Campinas',
      ).single.nome,
      'Academia Essência',
    );
    expect(
      filtrarLocais(
        demoLocais(),
        categoria: 'Parque',
        cidade: 'Jundiaí',
      ).length,
      1,
    );
    expect(filtrarLocais(demoLocais(), favoritos: true), isEmpty);
    expect(
      filtrarLocais(demoLocais(), ordem: Ordenacao.avaliacao).first.avaliacao,
      4.9,
    );
    expect(filtrarLocais(demoLocais(), pesquisa: 'inexistente'), isEmpty);
  });
  test('Validação de obrigatórios, vírgula decimal e limites numéricos', () {
    expect(obrigatorio('  '), isNotNull);
    expect(validarAvaliacao('4,8'), isNull);
    for (final valor in ['-1', '5.1', 'NaN', 'Infinity', 'abc', '']) {
      expect(validarAvaliacao(valor), isNotNull);
    }
    expect(validarDistancia('0'), isNull);
    expect(validarDistancia('-0,1'), isNotNull);
    expect(validarDistancia('NaN'), isNotNull);
  });
  test('CRUD e favoritos persistem ao recriar repositório; IDs únicos em gravações concorrentes', () async {
    final prefs = MemoryPreferences();
    final repo = DeviceLocalRepository(storage: prefs);
    expect((await repo.observar().first).length, 15);
    await Future.wait(
      List.generate(3, (_) => repo.salvar(demoLocais().first.copyWith(id: ''))),
    );
    var itens = await DeviceLocalRepository(storage: prefs).observar().first;
    expect(itens.length, 18);
    expect(itens.map((l) => l.id).toSet().length, 18);
    final local = itens.last;
    await repo.salvar(
      Local.fromMap(local.id, {...local.toMap(), 'nome': 'Novo nome'}),
    );
    await repo.favoritar(local.id, true);
    itens = await DeviceLocalRepository(storage: prefs).observar().first;
    expect(itens.last.nome, 'Novo nome');
    expect(itens.last.favorito, isTrue);
    await repo.excluir(local.id);
    expect((await repo.observar().first).length, 17);
  });
  test('Excluir todos preserva banco vazio na reabertura', () async {
    final prefs = MemoryPreferences();
    final repo = DeviceLocalRepository(storage: prefs);
    for (final l in await repo.observar().first) {
      await repo.excluir(l.id);
    }
    expect(
      await DeviceLocalRepository(storage: prefs).observar().first,
      isEmpty,
    );
  });
  test(
    'Falha de gravação não publica alteração e próxima operação pode recuperar',
    () async {
      final prefs = MemoryPreferences();
      final repo = DeviceLocalRepository(storage: prefs);
      final local = (await repo.observar().first).first;
      prefs.fail = true;
      await expectLater(repo.favoritar(local.id, true), throwsStateError);
      expect((await repo.observar().first).first.favorito, isFalse);
      prefs.fail = false;
      await repo.favoritar(local.id, true);
      expect((await repo.observar().first).first.favorito, isTrue);
    },
  );

  test('Atualização dos exemplos preserva edições, favoritos, exclusões e cópia anterior', () async {
    final prefs = MemoryPreferences();
    final antigos = legacyDemoLocais()
        .where((l) => l.id != 'demo-0-4')
        .toList();
    antigos[0] = antigos[0].copyWith(favorito: true);
    antigos[1] = Local.fromMap(antigos[1].id, {
      ...antigos[1].toMap(),
      'nome': 'Academia editada pelo usuário',
    });
    antigos.add(antigos.first.copyWith(id: 'cadastro-do-usuario'));
    final raw = jsonEncode([
      for (final l in antigos) {'id': l.id, ...l.toMap()},
    ]);
    prefs.values[DeviceLocalRepository.storageKey] = raw;
    final dados = await DeviceLocalRepository(storage: prefs).observar().first;
    expect(dados.first.nome, 'Academia Fitness');
    expect(dados.first.favorito, isTrue);
    expect(dados[1].nome, 'Academia editada pelo usuário');
    expect(dados.any((l) => l.id == 'demo-0-4'), isFalse);
    expect(dados.any((l) => l.id == 'cadastro-do-usuario'), isTrue);
    expect(prefs.values['perto.backup.before-reference.v1'], raw);
  });

  Future<DeviceLocalRepository> iniciar(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    MemoryPreferences? prefs,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = DeviceLocalRepository(storage: prefs ?? MemoryPreferences());
    await tester.pumpWidget(PertoApp(repository: repo));
    await tester.pumpAndSettle();
    return repo;
  }

  for (final size in [
    const Size(320, 568),
    const Size(320, 640),
    const Size(360, 800),
    const Size(390, 844),
    const Size(430, 932),
    const Size(768, 1024),
    const Size(844, 390),
    const Size(1366, 900),
  ]) {
    testWidgets('Mapa, resultados e detalhes sem overflow em $size', (
      tester,
    ) async {
      await iniciar(tester, size: size);
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      expect(find.text('Visitante'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('São Paulo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('São Paulo').last);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Academia Fitness'), findsOneWidget);
      for (final local in demoLocais().where(
        (l) => l.cidade == cidades.first && l.id != 'demo-0-0',
      )) {
        await tester.tap(find.byTooltip(local.nome));
        await tester.pumpAndSettle();
        expect(find.text(local.nome), findsOneWidget);
      }
      await tester.tap(find.byTooltip('Pesquisar locais'));
      await tester.pumpAndSettle();
      expect(find.byType(LocalCard), findsWidgets);
      await tester.tap(find.text('Academia Fitness'));
      await tester.pumpAndSettle();
      expect(find.text('Sobre'), findsOneWidget);
      await tester.ensureVisible(find.text('Ver todas'));
      await tester.tap(find.text('Ver todas'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Fechar fotos'), findsOneWidget);
      await tester.tap(find.byTooltip('Fechar fotos'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Ver no mapa'));
      await tester.tap(find.text('Ver no mapa'));
      await tester.pumpAndSettle();
      expect(find.text('Cidade selecionada'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Cidade, pesquisa, vazio e limpeza de filtros', (tester) async {
    await iniciar(tester);
    await tester.tap(find.text('São Paulo').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Campinas').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'academia');
    await tester.tap(find.byTooltip('Pesquisar locais'));
    await tester.pumpAndSettle();
    expect(find.text('Academia Essência'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('Nenhum local encontrado'), findsOneWidget);
    await tester.tap(find.text('Limpar filtros'));
    await tester.pumpAndSettle();
    expect(find.byType(LocalCard), findsWidgets);
  });
  testWidgets('Favoritar e desmarcar atualiza detalhes e filtro', (
    tester,
  ) async {
    final repo = await iniciar(tester);
    await tester.tap(find.text('Academia Fitness'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Adicionar aos favoritos'));
    await tester.pumpAndSettle();
    expect((await repo.observar().first).first.favorito, isTrue);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Academia Fitness'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remover dos favoritos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum local encontrado'), findsOneWidget);
  });
  testWidgets('CRUD pela interface e exclusão exige confirmação', (
    tester,
  ) async {
    final repo = await iniciar(tester);
    await tester.tap(find.byTooltip('Pesquisar locais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo local').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar local'));
    await tester.pumpAndSettle();
    expect(find.text('Preencha este campo.'), findsWidgets);
    Future<void> preencher(String label, String value) async {
      final finder = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(finder);
      await tester.enterText(finder, value);
    }

    await preencher('Nome do local', 'Local de teste');
    await preencher('Endereço', 'Rua Exemplo, 10');
    await preencher('Horário (ex.: 08:00 - 18:00)', '09:00 - 18:00');
    await preencher('Avaliação (0 a 5)', '4,5');
    await preencher('Distância (km)', '0,2');
    await preencher('Descrição', 'Descrição para validar o cadastro.');
    await tester.tap(find.text('Salvar local'));
    await tester.pumpAndSettle();
    expect((await repo.observar().first).length, 16);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Pesquisar locais'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Local de teste'),
      -220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.longPress(find.text('Local de teste'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar local'));
    await tester.pumpAndSettle();
    await preencher('Nome do local', 'Local atualizado');
    await tester.tap(find.text('Salvar local'));
    await tester.pumpAndSettle();
    expect(find.text('Local atualizado'), findsOneWidget);
    await tester.longPress(find.text('Local atualizado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir local'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir local?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect((await repo.observar().first).length, 16);
    await tester.tap(find.text('Local atualizado'));
    await tester.pumpAndSettle();
    await tester.longPress(find.byType(PageView).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir local'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect((await repo.observar().first).length, 15);
    expect(find.text('Local atualizado'), findsNothing);
  });
  testWidgets('Erro de leitura exibe mensagem e permite tentar novamente', (
    tester,
  ) async {
    final prefs = MemoryPreferences()..fail = true;
    await iniciar(tester, prefs: prefs);
    expect(find.text('Não foi possível carregar os locais'), findsOneWidget);
    prefs.fail = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Academia Fitness'), findsOneWidget);
  });
}
