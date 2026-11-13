import 'package:dompet_kos/data/model/BudgetKategori.dart';
import 'package:dompet_kos/data/model/Kategori.dart';
import 'package:dompet_kos/data/model/PeriodeBudget.dart';
import 'package:dompet_kos/data/repository/RepositoryKategori.dart';
import 'package:dompet_kos/data/repository/RepositoryPeriodeBudget.dart';
import 'package:dompet_kos/provider/ProviderOnboarding.dart';
import 'package:flutter_test/flutter_test.dart';

class _KategoriUji implements RepositoryKategori {
  @override
  bool get modeErrorAktif => false;

  @override
  Future<List<Kategori>> ambilSemua() async => [
        Kategori(
          id: 1,
          nama: 'Makan',
          namaIkon: 'restaurant',
          nilaiWarna: 0xFFFF9800,
          dibuatPada: DateTime(2026, 10, 1),
        ),
      ];

  @override
  Future<void> buatDefault() async {}

  @override
  Future<void> reset() async {}

  @override
  void aktifkanModeError() {}

  @override
  void nonaktifkanModeError() {}
}

class _PeriodeUji implements RepositoryPeriodeBudget {
  @override
  Future<PeriodeBudget> buatPeriode({
    required int totalPemasukan,
    required Map<int, int> batasKategori,
  }) async =>
      throw UnimplementedError();

  @override
  Future<PeriodeBudget?> ambilPeriodeAktif() async => null;

  @override
  Future<List<BudgetKategori>> ambilBatasPeriode(int idPeriode) async => [];
}

void main() {
  test('ringkasan batas ikut berubah saat field diisi', () async {
    final provider = ProviderOnboarding(_KategoriUji(), _PeriodeUji());
    await provider.muatKategori();
    expect(provider.ringkasanBatas, contains('Rp 0'));

    provider.controllerPemasukan.text = '3000000';
    provider.controllerBatas[1]!.text = '800000';

    expect(provider.ringkasanBatas, contains('Rp 800.000'));
    expect(provider.ringkasanBatas, contains('Rp 3.000.000'));
  });
}
