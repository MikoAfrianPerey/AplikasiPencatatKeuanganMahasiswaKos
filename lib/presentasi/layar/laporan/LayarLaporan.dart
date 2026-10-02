import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../widget/StateKosong.dart';

class LayarLaporan extends StatefulWidget {
  const LayarLaporan({super.key});

  @override
  State<LayarLaporan> createState() => _KeadaanLayarLaporan();
}

class _KeadaanLayarLaporan extends State<LayarLaporan>
    with SingleTickerProviderStateMixin {
  late final TabController _kontrolTab;

  static const List<Map<String, dynamic>> _dataKategori = [
    {'nama': 'Kos', 'jumlah': 500000, 'warna': Colors.green},
    {'nama': 'Makan', 'jumlah': 420000, 'warna': Colors.orange},
    {'nama': 'Transport', 'jumlah': 90000, 'warna': Colors.blue},
    {'nama': 'Lain-lain', 'jumlah': 60000, 'warna': Colors.purple},
  ];

  static const List<double> _pengeluaranHarian = [
    25000,
    18000,
    500000,
    0,
    42000,
    31000,
    27000,
  ];

  static const List<String> _labelHari = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  @override
  void initState() {
    super.initState();
    _kontrolTab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _kontrolTab.dispose();
    super.dispose();
  }

  double get _totalPengeluaran =>
      _dataKategori.fold(0, (total, item) => total + (item['jumlah'] as int));

  String _formatRupiah(int jumlah) {
    final str = jumlah.toString();
    final regexp = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return 'Rp ${str.replaceAllMapped(regexp, (match) => '.')}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

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
      body: TabBarView(
        controller: _kontrolTab,
        children: [
          _tabLaporan('Mingguan', tema),
          _tabLaporan('Bulanan', tema),
        ],
      ),
    );
  }

  Widget _tabLaporan(String jenis, ThemeData tema) {
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
                  'Total Pengeluaran $jenis',
                  style: tema.textTheme.titleSmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRupiah(_totalPengeluaran.toInt()),
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
              sections: _dataKategori.map((item) {
                final jumlah = item['jumlah'] as int;
                final persen = (jumlah / _totalPengeluaran) * 100;

                return PieChartSectionData(
                  value: jumlah.toDouble(),
                  color: item['warna'],
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
            children: _dataKategori.map((item) {
              final jumlah = item['jumlah'] as int;
              final persen = (jumlah / _totalPengeluaran) * 100;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: (item['warna'] as Color).withOpacity(0.15),
                  child: Icon(Icons.circle, color: item['warna'], size: 12),
                ),
                title: Text(item['nama']),
                trailing: Text(
                  '${_formatRupiah(jumlah)} (${persen.toStringAsFixed(0)}%)',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
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
                      final index = value.toInt();
                      if (index < 0 || index >= _labelHari.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(_labelHari[index]),
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
              barGroups: _pengeluaranHarian.asMap().entries.map((entry) {
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
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.home, color: Colors.white),
            ),
            title: const Text('Kos'),
            subtitle: const Text('Pengeluaran terbesar bulan ini'),
            trailing: Text(
              _formatRupiah(500000),
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const StateKosong(
          ikon: Icons.bar_chart,
          judul: 'Data Laporan Lengkap',
          pesan: 'Grafik detail akan tersedia setelah transaksi tercatat '
              'dalam database.',
        ),
      ],
    );
  }
}
