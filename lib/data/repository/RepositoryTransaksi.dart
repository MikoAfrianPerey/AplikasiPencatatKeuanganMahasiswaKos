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

  Future<void> perbarui(int id, {
    int? idKategori,
    int? jumlah,
    JenisTransaksi? jenis,
    DateTime? tanggal,
    String? catatan,
  });
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

  @override
  Future<void> perbarui(int id, {
    int? idKategori,
    int? jumlah,
    JenisTransaksi? jenis,
    DateTime? tanggal,
    String? catatan,
  }) async {
    await Future.delayed(jeda);
    final index = _transaksi.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final lama = _transaksi[index];
    _transaksi[index] = Transaksi(
      id: lama.id,
      idPeriodeBudget: lama.idPeriodeBudget,
      idKategori: idKategori ?? lama.idKategori,
      jenisTransaksi: jenis ?? lama.jenisTransaksi,
      jumlah: jumlah ?? lama.jumlah,
      catatan: catatan ?? lama.catatan,
      tanggalTransaksi: tanggal ?? lama.tanggalTransaksi,
      dibuatPada: lama.dibuatPada,
    );
  }
}
