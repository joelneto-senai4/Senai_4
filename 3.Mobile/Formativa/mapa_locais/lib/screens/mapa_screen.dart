import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_repository.dart';
import '../widgets/shared.dart';
import '../widgets/illustrated_map.dart';
import '../widgets/reference_nav.dart';
import 'detalhes_screen.dart';
import 'resultados_screen.dart';

class MapaScreen extends StatefulWidget {
  final LocalRepository repository;
  const MapaScreen({super.key, required this.repository});
  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  String cidade = cidades.first;
  String? selectedId;
  bool contrast = false;
  final pesquisa = TextEditingController();
  final transform = TransformationController();
  late Stream<List<Local>> stream;
  @override
  void initState() {
    super.initState();
    stream = widget.repository.observar();
  }

  @override
  void dispose() {
    pesquisa.dispose();
    transform.dispose();
    super.dispose();
  }

  Future<void> resultados({bool favoritos = false}) async {
    FocusScope.of(context).unfocus();
    final local = await Navigator.push<Local>(
      context,
      MaterialPageRoute(
        builder: (_) => ResultadosScreen(
          repository: widget.repository,
          cidade: favoritos ? 'Todas' : cidade,
          pesquisa: favoritos ? '' : pesquisa.text,
          favoritos: favoritos,
        ),
      ),
    );
    if (local != null && mounted) {
      setState(() {
        cidade = local.cidade;
        selectedId = local.id;
        transform.value = Matrix4.identity();
      });
    }
  }

  Future<void> detalhes(Local local) async {
    final retorno = await Navigator.push<Local>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DetalhesScreen(repository: widget.repository, localId: local.id),
      ),
    );
    if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (retorno != null && mounted) {
      setState(() {
        cidade = retorno.cidade;
        selectedId = retorno.id;
        transform.value = Matrix4.identity();
      });
    }
  }

  Future<void> selecionarCidade() async {
    final nova = await escolherCidade(context, cidade);
    if (nova != null && mounted) {
      setState(() {
        cidade = nova;
        selectedId = null;
        transform.value = Matrix4.identity();
      });
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    child: Scaffold(
      bottomNavigationBar: ReferenceNav(
        repository: widget.repository,
        onMap: () => transform.value = Matrix4.identity(),
        onFavorites: () => resultados(favoritos: true),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 9),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: true,
                  label: 'Selecionar cidade',
                  child: InkWell(
                    onTap: selecionarCidade,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 26,
                            color: tinta,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cidade selecionada',
                                style: TextStyle(fontSize: 10, color: cinza),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    cidade,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: SizedBox(
                height: 46,
                child: TextField(
                  controller: pesquisa,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(fontSize: 13),
                  onSubmitted: (_) => resultados(),
                  decoration: InputDecoration(
                    hintText: 'Buscar locais, endereços ou categorias...',
                    prefixIcon: IconButton(
                      tooltip: 'Pesquisar locais',
                      onPressed: resultados,
                      icon: const Icon(Icons.search, size: 21),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Local>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return EstadoLista(
                      erro: true,
                      onRetry: () =>
                          setState(() => stream = widget.repository.observar()),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final locais = filtrarLocais(snapshot.data!, cidade: cidade);
                  if (locais.isEmpty) {
                    return EstadoLista(
                      titulo: 'Nenhum local nesta cidade',
                      onRetry: resultados,
                    );
                  }
                  final selected =
                      locais.where((l) => l.id == selectedId).firstOrNull ??
                      locais.first;
                  return LayoutBuilder(
                    builder: (context, bounds) => Stack(
                      children: [
                        Positioned.fill(
                          child: InteractiveViewer(
                            transformationController: transform,
                            minScale: 1,
                            maxScale: 3,
                            child: IllustratedMap(
                              locais: locais,
                              selected: selected,
                              contrast: contrast,
                              onSelect: (local) =>
                                  setState(() => selectedId = local.id),
                              onOpen: () => detalhes(selected),
                            ),
                          ),
                        ),
                        if (bounds.maxHeight >= 180)
                          Positioned(
                            right: 16,
                            bottom: bounds.maxHeight > 300 ? 154 : 70,
                            child: _MapControl(
                              icon: Icons.my_location,
                              tooltip: 'Centralizar mapa',
                              onTap: () => setState(() {
                                transform.value = Matrix4.identity();
                                selectedId = null;
                              }),
                            ),
                          ),
                        if (bounds.maxHeight >= 180)
                          Positioned(
                            right: 16,
                            bottom: bounds.maxHeight > 300 ? 98 : 14,
                            child: _MapControl(
                              icon: Icons.layers_outlined,
                              tooltip: 'Camadas do mapa',
                              onTap: () async {
                                final escolha =
                                    await showModalBottomSheet<bool>(
                                      context: context,
                                      showDragHandle: true,
                                      builder: (context) => SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(14),
                                              child: Text(
                                                'Camadas do mapa',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.map_outlined,
                                              ),
                                              title: const Text('Padrão'),
                                              trailing: !contrast
                                                  ? const Icon(Icons.check)
                                                  : null,
                                              onTap: () =>
                                                  Navigator.pop(context, false),
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.contrast,
                                              ),
                                              title: const Text(
                                                'Mais contraste',
                                              ),
                                              trailing: contrast
                                                  ? const Icon(Icons.check)
                                                  : null,
                                              onTap: () =>
                                                  Navigator.pop(context, true),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                if (escolha != null && mounted) {
                                  setState(() => contrast = escolha);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MapControl extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _MapControl({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: papel,
    elevation: 2,
    shape: const CircleBorder(side: BorderSide(color: Color(0xFFCED3D2))),
    child: IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 23),
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
    ),
  );
}
