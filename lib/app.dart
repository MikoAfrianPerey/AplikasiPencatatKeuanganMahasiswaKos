import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repository/RepositoryKategori.dart';
import 'data/repository/RepositoryPeriodeBudget.dart';
import 'data/repository/RepositoryTransaksi.dart';
import 'inti/routing/RuteAplikasi.dart';
import 'inti/tema/Tema.dart';
import 'provider/ProviderOnboarding.dart';
import 'provider/ProviderPengaturan.dart';
import 'provider/ProviderTransaksi.dart';

class AplikasiDompetKos extends StatelessWidget {
  const AplikasiDompetKos({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RepositoryKategori>(
          create: (_) => RepositoryKategoriMock(),
        ),
        Provider<RepositoryPeriodeBudget>(
          create: (_) => RepositoryPeriodeBudgetMock(),
        ),
        Provider<RepositoryTransaksi>(
          create: (_) => RepositoryTransaksiMock(),
        ),
        ChangeNotifierProvider<ProviderOnboarding>(
          create: (context) => ProviderOnboarding(
            context.read<RepositoryKategori>(),
            context.read<RepositoryPeriodeBudget>(),
          ),
        ),
        ChangeNotifierProvider<ProviderTransaksi>(
          create: (context) => ProviderTransaksi(
            context.read<RepositoryKategori>(),
            context.read<RepositoryTransaksi>(),
          ),
        ),
        ChangeNotifierProvider<ProviderPengaturan>(
          create: (context) => ProviderPengaturan(
            context.read<RepositoryKategori>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'DompetKos',
        debugShowCheckedModeBanner: false,
        theme: Tema.terang,
        darkTheme: Tema.gelap,
        themeMode: ThemeMode.system,
        initialRoute: RuteAplikasi.onboarding,
        routes: RuteAplikasi.rute,
      ),
    );
  }
}
