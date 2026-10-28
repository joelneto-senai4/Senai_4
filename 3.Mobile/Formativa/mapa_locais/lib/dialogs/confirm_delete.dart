import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_repository.dart';
import '../widgets/shared.dart';

Future<bool> confirmarExclusao(
  BuildContext context,
  LocalRepository repository,
  Local local,
) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _DeleteDialog(repository: repository, local: local),
      ) ??
      false;
}

class _DeleteDialog extends StatefulWidget {
  final LocalRepository repository;
  final Local local;
  const _DeleteDialog({required this.repository, required this.local});
  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  bool busy = false;
  String? erro;
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      icon: const Icon(Icons.delete_outline_rounded, color: verde),
      title: const Text('Excluir local?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“${widget.local.nome}” será excluído. Essa ação não poderá ser desfeita.',
          ),
          if (erro != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                erro!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: busy
              ? null
              : () async {
                  setState(() {
                    busy = true;
                    erro = null;
                  });
                  try {
                    await widget.repository.excluir(widget.local.id);
                    if (context.mounted) {
                      setState(() => busy = false);
                      mensagem(context, 'Local excluído com sucesso.');
                      Navigator.pop(context, true);
                    }
                  } catch (_) {
                    if (mounted) {
                      setState(() {
                        busy = false;
                        erro = 'Não foi possível excluir. Tente novamente.';
                      });
                    }
                  }
                },
          child: Text(busy ? 'Excluindo…' : 'Excluir'),
        ),
      ],
    ),
  );
}
