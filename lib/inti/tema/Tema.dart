import 'package:flutter/material.dart';

class Tema {
  static const Color benihWarna = Color(0xFF0D9488);

  static ThemeData get terang => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: benihWarna,
          brightness: Brightness.light,
        ),
      );

  static ThemeData get gelap => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: benihWarna,
          brightness: Brightness.dark,
        ),
      );
}
