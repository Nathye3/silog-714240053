import 'package:flutter/material.dart';

import 'data/preferensi.dart';
import 'tampilan/daftar_pengiriman_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SiLogApp());
}

class SiLogApp extends StatefulWidget {
  const SiLogApp({super.key});

  @override
  State<SiLogApp> createState() => _SiLogAppState();
}

class _SiLogAppState extends State<SiLogApp> {
  final Preferensi _preferensi = Preferensi();

  bool _modeGelap = false;
  bool _memuatTema = true;

  @override
  void initState() {
    super.initState();
    _muatTema();
  }

  // Memuat preferensi tema yang tersimpan
  Future<void> _muatTema() async {
    final aktif = await _preferensi.modeGelap();

    if (!mounted) return;

    setState(() {
      _modeGelap = aktif;
      _memuatTema = false;
    });
  }

  // Mengubah dan menyimpan tema aplikasi
  Future<void> _ubahTema(bool aktif) async {
    await _preferensi.setModeGelap(aktif);

    if (!mounted) return;

    setState(() {
      _modeGelap = aktif;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_memuatTema) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'SiLog',
      debugShowCheckedModeBanner: false,

      // Tema terang
      theme: ThemeData(
        useMaterial3: true,
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

      // Tema gelap
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),

      themeMode: _modeGelap ? ThemeMode.dark : ThemeMode.light,

      // Mempertahankan halaman utama SiLog
      home: const DaftarPengirimanPage(),
    );
  }
}
