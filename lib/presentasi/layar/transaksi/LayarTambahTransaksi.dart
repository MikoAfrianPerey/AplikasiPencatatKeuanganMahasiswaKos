import 'package:flutter/material.dart';

import '../../../inti/utils/PemformatTanggal.dart';
import '../../widget/TombolUtama.dart';

class LayarTambahTransaksi extends StatefulWidget {
  const LayarTambahTransaksi({super.key});

  @override
  State<LayarTambahTransaksi> createState() => _KeadaanLayarTambahTransaksi();
}

class _KeadaanLayarTambahTransaksi extends State<LayarTambahTransaksi> {
  bool _adalahPemasukan = false;
  String _jumlah = '0';
  String _kategoriTerpilih = 'Makan';
  DateTime _tanggal = DateTime.now();
  final _controllerCatatan = TextEditingController();

  static const List<Map<String, dynamic>> _kategori = [
    {'nama': 'Makan', 'ikon': Icons.restaurant, 'warna': Colors.orange},
    {'nama': 'Kos', 'ikon': Icons.home, 'warna': Colors.green},
    {'nama': 'Transport', 'ikon': Icons.directions_bus, 'warna': Colors.blue},
    {'nama': 'Lain-lain', 'ikon': Icons.category, 'warna': Colors.purple},
  ];

  @override
  void dispose() {
    _controllerCatatan.dispose();
    super.dispose();
  }

  void _ketik(String nilai) {
    setState(() {
      if (_jumlah == '0' && nilai != '000') {
        _jumlah = nilai;
      } else if (_jumlah == '0' && nilai == '000') {
        _jumlah = '0';
      } else {
        _jumlah += nilai;
      }
    });
  }

  void _hapus() {
    setState(() {
      if (_jumlah.length > 1) {
        _jumlah = _jumlah.substring(0, _jumlah.length - 1);
      } else {
        _jumlah = '0';
      }
    });
  }

  void _reset() {
    setState(() {
      _jumlah = '0';
      _kategoriTerpilih = 'Makan';
      _tanggal = DateTime.now();
      _controllerCatatan.clear();
    });
  }

  Future<void> _pilihTanggal() async {
    final dipilih = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (dipilih != null) {
      setState(() => _tanggal = dipilih);
    }
  }

  void _simpan() {
    final jumlah = int.tryParse(_jumlah) ?? 0;
    if (jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah yang valid')),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaksi ${_adalahPemasukan ? 'pemasukan' : 'pengeluaran'} '
          '$_kategoriTerpilih berhasil disimpan',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final jumlahFormat = int.tryParse(_jumlah) ?? 0;
    final mataUang = _formatRupiah(jumlahFormat);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('Pengeluaran')),
                          ButtonSegment(value: true, label: Text('Pemasukan')),
                        ],
                        selected: {_adalahPemasukan},
                        onSelectionChanged: (pilihan) {
                          setState(() => _adalahPemasukan = pilihan.first);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        mataUang,
                        style: tema.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _adalahPemasukan ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _kategori.length,
                        itemBuilder: (context, index) {
                          final item = _kategori[index];
                          final terpilih = item['nama'] == _kategoriTerpilih;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(item['nama']),
                              avatar: Icon(item['ikon'], color: item['warna']),
                              selected: terpilih,
                              onSelected: (_) {
                                setState(() => _kategoriTerpilih = item['nama']);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Tanggal Transaksi'),
                      subtitle: Text(PemformatTanggal.formatPanjang(_tanggal)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _pilihTanggal,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controllerCatatan,
                        decoration: const InputDecoration(
                          labelText: 'Catatan (opsional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TombolUtama(
                        label: 'Simpan Transaksi',
                        ikon: Icons.save,
                        saatDitekan: _simpan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.6,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final tombol = _tombolKeypad(index);
                final adalahHapus = tombol == '⌫';

                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: FilledButton(
                    onPressed: adalahHapus ? _hapus : () => _ketik(tombol),
                    style: FilledButton.styleFrom(
                      backgroundColor: adalahHapus
                          ? tema.colorScheme.errorContainer
                          : tema.colorScheme.surfaceContainerHighest,
                      foregroundColor: adalahHapus
                          ? tema.colorScheme.onErrorContainer
                          : tema.colorScheme.onSurface,
                    ),
                    child: Text(
                      tombol,
                      style: tema.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _tombolKeypad(int index) {
    const tombol = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '000', '0', '⌫'];
    return tombol[index];
  }

  String _formatRupiah(int jumlah) {
    final buffer = StringBuffer('Rp ');
    final str = jumlah.toString();
    final regexp = RegExp(r'\B(?=(\d{3})+(?!\d))');
    buffer.write(str.replaceAllMapped(regexp, (match) => '.'));
    return buffer.toString();
  }
}
