import 'dart:convert';
import 'dart:io';

import 'package:mapa_locais/data/demo_locais.dart';

void main() {
  File('docs/locais-exemplo.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ')
        .convert({for (final local in demoLocais()) local.id: local.toMap()}),
  );
}
