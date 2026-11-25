import 'package:flutter/material.dart';
import 'data/tema_controller.dart';
import 'tampilan/daftar_pengiriman_page.dart';

void main() => runApp(const SiLogApp());

class SiLogApp extends StatelessWidget {
  const SiLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: TemaController.mode,
      builder: (context, mode, _) => MaterialApp(
        title: 'SiLog',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: _tema(Brightness.light),
        darkTheme: _tema(Brightness.dark),
        home: const DaftarPengirimanPage(),
      ),
    );
  }

  ThemeData _tema(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B5E20),
        brightness: brightness,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}
