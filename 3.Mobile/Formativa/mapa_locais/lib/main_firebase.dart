import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/firestore_local_repository.dart';

/// Entrada opcional; o app padrão permanece inteiramente local.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final session = await FirebaseAuth.instance.signInAnonymously();
    // Identidade de demonstração: autorizar somente este UID nas regras finais.
    debugPrint('Perto - UID de demonstração: ${session.user?.uid}');
    runApp(PertoApp(repository: FirestoreLocalRepository()));
  } catch (_) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 48),
                    const SizedBox(height: 20),
                    const Text(
                      'Firebase ainda não está disponível',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Conclua a configuração em docs/FIREBASE.md e execute novamente. Para usar os dados locais, inicie lib/main.dart.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
