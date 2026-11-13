import '../../data/model/Kategori.dart';
import '../../data/model/Transaksi.dart';
import '../../data/repository/RepositoryKategori.dart';
import '../../data/repository/RepositoryTransaksi.dart';

class DataBeranda {
  final List<Transaksi> transaksi;
  final List<Kategori> kategori;

  const DataBeranda({required this.transaksi, required this.kategori});

  static Future<DataBeranda> muat({
    required RepositoryTransaksi transaksi,
    required RepositoryKategori kategori,
  }) async {
    final daftarTransaksi = await transaksi.ambilSemua();
    final daftarKategori = await kategori.ambilSemua();
    return DataBeranda(transaksi: daftarTransaksi, kategori: daftarKategori);
  }

  Kategori? cariKategori(int idKategori) {
    for (final item in kategori) {
      if (item.id == idKategori) return item;
    }
    return null;
  }

  String namaKategori(int idKategori) =>
      cariKategori(idKategori)?.nama ?? 'Lain-lain';

  int totalPemasukan() => _total(JenisTransaksi.pemasukan);

  int totalPengeluaran() => _total(JenisTransaksi.pengeluaran);

  int _total(JenisTransaksi jenis) => transaksi
      .where((t) => t.jenisTransaksi == jenis)
      .fold(0, (total, t) => total + t.jumlah);

  List<Transaksi> terbaru(int jumlah) => transaksi.take(jumlah).toList();
}
