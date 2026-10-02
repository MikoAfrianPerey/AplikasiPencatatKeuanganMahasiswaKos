import 'package:flutter/material.dart';

import '../../../inti/routing/RuteAplikasi.dart';
import '../../widget/ItemKategori.dart';
import '../../widget/ItemTransaksi.dart';
import '../../widget/KartuSaldo.dart';

class LayarDashboard extends StatelessWidget {
  const LayarDashboard({super.key});

  void _bukaLaporan(BuildContext context) {
    Navigator.pushNamed(context, RuteAplikasi.laporan);
  }

  void _bukaPengaturan(BuildContext context) {
    Navigator.pushNamed(context, RuteAplikasi.pengaturan);
  }

  void _bukaRiwayat(BuildContext context) {
    Navigator.pushNamed(context, RuteAplikasi.riwayatTransaksi);
  }

  void _tambahTransaksi(BuildContext context) {
    Navigator.pushNamed(context, RuteAplikasi.tambahTransaksi);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DompetKos'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Laporan',
            onPressed: () => _bukaLaporan(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan',
            onPressed: () => _bukaPengaturan(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const KartuSaldo(
            sisaSaldo: 807000,
            totalPemasukan: 1500000,
            totalPengeluaran: 693000,
            sisaHari: 29,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Batas Kategori',
                style: tema.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _bukaPengaturan(context),
                child: const Text('Atur Batas'),
              ),
            ],
          ),
          const Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ItemKategori(nama: 'Makan', batas: 600000, terpakai: 420000),
                  ItemKategori(nama: 'Kos', batas: 500000, terpakai: 500000),
                  ItemKategori(nama: 'Transport', batas: 200000, terpakai: 90000),
                  ItemKategori(nama: 'Lain-lain', batas: 200000, terpakai: 60000),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaksi Terbaru',
                style: tema.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _bukaRiwayat(context),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const Card(
            child: Column(
              children: [
                ItemTransaksi(
                  ikon: Icons.restaurant,
                  warnaIkon: Colors.orange,
                  kategori: 'Makan',
                  catatan: 'Nasi goreng malam',
                  tanggal: '2 Okt 2026',
                  jumlah: 'Rp 25.000',
                  adalahPemasukan: false,
                ),
                ItemTransaksi(
                  ikon: Icons.directions_bus,
                  warnaIkon: Colors.blue,
                  kategori: 'Transport',
                  catatan: 'Gojek ke kampus',
                  tanggal: '2 Okt 2026',
                  jumlah: 'Rp 18.000',
                  adalahPemasukan: false,
                ),
                ItemTransaksi(
                  ikon: Icons.home,
                  warnaIkon: Colors.green,
                  kategori: 'Kos',
                  catatan: 'Bayar kos bulanan',
                  tanggal: '1 Okt 2026',
                  jumlah: 'Rp 500.000',
                  adalahPemasukan: false,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
        onPressed: () => _tambahTransaksi(context),
      ),
    );
  }
}
