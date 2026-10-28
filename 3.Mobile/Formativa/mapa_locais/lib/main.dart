import 'package:flutter/material.dart';

import 'app.dart';
import 'services/local_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PertoApp(repository: DeviceLocalRepository()));
}
