import 'package:flutter/material.dart';

class TemaController {
  static final mode = ValueNotifier(ThemeMode.light);

  static void toggle() {
    mode.value = mode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
