import 'package:flutter/material.dart';

import 'data/tema_controller.dart';
import 'tampilan/daftar_pengiriman_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TemaController.instance.muat();

  runApp(const SiLogApp());
}

class SiLogApp extends StatelessWidget {
  const SiLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TemaController.instance,
      builder: (context, child) {
        final gelap = TemaController.instance.modeGelap;

        return MaterialApp(
          title: 'SiLog',
          debugShowCheckedModeBanner: false,

          themeMode: gelap ? ThemeMode.dark : ThemeMode.light,

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E20),
              brightness: Brightness.light,
            ),
            cardTheme: CardThemeData(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E20),
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),

          home: const DaftarPengirimanPage(),
        );
      },
    );
  }
}
