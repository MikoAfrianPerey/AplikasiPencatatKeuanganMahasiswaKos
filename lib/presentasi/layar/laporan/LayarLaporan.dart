import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/model/Kategori.dart';
import '../../../data/model/Transaksi.dart';
import '../../../data/repository/RepositoryKategori.dart';
import '../../../data/repository/RepositoryTransaksi.dart';
import '../../../inti/utils/PemformatMataUang.dart';
import '../../widget/StateKosong.dart';
import '../../widget/TombolUtama.dart';

class LayarLaporan extends StatefulWidget {
  const LayarLaporan({super.key});

  @override
  State<LayarLaporan> createState() => _KeadaanLayarLaporan();
}

class _KeadaanLayarLaporan extends State<LayarLaporan>
    with SingleTickerProviderStateMixin {
  late final TabController _kontrolTab;
  List<Transaksi> _transaksi = [];
  List<Kategori> _kategori = [];
  bool _sedangMemuat = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _kontrolTab = TabController(length: 2, vsync: this);
    _muatData();
  }

  @override
  void dispose() {
    _kontrolTab.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    setState(() {
      _sedangMemuat = true;
      _error = null;
    });
    try {
      final transaksi = await context.read<RepositoryTransaksi>().ambilSemua();
      final kategori = await context.read<RepositoryKategori>().ambilSemua();
      if (!mounted) return;
      setState(() {
        _transaksi = transaksi;
        _kategori = kategori;
        _sedangMemuat = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sedangMemuat = false;
        _error = error.toString();
      });
    }
  }

  List<Transaksi> _dalamRentang(bool mingguan) {
    final sekarang = DateTime.now();
    final batas = mingguan
        ? sekarang.subtract(const Duration(days: 7))
        : DateTime(sekarang.year, sekarang.month, 1);
    return _transaksi
        .where((t) => !t.tanggalTransaksi.isBefore(batas))
        .where((t) => t.jenisTransaksi == JenisTransaksi.pengeluaran)
        .toList();
  }

  Map<String, int> _komposisi(List<Transaksi> daftar) {
    final hasil = <String, int>{};
    for (final transaksi in daftar) {
      final cocok = _kategori.where((k) => k.id == transaksi.idKategori);
      final nama = cocok.isEmpty ? 'Lain-lain' : cocok.first.nama;
      hasil[nama] = (hasil[nama] ?? 0) + transaksi.jumlah;
    }
    return hasil;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        bottom: TabBar(
          controller: _kontrolTab,
          tabs: const [
            Tab(text: 'Mingguan'),
            Tab(text: 'Bulanan'),
          ],
        ),
      ),
      body: _sedangMemuat
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _bangunError()
              : TabBarView(
                  controller: _kontrolTab,
                  children: [
                    _tabLaporan(true),
                    _tabLaporan(false),
                  ],
                ),
    );
  }

  Widget _bangunError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            const Text('Gagal memuat laporan'),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TombolUtama(
              label: 'Coba Lagi',
              ikon: Icons.refresh,
              saatDitekan: _muatData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabLaporan(bool mingguan) {
    final tema = Theme.of(context);
    final daftar = _dalamRentang(mingguan);
    if (daftar.isEmpty) {
      return const StateKosong(
        ikon: Icons.bar_chart,
        judul: 'Belum Ada Data Laporan',
        pesan: 'Catat transaksi pengeluaran untuk melihat laporan di sini.',
      );
    }

    final komposisi = _komposisi(daftar);
    final total = komposisi.values.fold(0, (a, b) => a + b);
    final urutan = komposisi.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final harian = List<double>.filled(7, 0);
    for (final transaksi in daftar) {
      harian[transaksi.tanggalTransaksi.weekday - 1] += transaksi.jumlah;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pengeluaran ${mingguan ? 'Mingguan' : 'Bulanan'}',
                  style: tema.textTheme.titleSmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  PemformatMataUang.format(total),
                  style: tema.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Komposisi Pengeluaran per Kategori',
          style: tema.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              sections: urutan.asMap().entries.map((entry) {
                final persen = (entry.value.value / total) * 100;
                return PieChartSectionData(
                  value: entry.value.value.toDouble(),
                  color: Colors.primaries[entry.key % Colors.primaries.length],
                  title: '${persen.toStringAsFixed(0)}%',
                  radius: 56,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: urutan.asMap().entries.map((entry) {
              final warna =
                  Colors.primaries[entry.key % Colors.primaries.length];
              final persen = (entry.value.value / total) * 100;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: warna.withOpacity(0.15),
                  child: Icon(Icons.circle, color: warna, size: 12),
                ),
                title: Text(entry.value.key),
                trailing: Text(
                  '${PemformatMataUang.format(entry.value.value)} '
                  '(${persen.toStringAsFixed(0)}%)',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (mingguan) ...[
          const SizedBox(height: 24),
          Text(
            'Pengeluaran Harian',
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const label = [
                          'Sen',
                          'Sel',
                          'Rab',
                          'Kam',
                          'Jum',
                          'Sab',
                          'Min',
                        ];
                        final index = value.toInt();
                        if (index < 0 || index >= label.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(label[index]),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: harian.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: tema.colorScheme.primary,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Kategori Pengeluaran Terbesar',
          style: tema.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.trending_up)),
            title: Text(urutan.first.key),
            subtitle: const Text('Pengeluaran terbesar periode ini'),
            trailing: Text(
              PemformatMataUang.format(urutan.first.value),
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
