import 'package:flutter/material.dart';
import 'preferensi.dart';

class TemaController extends ChangeNotifier {
  static final TemaController instance = TemaController._();

  TemaController._();

  final Preferensi _preferensi = Preferensi();

  bool _modeGelap = false;

  bool get modeGelap => _modeGelap;

  // Membaca preferensi tema yang tersimpan
  Future<void> muat() async {
    _modeGelap = await _preferensi.modeGelap();
    notifyListeners();
  }

  // Mengubah dan menyimpan tema
  Future<void> ubahModeGelap(bool aktif) async {
    _modeGelap = aktif;

    notifyListeners();

    await _preferensi.setModeGelap(aktif);
  }

  // Mengaktifkan atau menonaktifkan tema
  Future<void> toggle() async {
    await ubahModeGelap(!_modeGelap);
  }
}
