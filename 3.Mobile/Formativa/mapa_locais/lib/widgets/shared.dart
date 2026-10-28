import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_repository.dart';

// Paleta e medidas do wireframe fornecido.
const verde = Color(0xFF3E4346);
const papel = Color(0xFFF8F9F9);
const tinta = Color(0xFF272D31);
const cinza = Color(0xFF7D8385);
const linha = Color(0xFFE2E5E5);

String decimal(double valor) => valor.toStringAsFixed(1).replaceAll('.', ',');
IconData iconeCategoria(String categoria) => switch (categoria) {
  'Academia' => Icons.fitness_center,
  'Restaurante' => Icons.restaurant,
  'Hospital' => Icons.local_hospital_outlined,
  'Parque' => Icons.park_outlined,
  'Cultura' => Icons.auto_stories_outlined,
  _ => Icons.local_cafe_outlined,
};
Color corCategoria(String categoria) => const Color(0xFFD1D3D3);
void mensagem(BuildContext context, String texto) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
}

class PageFrame extends StatelessWidget {
  final Widget child;
  const PageFrame({super.key, required this.child});
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFE9EBEB),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: child,
      ),
    ),
  );
}

Future<String?> escolherCidade(
  BuildContext context,
  String atual, {
  bool todas = false,
}) => showModalBottomSheet<String>(
  context: context,
  backgroundColor: papel,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Selecionar cidade',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ),
          for (final cidade in [if (todas) 'Todas', ...cidades])
            ListTile(
              leading: const Icon(Icons.location_on_outlined, size: 21),
              title: Text(cidade),
              trailing: cidade == atual
                  ? const Icon(Icons.check, size: 20)
                  : null,
              onTap: () => Navigator.pop(context, cidade),
            ),
        ],
      ),
    ),
  ),
);

class CidadeField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool todas;
  const CidadeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.todas = false,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Selecionar cidade',
    child: Material(
      color: papel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFCCD0D1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final nova = await escolherCidade(context, value, todas: todas);
          if (nova != null) onChanged(nova);
        },
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              const SizedBox(width: 13),
              const Icon(Icons.location_on_outlined, size: 20, color: verde),
              const SizedBox(width: 9),
              Expanded(
                child: Text(value, style: const TextStyle(fontSize: 13)),
              ),
              const Icon(Icons.chevron_right, size: 19, color: cinza),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    ),
  );
}

class CategoriaChips extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const CategoriaChips({
    super.key,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Row(
      children: [
        for (final c in [
          'Todos',
          'Academia',
          'Restaurante',
          'Hospital',
          'Café',
          'Parque',
          'Cultura',
        ])
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              selected: value == c,
              button: true,
              child: Material(
                color: value == c ? verde : const Color(0xFFE9EBEB),
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => onChanged(c),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    child: Text(
                      switch (c) {
                        'Academia' => 'Academias',
                        'Restaurante' => 'Restaurantes',
                        'Hospital' => 'Hospitais',
                        _ => c,
                      },
                      style: TextStyle(
                        fontSize: 11,
                        color: value == c ? Colors.white : verde,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class EstadoLista extends StatelessWidget {
  final bool erro;
  final String? titulo;
  final VoidCallback? onRetry;
  const EstadoLista({super.key, this.erro = false, this.titulo, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              erro ? Icons.cloud_off_outlined : Icons.search_off,
              size: 38,
              color: cinza,
            ),
            const SizedBox(height: 14),
            Text(
              titulo ??
                  (erro
                      ? 'Não foi possível carregar os locais'
                      : 'Nenhum local encontrado'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              erro
                  ? 'Tente novamente em instantes.'
                  : 'Experimente outra pesquisa ou remova os filtros.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: cinza),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text(erro ? 'Tentar novamente' : 'Limpar filtros'),
              ),
          ],
        ),
      ),
    ),
  );
}

class FavoriteButton extends StatefulWidget {
  final Local local;
  final LocalRepository repository;
  const FavoriteButton({
    super.key,
    required this.local,
    required this.repository,
  });
  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool busy = false;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: widget.local.favorito
        ? 'Remover dos favoritos'
        : 'Adicionar aos favoritos',
    onPressed: busy
        ? null
        : () async {
            setState(() => busy = true);
            try {
              await widget.repository.favoritar(
                widget.local.id,
                !widget.local.favorito,
              );
            } catch (_) {
              if (context.mounted) {
                mensagem(
                  context,
                  'Não foi possível atualizar o favorito. Tente novamente.',
                );
              }
            } finally {
              if (mounted) setState(() => busy = false);
            }
          },
    icon: busy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(
            widget.local.favorito ? Icons.favorite : Icons.favorite_border,
            size: 23,
            color: verde,
          ),
  );
}
