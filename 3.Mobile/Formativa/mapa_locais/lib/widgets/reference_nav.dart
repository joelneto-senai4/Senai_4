import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/local.dart';
import '../screens/resultados_screen.dart';
import '../services/local_repository.dart';
import 'local_form.dart';
import 'local_actions.dart';
import 'shared.dart';

class ReferenceNav extends StatelessWidget {
  final LocalRepository repository;
  final int selected;
  final VoidCallback? onMap, onFavorites;
  final Local? local;
  const ReferenceNav({
    super.key,
    required this.repository,
    this.selected = 0,
    this.onMap,
    this.onFavorites,
    this.local,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: papel,
      border: Border(top: BorderSide(color: linha, width: .8)),
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            _item(
              'Mapa',
              Icons.map_outlined,
              Icons.map,
              0,
              onMap ?? () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
            _item(
              'Favoritos',
              Icons.favorite_border,
              Icons.favorite,
              1,
              onFavorites ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultadosScreen(
                          repository: repository,
                          cidade: 'Todas',
                          favoritos: true,
                        ),
                      ),
                    );
                  },
            ),
            _item(
              'Perfil',
              Icons.person_outline,
              Icons.person_outline,
              2,
              () => abrirPerfil(context, repository, local: local),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _item(
    String label,
    IconData icon,
    IconData filled,
    int index,
    VoidCallback action,
  ) => Expanded(
    child: Semantics(
      button: true,
      selected: selected == index,
      child: InkWell(
        onTap: action,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected == index ? filled : icon,
              size: 21,
              color: selected == index ? tinta : cinza,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected == index ? tinta : cinza,
                fontWeight: selected == index
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> abrirPerfil(
  BuildContext context,
  LocalRepository repository, {
  Local? local,
}) async {
  final acao = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: papel,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Text(
                'Perfil',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Visitante'),
              subtitle: Text('${repository.origem} · dados de demonstração'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_location_alt_outlined),
              title: const Text('Novo local'),
              onTap: () => Navigator.pop(context, 'novo'),
            ),
            if (local != null)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Gerenciar este local'),
                onTap: () => Navigator.pop(context, 'gerenciar'),
              ),
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Meus lembretes'),
              onTap: () => Navigator.pop(context, 'lembretes'),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 4, 24, 20),
              child: Text(
                'O mapa e os locais são ilustrativos. As distâncias são informadas no cadastro. Firebase será conectado na próxima etapa.',
                style: TextStyle(fontSize: 12, height: 1.5, color: cinza),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (!context.mounted) return;
  if (acao == 'novo') await abrirFormulario(context, repository);
  if (acao == 'gerenciar' && local != null && context.mounted) {
    final navigator = Navigator.of(context);
    final excluido = await acoesLocal(context, repository, local);
    if (excluido && navigator.mounted) navigator.pop();
  }
  if (acao == 'lembretes' && context.mounted) {
    final raw = await SharedPreferencesAsync().getString('perto.lembretes.v1');
    final dados = raw == null
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Meus lembretes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              if (dados.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Você ainda não salvou um lembrete.'),
                ),
              for (final item in dados.values)
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: Text(item['nome'] as String),
                  subtitle: Text(item['quando'] as String),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
