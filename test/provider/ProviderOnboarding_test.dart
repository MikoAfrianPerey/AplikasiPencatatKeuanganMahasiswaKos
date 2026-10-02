import 'package:flutter_test/flutter_test.dart';


import '../../lib/data/repository/RepositoryKategori.dart';
import '../../lib/data/repository/RepositoryPeriodeBudget.dart';
import '../../lib/inti/state/StatusData.dart';
import '../../lib/provider/ProviderOnboarding.dart';

void main() {
  late RepositoryKategoriMock kategori;
  late RepositoryPeriodeBudgetMock periode;
  late ProviderOnboarding provider;

  setUp(() {
    kategori = RepositoryKategoriMock(jeda: Duration.zero);
    periode = RepositoryPeriodeBudgetMock(jeda: Duration.zero);
    provider = ProviderOnboarding(kategori, periode);
  });

  group('validasiPemasukan', () {
    test('mengembalikan pesan saat kosong', () {
      expect(
        provider.validasiPemasukan(''),
        'Total pemasukan tidak boleh kosong',
      );
      expect(provider.validasiPemasukan(null), isNotEmpty);
    });

    test('mengembalikan pesan saat bernilai nol', () {
      expect(provider.validasiPemasukan('0'), 'Masukkan angka lebih dari 0');
    });

    test('mengembalikan null saat angka valid', () {
      expect(provider.validasiPemasukan('1500000'), isNull);
    });
  });

  group('validasiBatas', () {
    test('mengembalikan pesan saat negatif', () {
      expect(provider.validasiBatas('-100'), 'Batas tidak boleh negatif');
    });

    test('mengembalikan null saat nol atau angka valid', () {
      expect(provider.validasiBatas('0'), isNull);
      expect(provider.validasiBatas('500000'), isNull);
    });
  });

  group('muatKategori', () {
    test('berstatus kosong saat repository belum memiliki kategori', () async {
      await provider.muatKategori();
      expect(provider.statusKategori.adalahKosong, isTrue);
      expect(provider.kategori, isNull);
    });

    test('berstatus sukses dan menyiapkan controller batas', () async {
      await kategori.buatDefault();
      await provider.muatKategori();
      expect(provider.statusKategori.adalahSukses, isTrue);
      expect(provider.kategori?.length, 4);
      expect(provider.controllerBatas.length, 4);
    });

    test('berstatus error saat repository gagal', () async {
      kategori.aktifkanModeError();
      await provider.muatKategori();
      expect(provider.statusKategori.adalahError, isTrue);
      expect(provider.statusKategori.pesan, isNotEmpty);
    });

    test('buatKategoriDefault memuat ulang hingga berstatus sukses', () async {
      await provider.muatKategori();
      expect(provider.statusKategori.adalahKosong, isTrue);
      await provider.buatKategoriDefault();
      expect(provider.statusKategori.adalahSukses, isTrue);
      expect(provider.kategori?.length, 4);
    });
  });

  group('simpanPeriode', () {
    test('gagal saat total batas melebihi pemasukan', () async {
      await kategori.buatDefault();
      await provider.muatKategori();
      provider.controllerPemasukan.text = '100000';
      provider.controllerBatas.values.first.text = '500000';
      await provider.simpanPeriode();
      expect(provider.errorTotalBatas, isNotNull);
      expect(provider.statusSimpan.status, Status.initial);
    });

    test('berhasil menyimpan saat data valid', () async {
      await kategori.buatDefault();
      await provider.muatKategori();
      provider.controllerPemasukan.text = '1500000';
      provider.controllerBatas.values.first.text = '600000';
      await provider.simpanPeriode();
      expect(provider.errorTotalBatas, isNull);
      expect(provider.statusSimpan.adalahSukses, isTrue);
      expect(provider.statusSimpan.data?.totalPemasukan, 1500000);
    });

    test('tidak menyimpan saat pemasukan kosong', () async {
      await kategori.buatDefault();
      await provider.muatKategori();
      await provider.simpanPeriode();
      expect(provider.statusSimpan.status, Status.initial);
    });
  });
}
