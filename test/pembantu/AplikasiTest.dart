import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../lib/data/repository/RepositoryKategori.dart';
import '../../lib/data/repository/RepositoryPeriodeBudget.dart';
import '../../lib/data/repository/RepositoryTransaksi.dart';
import '../../lib/inti/routing/RuteAplikasi.dart';
import '../../lib/presentasi/layar/onboarding/LayarOnboarding.dart';
import '../../lib/presentasi/layar/transaksi/LayarTambahTransaksi.dart';
import '../../lib/provider/ProviderOnboarding.dart';
import '../../lib/provider/ProviderTransaksi.dart';

const String labelDashboard = 'Dashboard Pengganti';
const String labelBeranda = 'Beranda Pengganti';

void aturUkuranPonsel(WidgetTester tester) {
  tester.view.physicalSize = const Size(411, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget aplikasiOnboardingTest({
  required RepositoryKategori repositoryKategori,
  required RepositoryPeriodeBudget repositoryPeriodeBudget,
}) {
  return MaterialApp(
    routes: {
      RuteAplikasi.dashboard: (_) =>
          const Scaffold(body: Center(child: Text(labelDashboard))),
    },
    home: MultiProvider(
      providers: [
        Provider<RepositoryKategori>.value(value: repositoryKategori),
        Provider<RepositoryPeriodeBudget>.value(value: repositoryPeriodeBudget),
        ChangeNotifierProvider<ProviderOnboarding>(
          create: (_) => ProviderOnboarding(
            repositoryKategori,
            repositoryPeriodeBudget,
          ),
        ),
      ],
      child: const LayarOnboarding(),
    ),
  );
}

Widget aplikasiTambahTransaksiTest({
  required RepositoryKategori repositoryKategori,
  required RepositoryTransaksi repositoryTransaksi,
  bool navigasi = false,
}) {
  final layar = MultiProvider(
    providers: [
      Provider<RepositoryKategori>.value(value: repositoryKategori),
      Provider<RepositoryTransaksi>.value(value: repositoryTransaksi),
      ChangeNotifierProvider<ProviderTransaksi>(
        create: (_) => ProviderTransaksi(
          repositoryKategori,
          repositoryTransaksi,
        ),
      ),
    ],
    child: const LayarTambahTransaksi(),
  );

  if (!navigasi) {
    return MaterialApp(home: layar);
  }

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.pushNamed(
              context,
              RuteAplikasi.tambahTransaksi,
            ),
            child: const Text(labelBeranda),
          ),
        ),
      ),
    ),
    routes: {
      RuteAplikasi.tambahTransaksi: (_) => layar,
    },
  );
}
