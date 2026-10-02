import '../model/BudgetKategori.dart';
import '../model/PeriodeBudget.dart';

abstract class RepositoryPeriodeBudget {
  Future<PeriodeBudget> buatPeriode({
    required int totalPemasukan,
    required Map<int, int> batasKategori,
  });

  Future<PeriodeBudget?> ambilPeriodeAktif();

  Future<List<BudgetKategori>> ambilBatasPeriode(int idPeriode);
}

class RepositoryPeriodeBudgetMock implements RepositoryPeriodeBudget {
  final List<BudgetKategori> _batas = [];
  final Duration jeda;
  PeriodeBudget? _periodeAktif;
  int _idBerikutnya = 1;

  RepositoryPeriodeBudgetMock({this.jeda = const Duration(milliseconds: 900)});

  @override
  Future<PeriodeBudget> buatPeriode({
    required int totalPemasukan,
    required Map<int, int> batasKategori,
  }) async {
    await Future.delayed(jeda);
    final sekarang = DateTime.now();
    final mulai = DateTime(sekarang.year, sekarang.month, 1);
    final akhir = DateTime(sekarang.year, sekarang.month + 1, 0);

    _periodeAktif = PeriodeBudget(
      id: _idBerikutnya,
      bulanPeriode: sekarang.month,
      tahunPeriode: sekarang.year,
      totalPemasukan: totalPemasukan,
      tanggalMulai: mulai,
      tanggalAkhir: akhir,
      aktifSekarang: true,
      dibuatPada: sekarang,
    );

    _batas.clear();
    for (final item in batasKategori.entries) {
      _batas.add(
        BudgetKategori(
          id: item.key,
          idPeriodeBudget: _idBerikutnya,
          idKategori: item.key,
          jumlahBatas: item.value,
          dibuatPada: sekarang,
        ),
      );
    }
    _idBerikutnya++;

    return _periodeAktif!;
  }

  @override
  Future<PeriodeBudget?> ambilPeriodeAktif() async {
    await Future.delayed(jeda);
    return _periodeAktif;
  }

  @override
  Future<List<BudgetKategori>> ambilBatasPeriode(int idPeriode) async {
    await Future.delayed(jeda);
    return _batas.where((batas) => batas.idPeriodeBudget == idPeriode).toList();
  }
}
