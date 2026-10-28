import 'package:firebase_core/firebase_core.dart';

/// Será substituído pelo FlutterFire CLI durante a configuração final.
abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Firebase ainda não configurado. Execute flutterfire configure conforme docs/FIREBASE.md.',
  );
}
