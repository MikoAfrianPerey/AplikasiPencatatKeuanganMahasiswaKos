import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/model/Transaksi.dart';
import '../../../data/repository/RepositoryKategori.dart';
import '../../../data/repository/RepositoryTransaksi.dart';
import '../../../inti/state/StatusData.dart';
import '../../../inti/utils/DataBeranda.dart';
import '../../../inti/utils/PemformatMataUang.dart';
import '../../../inti/utils/TataLetak.dart';
import '../../widget/StateKosong.dart';
import '../../widget/TampilanStatus.dart';

class LayarLaporan extends StatefulWidget {
  const LayarLaporan({super.key});

  @override
  State<LayarLaporan> createState() => _KeadaanLayarLaporan();
}

class _KeadaanLayarLaporan extends State<LayarLaporan>
    with SingleTickerProviderStateMixin {
  late final TabController _kontrolTab;
  DataBeranda _data = const DataBeranda(transaksi: [], kategori: []);
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
    final repoTransaksi = context.read<RepositoryTransaksi>();
    final repoKategori = context.read<RepositoryKategori>();
    try {
      final data = await DataBeranda.muat(
        transaksi: repoTransaksi,
        kategori: repoKategori,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
        _sedangMemuat = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sedangMemuat = false;
        _error = pesanException(error);
      });
    }
  }

  List<Transaksi> _dalamRentang(bool mingguan) {
    final sekarang = DateTime.now();
    final batas = mingguan
        ? sekarang.subtract(const Duration(days: 7))
        : DateTime(sekarang.year, sekarang.month, 1);
    return _data.transaksi
        .where((t) => !t.tanggalTransaksi.isBefore(batas))
        .where((t) => t.jenisTransaksi == JenisTransaksi.pengeluaran)
        .toList();
  }

  Map<String, int> _komposisi(List<Transaksi> daftar) {
    final hasil = <String, int>{};
    for (final transaksi in daftar) {
      final nama = _data.namaKategori(transaksi.idKategori);
      hasil[nama] = (hasil[nama] ?? 0) + transaksi.jumlah;
    }
    return hasil;
  }

  List<double> _harian(List<Transaksi> daftar) {
    final harian = List<double>.filled(7, 0);
    for (final transaksi in daftar) {
      harian[transaksi.tanggalTransaksi.weekday - 1] += transaksi.jumlah;
    }
    return harian;
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
      body: TampilanStatus(
        sedangMemuat: _sedangMemuat,
        pesanMemuat: 'Menghitung laporan...',
        error: _error,
        judulError: 'Gagal memuat laporan',
        ikonError: Icons.cloud_off,
        saatCobaLagi: _muatData,
        child: LayarTataLetak(
          child: TabBarView(
            controller: _kontrolTab,
            children: [
              _tabLaporan(true),
              _tabLaporan(false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabLaporan(bool mingguan) {
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _kartuTotal(mingguan, total),
        const SizedBox(height: 24),
        const _JudulBagian('Komposisi Pengeluaran per Kategori'),
        const SizedBox(height: 16),
        _grafikLingkaran(urutan, total),
        const SizedBox(height: 16),
        _daftarKomposisi(urutan, total),
        if (mingguan) ...[
          const SizedBox(height: 24),
          const _JudulBagian('Pengeluaran Harian'),
          const SizedBox(height: 16),
          _grafikHarian(_harian(daftar)),
        ],
        const SizedBox(height: 24),
        const _JudulBagian('Kategori Pengeluaran Terbesar'),
        const SizedBox(height: 8),
        _kartuTerbesar(urutan.first),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _kartuTotal(bool mingguan, int total) {
    final tema = Theme.of(context);
    return Card(
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
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                PemformatMataUang.format(total),
                style: tema.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _warnaIndeks(int index) =>
      Colors.primaries[index % Colors.primaries.length];

  Widget _grafikLingkaran(List<MapEntry<String, int>> urutan, int total) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 48,
          sections: urutan.asMap().entries.map((entry) {
            final persen = (entry.value.value / total) * 100;
            return PieChartSectionData(
              value: entry.value.value.toDouble(),
              color: _warnaIndeks(entry.key),
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
    );
  }

  Widget _daftarKomposisi(List<MapEntry<String, int>> urutan, int total) {
    final tema = Theme.of(context);
    return Card(
      child: Column(
        children: urutan.asMap().entries.map((entry) {
          final warna = _warnaIndeks(entry.key);
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
    );
  }

  Widget _grafikHarian(List<double> harian) {
    final tema = Theme.of(context);
    const label = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
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
    );
  }

  Widget _kartuTerbesar(MapEntry<String, int> terbesar) {
    final tema = Theme.of(context);
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.trending_up)),
        title: Text(terbesar.key),
        subtitle: const Text('Pengeluaran terbesar periode ini'),
        trailing: Text(
          PemformatMataUang.format(terbesar.value),
          style: tema.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _JudulBagian extends StatelessWidget {
  final String teks;

  const _JudulBagian(this.teks);

  @override
  Widget build(BuildContext context) {
    return Text(
      teks,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class LayarTataLetak extends StatelessWidget {
  final Widget child;

  const LayarTataLetak({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TataLetak.pusatkan(context, child);
  }
}
