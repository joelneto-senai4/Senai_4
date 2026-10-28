import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_repository.dart';
import '../dialogs/confirm_delete.dart';
import 'local_form.dart';
import 'shared.dart';

Future<bool> acoesLocal(
  BuildContext context,
  LocalRepository repository,
  Local local,
) async {
  final acao = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: papel,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              local.nome,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Editar local'),
            onTap: () => Navigator.pop(context, 'editar'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Excluir local'),
            onTap: () => Navigator.pop(context, 'excluir'),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted) return false;
  if (acao == 'editar') {
    await abrirFormulario(context, repository, local: local);
  }
  if (acao == 'excluir' && context.mounted) {
    return confirmarExclusao(context, repository, local);
  }
  return false;
}
