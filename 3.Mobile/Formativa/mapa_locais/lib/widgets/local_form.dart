import 'package:flutter/material.dart';

import '../models/local.dart';
import '../models/validators.dart';
import '../services/local_repository.dart';
import 'shared.dart';
import 'illustrated_map.dart';

Future<void> abrirFormulario(
  BuildContext context,
  LocalRepository repository, {
  Local? local,
  String? cidade,
}) async {
  final salvo = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: true,
    backgroundColor: papel,
    constraints: const BoxConstraints(maxWidth: 600),
    builder: (_) => LocalForm(
      repository: repository,
      local: local,
      cidade: cidade ?? cidades.first,
    ),
  );
  if (salvo == true && context.mounted) {
    mensagem(
      context,
      local == null
          ? 'Local cadastrado com sucesso.'
          : 'Alterações salvas com sucesso.',
    );
  }
}

class LocalForm extends StatefulWidget {
  final LocalRepository repository;
  final Local? local;
  final String cidade;
  const LocalForm({
    super.key,
    required this.repository,
    this.local,
    required this.cidade,
  });
  @override
  State<LocalForm> createState() => _LocalFormState();
}

class _LocalFormState extends State<LocalForm> {
  final form = GlobalKey<FormState>();
  late TextEditingController nome,
      horario,
      avaliacao,
      distancia,
      descricao,
      endereco;
  late String cidade, categoria;
  late double mapaX, mapaY;
  bool busy = false;
  String? erro;
  @override
  void initState() {
    super.initState();
    final l = widget.local;
    nome = TextEditingController(text: l?.nome);
    horario = TextEditingController(text: l?.horario);
    avaliacao = TextEditingController(
      text: l == null ? '' : decimal(l.avaliacao),
    );
    distancia = TextEditingController(
      text: l == null ? '' : decimal(l.distancia),
    );
    descricao = TextEditingController(text: l?.descricao);
    endereco = TextEditingController(text: l?.endereco);
    cidade = l?.cidade ?? widget.cidade;
    categoria = l?.categoria ?? categorias.first;
    mapaX = l?.mapaX ?? .5;
    mapaY = l?.mapaY ?? .5;
  }

  @override
  void dispose() {
    for (final c in [
      nome,
      horario,
      avaliacao,
      distancia,
      descricao,
      endereco,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> salvar() async {
    if (!form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      erro = null;
    });
    try {
      await widget.repository.salvar(
        Local(
          id: widget.local?.id ?? '',
          nome: nome.text.trim(),
          categoria: categoria,
          cidade: cidade,
          avaliacao: numero(avaliacao.text)!,
          distancia: numero(distancia.text)!,
          horario: horario.text.trim(),
          descricao: descricao.text.trim(),
          endereco: endereco.text.trim(),
          favorito: widget.local?.favorito ?? false,
          avaliacoes: widget.local?.avaliacoes ?? 0,
          mapaX: mapaX,
          mapaY: mapaY,
        ),
      );
      if (mounted) {
        setState(() => busy = false);
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          busy = false;
          erro = 'Não foi possível salvar. Seus campos foram mantidos. Tente novamente.';
        });
      }
    }
  }

  Widget campo(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    int lines = 1,
    bool numeric = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      enabled: !busy,
      maxLines: lines,
      validator: validator ?? obrigatorio,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : lines > 1
          ? TextInputType.multiline
          : TextInputType.text,
      textCapitalization: numeric
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label),
    ),
  );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .9,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.local == null
                          ? 'Um novo lugar para descobrir'
                          : 'Editar local',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: tinta,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar formulário',
                    onPressed: busy ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: form,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    Text(
                      'Salvamento: ${widget.repository.origem.toLowerCase()}',
                      style: const TextStyle(color: cinza, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    campo('Nome do local', nome),
                    DropdownButtonFormField<String>(
                      initialValue: categoria,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: categorias
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: busy
                          ? null
                          : (v) => setState(() => categoria = v!),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: cidade,
                      decoration: const InputDecoration(labelText: 'Cidade'),
                      items: cidades
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: busy
                          ? null
                          : (v) => setState(() => cidade = v!),
                    ),
                    const SizedBox(height: 14),
                    campo('Endereço', endereco),
                    campo('Horário (ex.: 08:00 - 18:00)', horario),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: campo(
                            'Avaliação (0 a 5)',
                            avaliacao,
                            numeric: true,
                            validator: validarAvaliacao,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: campo(
                            'Distância (km)',
                            distancia,
                            numeric: true,
                            validator: validarDistancia,
                          ),
                        ),
                      ],
                    ),
                    campo('Descrição', descricao, lines: 4),
                    const Text(
                      'Posição no mapa ilustrativo',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: tinta,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Toque no mapa para posicionar o marcador. A distância é informada manualmente.',
                      style: TextStyle(color: cinza, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 170,
                        child: LayoutBuilder(
                          builder: (_, constraints) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: busy
                                ? null
                                : (details) => setState(() {
                                    mapaX =
                                        ((details.localPosition.dx - 24) /
                                                (constraints.maxWidth - 52))
                                            .clamp(.08, .92);
                                    mapaY =
                                        ((details.localPosition.dy - 24) /
                                                (constraints.maxHeight - 58))
                                            .clamp(.12, .85);
                                  }),
                            child: IgnorePointer(
                              child: IllustratedMap(
                                compacto: true,
                                onSelect: (_) {},
                                locais: [
                                  Local(
                                    id: 'preview',
                                    nome: 'Posição do local',
                                    categoria: categoria,
                                    cidade: cidade,
                                    avaliacao: 0,
                                    distancia: 0,
                                    horario: '',
                                    descricao: '',
                                    mapaX: mapaX,
                                    mapaY: mapaY,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (erro != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          erro!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: busy ? null : salvar,
                  icon: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(busy ? 'Salvando…' : 'Salvar local'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
