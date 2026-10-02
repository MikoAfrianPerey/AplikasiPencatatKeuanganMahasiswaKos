import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/data/repository/RepositoryKategori.dart';
import '../../lib/data/repository/RepositoryPeriodeBudget.dart';
import '../../lib/presentasi/widget/TombolUtama.dart';
import '../pembantu/AplikasiTest.dart';

void main() {
  const jeda = Duration(milliseconds: 300);
  const durasiMuat = Duration(milliseconds: 800);

  RepositoryKategoriMock repoKategori() => RepositoryKategoriMock(jeda: jeda);
  RepositoryPeriodeBudgetMock repoPeriode() =>
      RepositoryPeriodeBudgetMock(jeda: jeda);

  Future<void> bukaOnboarding(
    WidgetTester tester,
    RepositoryKategoriMock kategori,
  ) async {
    aturUkuranPonsel(tester);
    await tester.pumpWidget(aplikasiOnboardingTest(
      repositoryKategori: kategori,
      repositoryPeriodeBudget: repoPeriode(),
    ));
    await tester.pump(durasiMuat);
  }

  testWidgets(
    '1. initial loading: menampilkan indikator loading saat memuat kategori',
    (tester) async {
      aturUkuranPonsel(tester);
      await tester.pumpWidget(aplikasiOnboardingTest(
        repositoryKategori: repoKategori(),
        repositoryPeriodeBudget: repoPeriode(),
      ));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Memuat kategori...'), findsOneWidget);
      await tester.pump(durasiMuat);
    },
  );

  testWidgets(
    '2. empty state: menampilkan pesan kosong saat belum ada kategori',
    (tester) async {
      await bukaOnboarding(tester, repoKategori());
      expect(find.text('Belum Ada Kategori'), findsOneWidget);
      expect(find.text('Tambah Kategori Default'), findsOneWidget);
    },
  );

  testWidgets(
    '3. data berhasil dimuat: menampilkan form setelah kategori dimuat',
    (tester) async {
      final kategori = repoKategori();
      kategori.isiKategoriDefault();
      await bukaOnboarding(tester, kategori);
      expect(find.text('Total Pemasukan Bulanan'), findsOneWidget);
      expect(find.text('Batas Makan'), findsOneWidget);
      expect(find.text('Batas Kos'), findsOneWidget);
      expect(find.text('Batas Transport'), findsOneWidget);
      expect(find.text('Batas Lain-lain'), findsOneWidget);
      expect(find.text('Mulai Kelola Uang'), findsOneWidget);
    },
  );

  testWidgets(
    '4. error state: menampilkan pesan error dan tombol retry',
    (tester) async {
      final kategori = repoKategori();
      kategori.aktifkanModeError();
      await bukaOnboarding(tester, kategori);
      expect(find.text('Gagal Memuat Kategori'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    },
  );

  testWidgets(
    '5. error state: tombol retry memuat ulang data setelah error teratasi',
    (tester) async {
      final kategori = repoKategori();
      kategori.aktifkanModeError();
      await bukaOnboarding(tester, kategori);
      expect(find.text('Gagal Memuat Kategori'), findsOneWidget);

      kategori.nonaktifkanModeError();
      kategori.isiKategoriDefault();
      await tester.tap(find.text('Coba Lagi'));
      await tester.pump(durasiMuat);
      expect(find.text('Total Pemasukan Bulanan'), findsOneWidget);
    },
  );

  testWidgets(
    '6. validasi input: pesan error saat total pemasukan kosong',
    (tester) async {
      final kategori = repoKategori();
      kategori.isiKategoriDefault();
      await bukaOnboarding(tester, kategori);
      await tester.tap(find.text('Mulai Kelola Uang'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Total pemasukan tidak boleh kosong'), findsOneWidget);
    },
  );

  testWidgets(
    '7. validasi input: pesan error saat total pemasukan bukan angka valid',
    (tester) async {
      final kategori = repoKategori();
      kategori.isiKategoriDefault();
      await bukaOnboarding(tester, kategori);
      await tester.enterText(find.byType(TextFormField).first, '0');
      await tester.tap(find.text('Mulai Kelola Uang'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Masukkan angka lebih dari 0'), findsOneWidget);
    },
  );

  testWidgets(
    '8. validasi input: error saat total batas melebihi total pemasukan',
    (tester) async {
      final kategori = repoKategori();
      kategori.isiKategoriDefault();
      await bukaOnboarding(tester, kategori);
      await tester.enterText(find.byType(TextFormField).first, '100000');
      await tester.enterText(find.byType(TextFormField).at(1), '200000');
      await tester.tap(find.text('Mulai Kelola Uang'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('melebihi total pemasukan'), findsOneWidget);
    },
  );

  testWidgets(
    '9. loading saat submit: tombol nonaktif dan menampilkan spinner',
    (tester) async {
      final kategori = repoKategori();
      kategori.isiKategoriDefault();
      await bukaOnboarding(tester, kategori);
      await tester.enterText(find.byType(TextFormField).first, '1000000');
      await tester.tap(find.text('Mulai Kelola Uang'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final tombol = tester.widget<TombolUtama>(find.byType(TombolUtama));
      expect(tombol.sedangMemuat, isTrue);
      expect(tombol.saatDitekan, isNull);
      await tester.pump(durasiMuat);
    },
  );

  testWidgets(
    '10. submit berhasil: pindah ke dashboard setelah periode disimpan',
    (tester) async {
      final kategori = repoKategori();
      kategori.isiKategoriDefault();
      await bukaOnboarding(tester, kategori);
      await tester.enterText(find.byType(TextFormField).first, '1000000');
      await tester.tap(find.text('Mulai Kelola Uang'));
      await tester.pump(durasiMuat);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(labelDashboard), findsOneWidget);
    },
  );
}
