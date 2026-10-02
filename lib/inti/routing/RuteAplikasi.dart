import 'package:flutter/material.dart';

import '../../presentasi/layar/dashboard/LayarDashboard.dart';
import '../../presentasi/layar/laporan/LayarLaporan.dart';
import '../../presentasi/layar/onboarding/LayarOnboarding.dart';
import '../../presentasi/layar/pengaturan/LayarPengaturan.dart';
import '../../presentasi/layar/transaksi/LayarRiwayatTransaksi.dart';
import '../../presentasi/layar/transaksi/LayarTambahTransaksi.dart';

class RuteAplikasi {
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String tambahTransaksi = '/tambah-transaksi';
  static const String riwayatTransaksi = '/riwayat-transaksi';
  static const String laporan = '/laporan';
  static const String pengaturan = '/pengaturan';

  static Map<String, WidgetBuilder> get rute => {
        onboarding: (_) => const LayarOnboarding(),
        dashboard: (_) => const LayarDashboard(),
        tambahTransaksi: (_) => const LayarTambahTransaksi(),
        riwayatTransaksi: (_) => const LayarRiwayatTransaksi(),
        laporan: (_) => const LayarLaporan(),
        pengaturan: (_) => const LayarPengaturan(),
      };
}
