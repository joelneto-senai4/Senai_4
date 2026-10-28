import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/local.dart';
import 'local_repository.dart';

/// Adaptador preparado para a etapa final. Não é iniciado no modo local.
class FirestoreLocalRepository implements LocalRepository {
  final FirebaseFirestore firestore;
  FirestoreLocalRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _locais =>
      firestore.collection('locais');
  @override
  String get origem => 'Firestore';
  @override
  Stream<List<Local>> observar() => _locais.snapshots().map(
    (snapshot) =>
        snapshot.docs.map((doc) => Local.fromMap(doc.id, doc.data())).toList(),
  );
  @override
  Future<void> salvar(Local local) async {
    if (local.id.isEmpty) {
      await _locais.add(local.toMap());
    } else {
      await _locais.doc(local.id).update(local.toMap());
    }
  }

  @override
  Future<void> excluir(String id) => _locais.doc(id).delete();
  @override
  Future<void> favoritar(String id, bool valor) =>
      _locais.doc(id).update({'favorito': valor});
}
