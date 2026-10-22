import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/model/Kategori.dart';
import '../../../data/model/Transaksi.dart';
import '../../../data/repository/RepositoryKategori.dart';
import '../../../data/repository/RepositoryTransaksi.dart';
import '../../../inti/routing/RuteAplikasi.dart';
import '../../../inti/utils/PemetaIkon.dart';
import '../../../inti/utils/PemformatMataUang.dart';
import '../../../inti/utils/PemformatTanggal.dart';
import '../../widget/StateKosong.dart';

class LayarRiwayatTransaksi extends StatefulWidget {
  const LayarRiwayatTransaksi({super.key});

  @override
  State<LayarRiwayatTransaksi> createState() => _KeadaanLayarRiwayatTransaksi();
}

class _KeadaanLayarRiwayatTransaksi extends State<LayarRiwayatTransaksi> {
  List<Transaksi> _semuaTransaksi = [];
  List<Kategori> _kategori = [];
  String _filterKategori = 'Semua';
  bool _sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final repoTransaksi = context.read<RepositoryTransaksi>();
    final repoKategori = context.read<RepositoryKategori>();
    try {
      final transaksi = await repoTransaksi.ambilSemua();
      final kategori = await repoKategori.ambilSemua();
      if (mounted) {
        setState(() {
          _semuaTransaksi = transaksi;
          _kategori = kategori;
          _sedangMemuat = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _sedangMemuat = false);
    }
  }

  List<String> get _daftarFilter {
    final filters = ['Semua'];
    for (final k in _kategori) {
      if (!filters.contains(k.nama)) filters.add(k.nama);
    }
    return filters;
  }

  Kategori? _cariKategori(int idKategori) {
    final k = _kategori.where((k) => k.id == idKategori);
    return k.isNotEmpty ? k.first : null;
  }

  String _namaKategori(int idKategori) {
    return _cariKategori(idKategori)?.nama ?? 'Lain-lain';
  }

  List<Transaksi> get _transaksiDifilter {
    if (_filterKategori == 'Semua') return _semuaTransaksi;
    return _semuaTransaksi.where((t) {
      return _namaKategori(t.idKategori) == _filterKategori;
    }).toList();
  }

  Map<String, List<Transaksi>> get _transaksiDikelompokkan {
    final hasil = <String, List<Transaksi>>{};
    for (final item in _transaksiDifilter) {
      final tanggal = PemformatTanggal.formatPendek(item.tanggalTransaksi);
      hasil.putIfAbsent(tanggal, () => []).add(item);
    }
    return hasil;
  }

  Future<void> _editTransaksi(Transaksi transaksi) async {
    await Navigator.pushNamed(
      context,
      RuteAplikasi.editTransaksi,
      arguments: transaksi,
    );
    if (mounted) _muatData();
  }

  Future<void> _hapusTransaksi(Transaksi transaksi) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: Text(
          'Transaksi ${_namaKategori(transaksi.idKategori)} '
          'sebesar ${PemformatMataUang.format(transaksi.jumlah)} akan dihapus.',
        ),
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

    if (konfirmasi == true && mounted) {
      await context.read<RepositoryTransaksi>().hapus(transaksi.id);
      _muatData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final kelompok = _transaksiDikelompokkan;
    final daftarFilter = _daftarFilter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(28),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Ketuk transaksi untuk mengedit, geser ke kiri untuk menghapus',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
      body: _sedangMemuat
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: daftarFilter.length,
                    itemBuilder: (context, index) {
                      final filter = daftarFilter[index];
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
                          pesan:
                              'Transaksi pada kategori ini belum ada. '
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    tanggal,
                                    style:
                                        tema.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: tema.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Card(
                                  child: Column(
                                    children: daftar.map((item) {
                                      final kat =
                                          _cariKategori(item.idKategori);
                                      final adalahPemasukan =
                                          item.jenisTransaksi ==
                                              JenisTransaksi.pemasukan;
                                      return Dismissible(
                                        key: ValueKey(item.id),
                                        direction:
                                            DismissDirection.endToStart,
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.only(
                                              right: 16),
                                          color: Colors.red,
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                        confirmDismiss: (_) async {
                                          await _hapusTransaksi(item);
                                          return false;
                                        },
                                        child: ListTile(
                                          onTap: () => _editTransaksi(item),
                                          leading: CircleAvatar(
                                            backgroundColor: kat != null
                                                ? Color(kat.nilaiWarna)
                                                    .withOpacity(0.15)
                                                : Colors.grey
                                                    .withOpacity(0.15),
                                            child: Icon(
                                              kat != null
                                                  ? PemetaIkon.dariNama(
                                                      kat.namaIkon)
                                                  : Icons.category,
                                              color: kat != null
                                                  ? Color(kat.nilaiWarna)
                                                  : Colors.grey,
                                            ),
                                          ),
                                          title: Text(
                                              _namaKategori(item.idKategori)),
                                          subtitle: Text(item.catatan.isNotEmpty
                                              ? item.catatan
                                              : 'Tidak ada catatan'),
                                          trailing: Text(
                                            '${adalahPemasukan ? '+' : '-'} ${PemformatMataUang.format(item.jumlah)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: adalahPemasukan
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
