import '../model/Transaksi.dart';

abstract class RepositoryTransaksi {
  Future<List<Transaksi>> ambilSemua();

  Future<Transaksi> buat({
    required int idKategori,
    required int jumlah,
    required JenisTransaksi jenis,
    required DateTime tanggal,
    String catatan,
  });

  Future<void> hapus(int id);
}

class RepositoryTransaksiMock implements RepositoryTransaksi {
  final List<Transaksi> _transaksi = [];
  final Duration jeda;
  int _idBerikutnya = 1;

  RepositoryTransaksiMock({this.jeda = const Duration(milliseconds: 700)});

  @override
  Future<List<Transaksi>> ambilSemua() async {
    await Future.delayed(jeda);
    return List.unmodifiable(_transaksi);
  }

  @override
  Future<Transaksi> buat({
    required int idKategori,
    required int jumlah,
    required JenisTransaksi jenis,
    required DateTime tanggal,
    String catatan = '',
  }) async {
    await Future.delayed(jeda);
    final sekarang = DateTime.now();
    final transaksi = Transaksi(
      id: _idBerikutnya,
      idPeriodeBudget: 1,
      idKategori: idKategori,
      jenisTransaksi: jenis,
      jumlah: jumlah,
      catatan: catatan,
      tanggalTransaksi: tanggal,
      dibuatPada: sekarang,
    );
    _transaksi.insert(0, transaksi);
    _idBerikutnya++;
    return transaksi;
  }

  @override
  Future<void> hapus(int id) async {
    await Future.delayed(jeda);
    _transaksi.removeWhere((item) => item.id == id);
  }
}
