import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/database/BantuanDatabase.dart';
import 'data/repository/RepositoryKategori.dart';
import 'data/repository/RepositoryKategoriSqlite.dart';
import 'data/repository/RepositoryPeriodeBudget.dart';
import 'data/repository/RepositoryPeriodeBudgetSqlite.dart';
import 'data/repository/RepositoryTransaksi.dart';
import 'data/repository/RepositoryTransaksiSqlite.dart';
import 'inti/routing/RuteAplikasi.dart';
import 'inti/tema/Tema.dart';
import 'provider/ProviderOnboarding.dart';
import 'provider/ProviderPengaturan.dart';
import 'provider/ProviderTransaksi.dart';

class AplikasiDompetKos extends StatelessWidget {
  const AplikasiDompetKos({super.key});

  @override
  Widget build(BuildContext context) {
    // ──────────────────────────────────────────────────────────────
    // LOCAL DATA & PERSISTENCE — SQLite via sqflite
    // Database helper singleton (BantuanDatabase) diinisialisasi
    // sekali, lalu di-inject ke setiap repository SQLite.
    // ──────────────────────────────────────────────────────────────
    final db = BantuanDatabase.instance;

    return MultiProvider(
      providers: [
        // ── Repository Layer (SQLite) ─────────────────────────────
        Provider<RepositoryKategori>(
          create: (_) => RepositoryKategoriSqlite(db),
        ),
        Provider<RepositoryPeriodeBudget>(
          create: (_) => RepositoryPeriodeBudgetSqlite(db),
        ),
        Provider<RepositoryTransaksi>(
          create: (_) => RepositoryTransaksiSqlite(db),
        ),
        // ── Provider / State Management ───────────────────────────
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
