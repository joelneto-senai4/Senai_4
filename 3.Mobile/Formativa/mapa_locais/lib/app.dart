import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'services/local_repository.dart';
import 'screens/mapa_screen.dart';
import 'widgets/shared.dart';

class PertoApp extends StatelessWidget {
  final LocalRepository repository;
  const PertoApp({super.key, required this.repository});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mapa de locais',
    debugShowCheckedModeBanner: false,
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: papel,
      colorScheme: ColorScheme.fromSeed(
        seedColor: verde,
        primary: verde,
        surface: papel,
        secondary: cinza,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 14, color: tinta),
        bodySmall: TextStyle(fontSize: 12, color: cinza),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: papel,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 52,
        titleTextStyle: TextStyle(
          fontSize: 16,
          color: tinta,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(size: 22, color: tinta),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: tinta,
          minimumSize: const Size(44, 44),
          iconSize: 22,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: papel,
        hoverColor: Colors.transparent,
        isDense: true,
        hintStyle: const TextStyle(color: Color(0xFF8A8D8E), fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        prefixIconColor: cinza,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: linha),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: linha),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: verde,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 13),
          minimumSize: const Size(44, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: linha,
        thickness: .7,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    home: MapaScreen(repository: repository),
  );
}
