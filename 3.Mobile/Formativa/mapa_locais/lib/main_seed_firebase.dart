import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'data/demo_locais.dart';
import 'firebase_options.dart';

// Ferramenta opcional para a etapa final. Nunca executada pelo app padrão.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(home: _SeedScreen(), debugShowCheckedModeBanner: false),
  );
}

class _SeedScreen extends StatefulWidget {
  const _SeedScreen();
  @override
  State<_SeedScreen> createState() => _SeedScreenState();
}

class _SeedScreenState extends State<_SeedScreen> {
  bool busy = false;
  String status =
      'Configura o Firebase e insere 15 exemplos, somente se a coleção estiver vazia. Não migra os dados locais.';
  Future<void> carregar() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cadastrar exemplos no Firestore?'),
        content: const Text(
          'Serão criados 15 documentos fictícios no projeto configurado em firebase_options.dart. Confira o projeto antes de continuar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cadastrar exemplos'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;
    setState(() => busy = true);
    String uid = '';
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      uid = (await FirebaseAuth.instance.signInAnonymously()).user!.uid;
      final db = FirebaseFirestore.instance;
      final collection = db.collection('locais');
      if ((await collection.limit(1).get()).docs.isNotEmpty) {
        throw StateError(
          'A coleção já contém registros. Nenhum exemplo foi inserido.',
        );
      }
      final exemplos = demoLocais();
      await db.runTransaction((tx) async {
        // Todas as leituras ocorrem antes das escritas; uma segunda carga concorrente é recusada.
        final existentes = [
          for (final l in exemplos) await tx.get(collection.doc(l.id)),
        ];
        if (existentes.any((d) => d.exists)) {
          throw StateError('Os exemplos já foram cadastrados.');
        }
        for (final l in exemplos) {
          tx.set(collection.doc(l.id), l.toMap());
        }
      });
      if (mounted) {
        setState(
          () => status = '15 exemplos cadastrados com sucesso. Abra agora main_firebase.dart.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => status =
              'Carga não concluída. $e\n\nUID desta instalação: $uid\nConsulte docs/FIREBASE.md e confira a autorização nas regras.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Perto · Carga de exemplos')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText(status),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy ? null : carregar,
                  child: Text(
                    busy ? 'Cadastrando…' : 'Preparar carga no Firestore',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
