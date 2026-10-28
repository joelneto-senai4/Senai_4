import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo_locais.dart';
import '../models/local.dart';

abstract class LocalRepository {
  String get origem;
  Stream<List<Local>> observar();
  Future<void> salvar(Local local);
  Future<void> excluir(String id);
  Future<void> favoritar(String id, bool valor);
}

abstract interface class LocalStorage {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
}

class PreferencesStorage implements LocalStorage {
  final SharedPreferencesAsync preferences = SharedPreferencesAsync();
  @override
  Future<String?> getString(String key) => preferences.getString(key);
  @override
  Future<void> setString(String key, String value) =>
      preferences.setString(key, value);
}

class DeviceLocalRepository implements LocalRepository {
  static const storageKey = 'perto.locais.v1';
  final LocalStorage _preferences;
  final List<void Function(List<Local>)> _listeners = [];
  List<Local>? _locais;
  Future<List<Local>>? _leitura;
  Future<void> _fila = Future.value();
  int _sequence = 0;
  DeviceLocalRepository({LocalStorage? storage})
    : _preferences = storage ?? PreferencesStorage();
  @override
  String get origem => 'Modo local';
  Future<List<Local>> _carregar() {
    if (_locais != null) return Future.value(_locais!);
    // Compartilha a primeira leitura entre as telas para evitar estados antigos.
    return _leitura ??= _lerDispositivo().whenComplete(() => _leitura = null);
  }

  Future<List<Local>> _lerDispositivo() async {
    final raw = await _preferences.getString(storageKey);
    if (raw == null) return _locais = demoLocais();
    final maps = jsonDecode(raw) as List<dynamic>;
    final locais = maps.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return Local.fromMap(map.remove('id') as String, map);
    }).toList();
    final atualizados = atualizarExemplosIntactos(locais);
    final mudou =
        jsonEncode(locais.map((l) => l.toMap()).toList()) !=
        jsonEncode(atualizados.map((l) => l.toMap()).toList());
    if (mudou) {
      const backup = 'perto.backup.before-reference.v1';
      if (await _preferences.getString(backup) == null) {
        await _preferences.setString(backup, raw);
      }
      await _preferences.setString(
        storageKey,
        jsonEncode([
          for (final local in atualizados) {'id': local.id, ...local.toMap()},
        ]),
      );
    }
    return _locais = atualizados;
  }

  @override
  Stream<List<Local>> observar() => Stream<List<Local>>.multi((controller) {
    void enviar(List<Local> locais) =>
        controller.add(List.unmodifiable(locais));
    _listeners.add(enviar);
    controller.onCancel = () => _listeners.remove(enviar);
    _carregar().then(enviar, onError: controller.addError);
  });
  Future<void> _alterar(List<Local> Function(List<Local>) mutation) {
    final trabalho = _fila.then((_) async {
      final atuais = await _carregar();
      final novos = mutation(List.of(atuais));
      await _preferences.setString(
        storageKey,
        jsonEncode([
          for (final local in novos) {'id': local.id, ...local.toMap()},
        ]),
      );
      _locais = novos; // Só publica depois de persistir com sucesso.
      for (final enviar in List.of(_listeners)) {
        enviar(novos);
      }
    });
    _fila = trabalho.catchError((Object _) {});
    return trabalho;
  }

  @override
  Future<void> salvar(Local local) => _alterar((atuais) {
    if (local.id.isEmpty) {
      atuais.add(
        local.copyWith(
          id: 'local-${DateTime.now().microsecondsSinceEpoch}-${_sequence++}',
        ),
      );
    } else {
      final index = atuais.indexWhere((l) => l.id == local.id);
      if (index < 0) throw StateError('Este local não existe mais.');
      atuais[index] = local;
    }
    return atuais;
  });
  @override
  Future<void> excluir(String id) => _alterar((atuais) {
    if (!atuais.any((l) => l.id == id)) {
      throw StateError('Local não encontrado.');
    }
    return atuais.where((l) => l.id != id).toList();
  });
  @override
  Future<void> favoritar(String id, bool valor) => _alterar((atuais) {
    final index = atuais.indexWhere((l) => l.id == id);
    if (index < 0) throw StateError('Local não encontrado.');
    atuais[index] = atuais[index].copyWith(favorito: valor);
    return atuais;
  });
}
