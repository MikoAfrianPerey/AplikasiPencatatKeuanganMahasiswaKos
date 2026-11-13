import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/model/Transaksi.dart';
import '../../../data/repository/RepositoryKategori.dart';
import '../../../data/repository/RepositoryTransaksi.dart';
import '../../../inti/routing/RuteAplikasi.dart';
import '../../../inti/state/StatusData.dart';
import '../../../inti/utils/DataBeranda.dart';
import '../../../inti/utils/PemetaIkon.dart';
import '../../../inti/utils/PemformatMataUang.dart';
import '../../../inti/utils/PemformatTanggal.dart';
import '../../../inti/utils/UmpanBalik.dart';
import '../../widget/StateKosong.dart';
import '../../widget/TampilanStatus.dart';

class LayarRiwayatTransaksi extends StatefulWidget {
  const LayarRiwayatTransaksi({super.key});

  @override
  State<LayarRiwayatTransaksi> createState() => _KeadaanLayarRiwayatTransaksi();
}

class _KeadaanLayarRiwayatTransaksi extends State<LayarRiwayatTransaksi> {
  DataBeranda _data = const DataBeranda(transaksi: [], kategori: []);
  String _filterKategori = 'Semua';
  bool _sedangMemuat = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    if (mounted) {
      setState(() {
        _sedangMemuat = true;
        _error = null;
      });
    }
    final repoTransaksi = context.read<RepositoryTransaksi>();
    final repoKategori = context.read<RepositoryKategori>();
    try {
      final data = await DataBeranda.muat(
        transaksi: repoTransaksi,
        kategori: repoKategori,
      );
      if (mounted) {
        setState(() {
          _data = data;
          _sedangMemuat = false;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _sedangMemuat = false;
          _error = pesanException(error);
        });
      }
    }
  }

  List<String> get _daftarFilter {
    final filters = ['Semua'];
    for (final k in _data.kategori) {
      if (!filters.contains(k.nama)) filters.add(k.nama);
    }
    return filters;
  }

  List<Transaksi> get _transaksiDifilter {
    if (_filterKategori == 'Semua') return _data.transaksi;
    return _data.transaksi
        .where((t) => _data.namaKategori(t.idKategori) == _filterKategori)
        .toList();
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
    final navigator = Navigator.of(context);
    final pesan = await navigator.pushNamed(
      RuteAplikasi.editTransaksi,
      arguments: transaksi,
    );
    await _muatData();
    if (pesan is String && mounted) UmpanBalik.sukses(context, pesan);
  }

  Future<void> _hapusTransaksi(Transaksi transaksi) async {
    final konfirmasi = await _konfirmasiHapus(transaksi);
    if (konfirmasi != true || !mounted) return;
    final repoTransaksi = context.read<RepositoryTransaksi>();
    try {
      await repoTransaksi.hapus(transaksi.id);
      await _muatData();
      if (mounted) UmpanBalik.sukses(context, 'Transaksi berhasil dihapus');
    } on Exception catch (error) {
      if (mounted) UmpanBalik.galat(context, 'Gagal menghapus: $error');
    }
  }

  Future<bool?> _konfirmasiHapus(Transaksi transaksi) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: Text(
          'Transaksi ${_data.namaKategori(transaksi.idKategori)} '
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
      body: TampilanStatus(
        sedangMemuat: _sedangMemuat,
        pesanMemuat: 'Memuat riwayat transaksi...',
        error: _error,
        judulError: 'Gagal memuat transaksi dari server',
        ikonError: Icons.wifi_off,
        saatCobaLagi: _muatData,
        child: Column(
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
                                  final kat =
                                      _data.cariKategori(item.idKategori);
                                  final adalahPemasukan = item.jenisTransaksi ==
                                      JenisTransaksi.pemasukan;
                                  return Dismissible(
                                    key: ValueKey(item.id),
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
                                            : Colors.grey.withOpacity(0.15),
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
                                          _data.namaKategori(item.idKategori)),
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
      ),
    );
  }
}
