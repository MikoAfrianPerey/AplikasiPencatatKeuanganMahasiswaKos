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
import '../../widget/KartuSaldo.dart';
import '../../widget/StateKosong.dart';

class LayarDashboard extends StatefulWidget {
  const LayarDashboard({super.key});

  @override
  State<LayarDashboard> createState() => _KeadaanLayarDashboard();
}

class _KeadaanLayarDashboard extends State<LayarDashboard> {
  List<Transaksi> _transaksi = [];
  List<Kategori> _kategori = [];
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
          _transaksi = transaksi;
          _kategori = kategori;
          _sedangMemuat = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _sedangMemuat = false);
    }
  }

  void _bukaLaporan(BuildContext context) {
    Navigator.pushNamed(context, RuteAplikasi.laporan);
  }

  void _bukaPengaturan(BuildContext context) {
    Navigator.pushNamed(context, RuteAplikasi.pengaturan);
  }

  void _bukaRiwayat(BuildContext context) {
    Navigator.pushNamed(context, RuteAplikasi.riwayatTransaksi).then((_) => _muatData());
  }

  void _tambahTransaksi(BuildContext context) {
    Navigator.pushNamed(context, RuteAplikasi.tambahTransaksi).then((_) => _muatData());
  }

  String _namaKategori(int idKategori) {
    final k = _kategori.where((k) => k.id == idKategori);
    return k.isNotEmpty ? k.first.nama : 'Lain-lain';
  }

  Kategori? _cariKategori(int idKategori) {
    final k = _kategori.where((k) => k.id == idKategori);
    return k.isNotEmpty ? k.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    final totalPemasukan = _transaksi
        .where((t) => t.jenisTransaksi == JenisTransaksi.pemasukan)
        .fold(0, (sum, t) => sum + t.jumlah);
    final totalPengeluaran = _transaksi
        .where((t) => t.jenisTransaksi == JenisTransaksi.pengeluaran)
        .fold(0, (sum, t) => sum + t.jumlah);
    final sisaSaldo = totalPemasukan - totalPengeluaran;

    final sekarang = DateTime.now();
    final akhirBulan = DateTime(sekarang.year, sekarang.month + 1, 0);
    final sisaHari = akhirBulan.difference(sekarang).inDays;

    // Ambil 5 transaksi terbaru
    final terbaru = _transaksi.take(5).toList();

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
      body: _sedangMemuat
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _muatData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  KartuSaldo(
                    sisaSaldo: sisaSaldo,
                    totalPemasukan: totalPemasukan,
                    totalPengeluaran: totalPengeluaran,
                    sisaHari: sisaHari,
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
                      if (_transaksi.isNotEmpty)
                        TextButton(
                          onPressed: () => _bukaRiwayat(context),
                          child: const Text('Lihat Semua'),
                        ),
                    ],
                  ),
                  if (terbaru.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: StateKosong(
                          ikon: Icons.receipt_long,
                          judul: 'Belum Ada Transaksi',
                          pesan: 'Tekan tombol + untuk menambah transaksi pertamamu.',
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Column(
                        children: terbaru.map((t) {
                          final kat = _cariKategori(t.idKategori);
                          final adalahPemasukan =
                              t.jenisTransaksi == JenisTransaksi.pemasukan;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: kat != null
                                  ? Color(kat.nilaiWarna).withOpacity(0.15)
                                  : Colors.grey.withOpacity(0.15),
                              child: Icon(
                                kat != null
                                    ? PemetaIkon.dariNama(kat.namaIkon)
                                    : Icons.category,
                                color: kat != null
                                    ? Color(kat.nilaiWarna)
                                    : Colors.grey,
                              ),
                            ),
                            title: Text(_namaKategori(t.idKategori)),
                            subtitle: Text(
                              t.catatan.isNotEmpty
                                  ? '${PemformatTanggal.formatPendek(t.tanggalTransaksi)} - ${t.catatan}'
                                  : PemformatTanggal.formatPendek(t.tanggalTransaksi),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              '${adalahPemasukan ? '+' : '-'} ${PemformatMataUang.format(t.jumlah)}',
                              style: tema.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: adalahPemasukan ? Colors.green : Colors.red,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
        onPressed: () => _tambahTransaksi(context),
      ),
    );
  }
}
