import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/local.dart';
import '../services/local_repository.dart';
import '../widgets/shared.dart';
import '../widgets/place_art.dart';
import '../widgets/reference_nav.dart';
import '../widgets/local_actions.dart';

class DetalhesScreen extends StatefulWidget {
  final LocalRepository repository;
  final String localId;
  const DetalhesScreen({
    super.key,
    required this.repository,
    required this.localId,
  });
  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  late Stream<List<Local>> stream;
  final pages = PageController();
  int photo = 0;
  @override
  void initState() {
    super.initState();
    stream = widget.repository.observar();
  }

  @override
  void dispose() {
    pages.dispose();
    super.dispose();
  }

  Future<void> compartilhar(Local local) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${local.nome}\n${local.categoria} · ${local.cidade}\n${local.endereco}\n${local.horario}\n${local.descricao}',
      ),
    );
    if (mounted) mensagem(context, 'Informações copiadas para compartilhar.');
  }

  Future<void> agendar(Local local) async {
    final now = DateTime.now();
    final dia = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
      initialDate: now,
      helpText: 'Agendar lembrete de visita',
    );
    if (dia == null || !mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Horário do lembrete',
    );
    if (hora == null || !mounted) return;
    final quando =
        '${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}/${dia.year} às ${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
    try {
      final storage = SharedPreferencesAsync();
      final raw = await storage.getString('perto.lembretes.v1');
      final lembretes = raw == null
          ? <String, dynamic>{}
          : jsonDecode(raw) as Map<String, dynamic>;
      lembretes[local.id] = {'nome': local.nome, 'quando': quando};
      await storage.setString('perto.lembretes.v1', jsonEncode(lembretes));
      if (mounted) {
        mensagem(
          context,
          'Lembrete salvo para $quando. Não é uma reserva no estabelecimento.',
        );
      }
    } catch (_) {
      if (mounted) {
        mensagem(
          context,
          'Não foi possível salvar o lembrete. Tente novamente.',
        );
      }
    }
  }

  Future<void> galeria(Local local, {int initial = 0}) async {
    final controller = PageController(initialPage: initial);
    try {
      await showDialog<void>(
        context: context,
        builder: (context) => Dialog.fullscreen(
          backgroundColor: papel,
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Fechar fotos',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    Expanded(
                      child: Text(
                        'Fotos · ${local.nome}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: 5,
                    itemBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 1.7,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: PlaceArt(categoria: local.categoria),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${index + 1}/5',
                            style: const TextStyle(color: cinza),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    child: StreamBuilder<List<Local>>(
      stream: stream,
      builder: (context, snapshot) {
        final local = snapshot.data
            ?.where((l) => l.id == widget.localId)
            .firstOrNull;
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            actions: [
              if (local != null)
                FavoriteButton(local: local, repository: widget.repository),
              if (local != null)
                IconButton(
                  tooltip: 'Compartilhar local',
                  icon: const Icon(Icons.share_outlined, size: 21),
                  onPressed: () => compartilhar(local),
                ),
              const SizedBox(width: 5),
            ],
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (local != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 5, 14, 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context, local),
                      icon: const Icon(Icons.location_on, size: 20),
                      label: const Text('Ver no mapa'),
                    ),
                  ),
                ),
              ReferenceNav(repository: widget.repository, local: local),
            ],
          ),
          body: snapshot.hasError
              ? EstadoLista(
                  erro: true,
                  onRetry: () =>
                      setState(() => stream = widget.repository.observar()),
                )
              : !snapshot.hasData
              ? const Center(child: CircularProgressIndicator())
              : local == null
              ? const EstadoLista(titulo: 'Este local não está mais disponível')
              : LayoutBuilder(
                  builder: (context, bounds) {
                    // Mantém toda a composição da referência visível em telefones altos.
                    final s = (bounds.maxHeight / 700).clamp(.82, 1.08);
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: bounds.maxHeight,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GestureDetector(
                              onLongPress: () async {
                                final navigator = Navigator.of(context);
                                final excluido = await acoesLocal(
                                  context,
                                  widget.repository,
                                  local,
                                );
                                if (excluido && navigator.mounted) {
                                  navigator.pop();
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: SizedBox(
                                  height: 180 * s,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: PageView.builder(
                                          controller: pages,
                                          itemCount: 5,
                                          onPageChanged: (value) =>
                                              setState(() => photo = value),
                                          itemBuilder: (_, i) =>
                                              GestureDetector(
                                                onTap: () =>
                                                    galeria(local, initial: i),
                                                child: PlaceArt(
                                                  categoria: local.categoria,
                                                  large: true,
                                                ),
                                              ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 12,
                                        bottom: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF949A9A),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '${photo + 1}/5',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 22 * s,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var i = 0; i < 5; i++)
                                    GestureDetector(
                                      onTap: () => pages.animateToPage(
                                        i,
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        curve: Curves.easeOut,
                                      ),
                                      child: Container(
                                        width: 7,
                                        height: 7,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: photo == i
                                              ? verde
                                              : const Color(0xFFCDD1D1),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 3 * s),
                            Text(
                              local.nome,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                                color: tinta,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              local.categoria,
                              style: const TextStyle(
                                fontSize: 13,
                                color: cinza,
                              ),
                            ),
                            SizedBox(height: 8 * s),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 20, color: tinta),
                                const SizedBox(width: 4),
                                Text(
                                  decimal(local.avaliacao),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  ' (${local.avaliacoes} avaliações)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: verde,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 17 * s),
                            Wrap(
                              spacing: 25,
                              runSpacing: 8,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${decimal(local.distancia)} km',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.schedule, size: 19),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Aberto · ${local.horario}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 18 * s),
                            const Divider(),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 14 * s),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _Action(
                                    icon: Icons.call,
                                    label: 'Ligar',
                                    onTap: () => showDialog<void>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(local.nome),
                                        content: const Text(
                                          'Telefone não informado para este local de demonstração.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Fechar'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _Action(
                                    icon: Icons.near_me,
                                    label: 'Como chegar',
                                    onTap: () => Navigator.pop(context, local),
                                  ),
                                  _Action(
                                    icon: Icons.calendar_today_outlined,
                                    label: 'Agendar',
                                    onTap: () => agendar(local),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            SizedBox(height: 12 * s),
                            const Text(
                              'Sobre',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              local.descricao,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: verde,
                              ),
                            ),
                            SizedBox(height: 14 * s),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Fotos',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => galeria(local),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Ver todas',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: cinza,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          size: 16,
                                          color: cinza,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 71 * s,
                              child: Row(
                                children: [
                                  for (var i = 0; i < 3; i++)
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: i < 2 ? 8 : 0,
                                        ),
                                        child: InkWell(
                                          onTap: () =>
                                              galeria(local, initial: i),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            child: PlaceArt(
                                              categoria: local.categoria,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    ),
  );
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCDD1D2)),
              ),
              child: Icon(icon, size: 20, color: verde),
            ),
            const SizedBox(height: 7),
            Text(label, style: const TextStyle(fontSize: 11, color: verde)),
          ],
        ),
      ),
    ),
  );
}
