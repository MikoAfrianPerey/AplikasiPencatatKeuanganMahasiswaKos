import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/database/BantuanDatabase.dart';
import 'data/repository/RepositoryKategori.dart';
import 'data/repository/RepositoryKategoriSqlite.dart';
import 'data/repository/RepositoryPeriodeBudget.dart';
import 'data/repository/RepositoryPeriodeBudgetSqlite.dart';
import 'data/repository/RepositoryTransaksi.dart';
import 'data/repository/RepositoryTransaksiApi.dart';
import 'inti/routing/RuteAplikasi.dart';
import 'inti/tema/Tema.dart';
import 'layanan/LayananAuth.dart';
import 'layanan/LayananNotifikasi.dart';
import 'provider/ProviderAuth.dart';
import 'provider/ProviderOnboarding.dart';
import 'provider/ProviderPengaturan.dart';
import 'provider/ProviderTransaksi.dart';

class AplikasiDompetKos extends StatelessWidget {
  const AplikasiDompetKos({super.key});

  @override
  Widget build(BuildContext context) {
    final db = BantuanDatabase.instance;

    return MultiProvider(
      providers: [
        Provider<LayananAuth>(create: (_) => LayananAuth()),
        Provider<LayananNotifikasi>(
          create: (_) => LayananNotifikasi(),
          lazy: false,
        ),
        Provider<RepositoryKategori>(
          create: (_) => RepositoryKategoriSqlite(db),
        ),
        Provider<RepositoryPeriodeBudget>(
          create: (_) => RepositoryPeriodeBudgetSqlite(db),
        ),
        Provider<RepositoryTransaksi>(
          create: (_) => RepositoryTransaksiApi(
            baseUri: Uri.parse(
              const String.fromEnvironment(
                'API_BASE_URL',
                defaultValue: 'http://10.0.2.2:8080',
              ),
            ),
          ),
          dispose: (_, repository) =>
              (repository as RepositoryTransaksiApi).tutup(),
        ),
        ChangeNotifierProvider<ProviderAuth>(
          create: (context) => ProviderAuth(context.read<LayananAuth>()),
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
            repositoryPeriode: context.read<RepositoryPeriodeBudget>(),
            notifikasi: context.read<LayananNotifikasi>(),
          ),
        ),
        ChangeNotifierProvider<ProviderPengaturan>(
          create: (context) => ProviderPengaturan(
            context.read<RepositoryKategori>(),
            context.read<LayananNotifikasi>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'DompetKos',
        debugShowCheckedModeBanner: false,
        theme: Tema.terang,
        darkTheme: Tema.gelap,
        themeMode: ThemeMode.system,
        initialRoute: RuteAplikasi.gerbang,
        routes: RuteAplikasi.rute,
      ),
    );
  }
}
