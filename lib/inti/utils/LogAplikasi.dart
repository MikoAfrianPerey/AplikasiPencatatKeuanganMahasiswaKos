import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LevelLog { debug, info, peringatan, error }

class LogAplikasi {
  const LogAplikasi._();

  static void debug(String pesan) => _tulis(LevelLog.debug, pesan);

  static void info(String pesan) => _tulis(LevelLog.info, pesan);

  static void peringatan(String pesan) => _tulis(LevelLog.peringatan, pesan);

  static void error(String pesan, {Object? error, StackTrace? stack}) {
    _tulis(LevelLog.error, pesan);
    if (error != null) developer.log('$pesan: $error', name: 'DompetKos');
    if (stack != null) developer.log('$pesan', name: 'DompetKos', error: stack);
  }

  static void _tulis(LevelLog level, String pesan) {
    final namaLevel = level.name.toUpperCase();
    developer.log(
      '[$namaLevel] $pesan',
      name: 'DompetKos',
      level: _nilaiLevel(level),
    );
    if (kDebugMode) debugPrint('[$namaLevel] $pesan');
  }

  static int _nilaiLevel(LevelLog level) => switch (level) {
        LevelLog.debug => 0,
        LevelLog.info => 800,
        LevelLog.peringatan => 900,
        LevelLog.error => 1000,
      };
}
