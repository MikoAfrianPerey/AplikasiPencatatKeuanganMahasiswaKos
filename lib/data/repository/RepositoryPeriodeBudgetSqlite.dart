import '../database/BantuanDatabase.dart';
import '../model/BudgetKategori.dart';
import '../model/PeriodeBudget.dart';
import 'RepositoryPeriodeBudget.dart';

class RepositoryPeriodeBudgetSqlite implements RepositoryPeriodeBudget {
  final BantuanDatabase _db;

  RepositoryPeriodeBudgetSqlite([BantuanDatabase? db])
      : _db = db ?? BantuanDatabase.instance;

  @override
  Future<PeriodeBudget> buatPeriode({
    required int totalPemasukan,
    required Map<int, int> batasKategori,
  }) async {
    // Nonaktifkan periode aktif sebelumnya jika ada
    await _db.perbarui(
      'periode_budget',
      {'aktif_sekarang': 0},
      where: 'aktif_sekarang = ?',
      whereArgs: [1],
    );

    final sekarang = DateTime.now();
    final mulai = DateTime(sekarang.year, sekarang.month, 1);
    final akhir = DateTime(sekarang.year, sekarang.month + 1, 0);

    final idPeriode = await _db.sisipkan('periode_budget', {
      'bulan_periode': sekarang.month,
      'tahun_periode': sekarang.year,
      'total_pemasukan': totalPemasukan,
      'tanggal_mulai': mulai.toIso8601String(),
      'tanggal_akhir': akhir.toIso8601String(),
      'aktif_sekarang': 1,
      'dibuat_pada': sekarang.toIso8601String(),
    });

    for (final item in batasKategori.entries) {
      await _db.sisipkan('budget_kategori', {
        'id_periode_budget': idPeriode,
        'id_kategori': item.key,
        'jumlah_batas': item.value,
        'persen_batas_peringatan': 80.0,
        'peringatan_sudah_dikirim': 0,
        'dibuat_pada': sekarang.toIso8601String(),
      });
    }

    return PeriodeBudget(
      id: idPeriode,
      bulanPeriode: sekarang.month,
      tahunPeriode: sekarang.year,
      totalPemasukan: totalPemasukan,
      tanggalMulai: mulai,
      tanggalAkhir: akhir,
      aktifSekarang: true,
      dibuatPada: sekarang,
    );
  }

  @override
  Future<PeriodeBudget?> ambilPeriodeAktif() async {
    final hasil = await _db.kueri(
      'periode_budget',
      where: 'aktif_sekarang = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );
    if (hasil.isEmpty) return null;
    return PeriodeBudget.dariMap(hasil.first);
  }

  @override
  Future<List<BudgetKategori>> ambilBatasPeriode(int idPeriode) async {
    final hasil = await _db.kueri(
      'budget_kategori',
      where: 'id_periode_budget = ?',
      whereArgs: [idPeriode],
      orderBy: 'id ASC',
    );
    return hasil.map((m) => BudgetKategori.dariMap(m)).toList();
  }
}
