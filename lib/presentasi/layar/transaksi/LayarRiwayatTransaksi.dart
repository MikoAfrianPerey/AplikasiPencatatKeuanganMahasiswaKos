import 'package:flutter/material.dart';

import '../../widget/StateKosong.dart';

class LayarRiwayatTransaksi extends StatefulWidget {
  const LayarRiwayatTransaksi({super.key});

  @override
  State<LayarRiwayatTransaksi> createState() => _KeadaanLayarRiwayatTransaksi();
}

class _KeadaanLayarRiwayatTransaksi extends State<LayarRiwayatTransaksi> {
  String _filterKategori = 'Semua';

  static const List<Map<String, dynamic>> _transaksi = [
    {
      'kategori': 'Makan',
      'catatan': 'Nasi goreng malam',
      'tanggal': '2 Okt 2026',
      'jumlah': 'Rp 25.000',
      'ikon': Icons.restaurant,
      'warna': Colors.orange,
      'masuk': false,
    },
    {
      'kategori': 'Transport',
      'catatan': 'Gojek ke kampus',
      'tanggal': '2 Okt 2026',
      'jumlah': 'Rp 18.000',
      'ikon': Icons.directions_bus,
      'warna': Colors.blue,
      'masuk': false,
    },
    {
      'kategori': 'Kos',
      'catatan': 'Bayar kos bulanan',
      'tanggal': '1 Okt 2026',
      'jumlah': 'Rp 500.000',
      'ikon': Icons.home,
      'warna': Colors.green,
      'masuk': false,
    },
    {
      'kategori': 'Pemasukan',
      'catatan': 'Uang bulanan dari ortu',
      'tanggal': '1 Okt 2026',
      'jumlah': 'Rp 1.500.000',
      'ikon': Icons.account_balance_wallet,
      'warna': Colors.teal,
      'masuk': true,
    },
    {
      'kategori': 'Lain-lain',
      'catatan': 'Voucher game',
      'tanggal': '30 Sep 2026',
      'jumlah': 'Rp 50.000',
      'ikon': Icons.category,
      'warna': Colors.purple,
      'masuk': false,
    },
  ];

  static const List<String> _daftarFilter = [
    'Semua',
    'Makan',
    'Kos',
    'Transport',
    'Lain-lain',
  ];

  List<Map<String, dynamic>> get _transaksiDifilter {
    if (_filterKategori == 'Semua') return _transaksi;
    return _transaksi.where((t) => t['kategori'] == _filterKategori).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _transaksiDikelompokkan {
    final hasil = <String, List<Map<String, dynamic>>>{};
    for (final item in _transaksiDifilter) {
      hasil.putIfAbsent(item['tanggal'], () => []).add(item);
    }
    return hasil;
  }

  Future<bool?> _konfirmasiHapus(String kategori, String jumlah) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: Text('Transaksi $kategori sebesar $jumlah akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final kelompok = _transaksiDikelompokkan;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _daftarFilter.length,
              itemBuilder: (context, index) {
                final filter = _daftarFilter[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: filter == _filterKategori,
                    onSelected: (_) {
                      setState(() => _filterKategori = filter);
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: kelompok.isEmpty
                ? const StateKosong(
                    ikon: Icons.receipt_long,
                    judul: 'Belum Ada Transaksi',
                    pesan: 'Transaksi pada kategori ini belum ada. '
                        'Coba pilih kategori lain atau tambah transaksi baru.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: kelompok.length,
                    itemBuilder: (context, index) {
                      final tanggal = kelompok.keys.elementAt(index);
                      final daftar = kelompok[tanggal]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              tanggal,
                              style: tema.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tema.colorScheme.primary,
                              ),
                            ),
                          ),
                          Card(
                            child: Column(
                              children: daftar.map((item) {
                                return Dismissible(
                                  key: ValueKey('${item['kategori']}'
                                      '${item['jumlah']}$tanggal${item['catatan']}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 16),
                                    color: Colors.red,
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (_) => _konfirmasiHapus(
                                    item['kategori'],
                                    item['jumlah'],
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          (item['warna'] as Color)
                                              .withOpacity(0.15),
                                      child: Icon(
                                        item['ikon'],
                                        color: item['warna'],
                                      ),
                                    ),
                                    title: Text(item['kategori']),
                                    subtitle: Text(item['catatan']),
                                    trailing: Text(
                                      '${item['masuk'] ? '+' : '-'} ${item['jumlah']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: item['masuk']
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
