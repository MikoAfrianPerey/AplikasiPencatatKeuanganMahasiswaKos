import '../database/BantuanDatabase.dart';
import '../model/Transaksi.dart';
import 'RepositoryTransaksi.dart';

class RepositoryTransaksiSqlite implements RepositoryTransaksi {
  final BantuanDatabase _db;

  RepositoryTransaksiSqlite([BantuanDatabase? db])
      : _db = db ?? BantuanDatabase.instance;

  @override
  Future<List<Transaksi>> ambilSemua() async {
    final hasil = await _db.kueri(
      'transaksi',
      orderBy: 'tanggal_transaksi DESC, dibuat_pada DESC',
    );
    return hasil.map((m) => Transaksi.dariMap(m)).toList();
  }

  @override
  Future<Transaksi> buat({
    required int idKategori,
    required int jumlah,
    required JenisTransaksi jenis,
    required DateTime tanggal,
    String catatan = '',
  }) async {
    final periodeAktif = await _db.kueri(
      'periode_budget',
      where: 'aktif_sekarang = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );

    int idPeriodeBudget;
    if (periodeAktif.isNotEmpty) {
      idPeriodeBudget = periodeAktif.first['id'] as int;
    } else {
      final sekarang = DateTime.now();
      idPeriodeBudget = await _db.sisipkan('periode_budget', {
        'bulan_periode': sekarang.month,
        'tahun_periode': sekarang.year,
        'total_pemasukan': 0,
        'tanggal_mulai': DateTime(sekarang.year, sekarang.month, 1).toIso8601String(),
        'tanggal_akhir': DateTime(sekarang.year, sekarang.month + 1, 0).toIso8601String(),
        'aktif_sekarang': 1,
        'dibuat_pada': sekarang.toIso8601String(),
      });
    }

    final sekarang = DateTime.now();
    final id = await _db.sisipkan('transaksi', {
      'id_periode_budget': idPeriodeBudget,
      'id_kategori': idKategori,
      'jenis_transaksi':
          jenis == JenisTransaksi.pemasukan ? 'PEMASUKAN' : 'PENGELUARAN',
      'jumlah': jumlah,
      'catatan': catatan,
      'tanggal_transaksi': tanggal.toIso8601String(),
      'dibuat_pada': sekarang.toIso8601String(),
    });

    return Transaksi(
      id: id,
      idPeriodeBudget: idPeriodeBudget,
      idKategori: idKategori,
      jenisTransaksi: jenis,
      jumlah: jumlah,
      catatan: catatan,
      tanggalTransaksi: tanggal,
      dibuatPada: sekarang,
    );
  }

  @override
  Future<void> hapus(int id) async {
    await _db.hapus(
      'transaksi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> perbarui(
    int id, {
    int? idKategori,
    int? jumlah,
    JenisTransaksi? jenis,
    DateTime? tanggal,
    String? catatan,
  }) async {
    final Map<String, dynamic> data = {};
    if (idKategori != null) data['id_kategori'] = idKategori;
    if (jumlah != null) data['jumlah'] = jumlah;
    if (jenis != null) {
      data['jenis_transaksi'] =
          jenis == JenisTransaksi.pemasukan ? 'PEMASUKAN' : 'PENGELUARAN';
    }
    if (tanggal != null) {
      data['tanggal_transaksi'] = tanggal.toIso8601String();
    }
    if (catatan != null) data['catatan'] = catatan;

    if (data.isEmpty) return;

    await _db.perbarui(
      'transaksi',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
