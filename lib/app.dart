import 'package:flutter/material.dart';

import 'inti/routing/RuteAplikasi.dart';
import 'inti/tema/Tema.dart';

class AplikasiDompetKos extends StatelessWidget {
  const AplikasiDompetKos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DompetKos',
      debugShowCheckedModeBanner: false,
      theme: Tema.terang,
      darkTheme: Tema.gelap,
      themeMode: ThemeMode.system,
      initialRoute: RuteAplikasi.onboarding,
      routes: RuteAplikasi.rute,
    );
  }
}
