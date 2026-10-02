import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../lib/data/repository/RepositoryKategori.dart';
import '../../lib/data/repository/RepositoryTransaksi.dart';
import '../../lib/presentasi/widget/TombolUtama.dart';
import '../pembantu/AplikasiTest.dart';

void main() {
  const jeda = Duration(milliseconds: 300);
  const durasiMuat = Duration(milliseconds: 800);

  setUp(() async {
    await initializeDateFormatting('id_ID', null);
  });

  RepositoryKategoriMock repoKategori() => RepositoryKategoriMock(jeda: jeda);
  RepositoryTransaksiMock repoTransaksi() =>
      RepositoryTransaksiMock(jeda: jeda);

  Future<void> bukaLayar(
    WidgetTester tester,
    RepositoryKategoriMock kategori, {
    bool navigasi = false,
  }) async {
    aturUkuranPonsel(tester);
    await tester.pumpWidget(aplikasiTambahTransaksiTest(
      repositoryKategori: kategori,
      repositoryTransaksi: repoTransaksi(),
      navigasi: navigasi,
    ));
    if (navigasi) {
      await tester.tap(find.text(labelBeranda));
      await tester.pumpAndSettle();
    } else {
      await tester.pump(durasiMuat);
    }
  }

  testWidgets(
    '1. initial loading: menampilkan indikator loading saat memuat kategori',
    (tester) async {
      aturUkuranPonsel(tester);
      await tester.pumpWidget(aplikasiTambahTransaksiTest(
        repositoryKategori:
            RepositoryKategoriMock(jeda: const Duration(seconds: 2)),
        repositoryTransaksi:
            RepositoryTransaksiMock(jeda: const Duration(seconds: 2)),
      ));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Memuat kategori...'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    },
  );

  testWidgets(
    '2. data berhasil dimuat: menampilkan keypad dan chip kategori',
    (tester) async {
      final kategori = repoKategori();
      kategori.isiKategoriDefault();
      await bukaLayar(tester, kategori);
      expect(find.text('Makan'), findsOneWidget);
      expect(find.text('Kos'), findsOneWidget);
      expect(find.text('Simpan Transaksi'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    },
  );

  testWidgets(
    '3. empty state: menampilkan pesan kosong saat tidak ada kategori',
    (tester) async {
      await bukaLayar(tester, repoKategori());
      expect(find.text('Belum Ada Kategori'), findsOneWidget);
    },
  );

  testWidgets(
    '4. error state: menampilkan pesan error dan tombol retry',
    (tester) async {
      final kategori = repoKategori();
      kategori.aktifkanModeError();
      await bukaLayar(tester, kategori);
      expect(find.text('Gagal Memuat Kategori'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    },
  );

  testWidgets(
    '5. error state: tombol retry memuat ulang data',
    (tester) async {
      final kategori = repoKategori();
      kategori.aktifkanModeError();
      await bukaLayar(tester, kategori);
      expect(find.text('Gagal Memuat Kategori'), findsOneWidget);
      kategori.nonaktifkanModeError();
      kategori.isiKategoriDefault();
      await tester.tap(find.text('Coba Lagi'));
      await tester.pump(durasiMuat);
      expect(find.text('Simpan Transaksi'), findsOneWidget);
    },
  );

  testWidgets(
    '6. validasi input: pesan error saat jumlah masih nol',
    (tester) async {
      final kategori = repoKategori();
      kategori.isiKategoriDefault();
      await bukaLayar(tester, kategori);
      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Jumlah transaksi harus lebih dari 0'), findsOneWidget);
    },
  );

  testWidgets(
    '7. loading saat submit: tombol nonaktif, spinner, lalu kembali',
    (tester) async {
      final kategori = repoKategori();
      kategori.isiKategoriDefault();
      await bukaLayar(tester, kategori, navigasi: true);
      for (final angka in ['1', '0', '0', '0', '0', '0']) {
        await tester.tap(find.text(angka).first);
      }
      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final tombol = tester.widget<TombolUtama>(find.byType(TombolUtama));
      expect(tombol.sedangMemuat, isTrue);
      expect(tombol.saatDitekan, isNull);
      await tester.pumpAndSettle();
      expect(find.text(labelBeranda), findsOneWidget);
    },
  );
}
