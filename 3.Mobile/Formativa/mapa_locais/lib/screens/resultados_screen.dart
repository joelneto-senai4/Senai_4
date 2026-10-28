import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_repository.dart';
import '../widgets/shared.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import '../widgets/local_actions.dart';
import '../widgets/reference_nav.dart';
import 'detalhes_screen.dart';

class ResultadosScreen extends StatefulWidget {
  final LocalRepository repository;
  final String cidade, pesquisa;
  final bool favoritos;
  const ResultadosScreen({
    super.key,
    required this.repository,
    required this.cidade,
    this.pesquisa = '',
    this.favoritos = false,
  });
  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  late String cidade;
  String categoria = 'Todos';
  late bool favoritos;
  Ordenacao ordem = Ordenacao.proximidade;
  late TextEditingController pesquisa;
  late Stream<List<Local>> stream;
  @override
  void initState() {
    super.initState();
    cidade = widget.cidade;
    favoritos = widget.favoritos;
    pesquisa = TextEditingController(text: widget.pesquisa);
    stream = widget.repository.observar();
  }

  @override
  void dispose() {
    pesquisa.dispose();
    super.dispose();
  }

  Future<void> detalhes(Local local) async {
    final retorno = await Navigator.push<Local>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DetalhesScreen(repository: widget.repository, localId: local.id),
      ),
    );
    if (retorno != null && mounted) Navigator.pop(context, retorno);
  }

  void limpar() => setState(() {
    pesquisa.clear();
    categoria = 'Todos';
    cidade = 'Todas';
    favoritos = false;
  });
  @override
  Widget build(BuildContext context) => PageFrame(
    child: Scaffold(
      appBar: AppBar(
        title: Text(favoritos ? 'Favoritos' : 'Resultados'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      bottomNavigationBar: ReferenceNav(
        repository: widget.repository,
        selected: favoritos ? 1 : 0,
        onFavorites: () => setState(() {
          favoritos = !favoritos;
          pesquisa.clear();
          categoria = 'Todos';
          cidade = 'Todas';
        }),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: pesquisa,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 13),
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Pesquisar',
                  prefixIcon: Icon(Icons.search, size: 21),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: CidadeField(
              value: cidade,
              todas: true,
              onChanged: (value) => setState(() => cidade = value),
            ),
          ),
          CategoriaChips(
            value: categoria,
            onChanged: (value) => setState(() => categoria = value),
          ),
          const SizedBox(height: 13),
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
                final locais = filtrarLocais(
                  snapshot.data!,
                  pesquisa: pesquisa.text,
                  cidade: cidade,
                  categoria: categoria,
                  favoritos: favoritos,
                  ordem: ordem,
                );
                if (locais.isEmpty) return EstadoLista(onRetry: limpar);
                return Semantics(
                  label: '${locais.length} lugares encontrados',
                  child: LayoutBuilder(
                    builder: (context, bounds) {
                      final rowHeight = locais.length == 5
                          ? ((bounds.maxHeight - 44) / 5).clamp(98.0, 116.0)
                          : 106.0;
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                        itemCount: locais.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          if (index == locais.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () => abrirFormulario(
                                        context,
                                        widget.repository,
                                        cidade: cidade == 'Todas'
                                            ? cidades.first
                                            : cidade,
                                      ),
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Novo local'),
                                    ),
                                  ),
                                  PopupMenuButton<Ordenacao>(
                                    tooltip: 'Ordenar locais',
                                    initialValue: ordem,
                                    onSelected: (value) =>
                                        setState(() => ordem = value),
                                    icon: const Icon(Icons.sort, size: 20),
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: Ordenacao.proximidade,
                                        child: Text('Menor distância'),
                                      ),
                                      PopupMenuItem(
                                        value: Ordenacao.avaliacao,
                                        child: Text('Melhor avaliação'),
                                      ),
                                      PopupMenuItem(
                                        value: Ordenacao.nome,
                                        child: Text('Nome de A a Z'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                          final local = locais[index];
                          return LocalCard(
                            height: rowHeight,
                            local: local,
                            repository: widget.repository,
                            onTap: () => detalhes(local),
                            onLongPress: () =>
                                acoesLocal(context, widget.repository, local),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
