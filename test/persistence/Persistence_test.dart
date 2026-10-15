import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dompet_kos/data/database/BantuanDatabase.dart';
import 'package:dompet_kos/data/model/Transaksi.dart';
import 'package:dompet_kos/data/repository/RepositoryKategoriSqlite.dart';
import 'package:dompet_kos/data/repository/RepositoryPeriodeBudgetSqlite.dart';
import 'package:dompet_kos/data/repository/RepositoryTransaksiSqlite.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Setup sqflite FFI untuk unit test di lingkungan desktop/Dart VM
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late BantuanDatabase dbHelper;
  late RepositoryKategoriSqlite repoKategori;
  late RepositoryPeriodeBudgetSqlite repoPeriode;
  late RepositoryTransaksiSqlite repoTransaksi;

  setUp(() async {
    dbHelper = BantuanDatabase.instance;
    dbHelper.aturJalurKustom('in_memory_db_test.db');
    await dbHelper.hapusDatabase(); // Bersihkan database sebelum pengujian
    repoKategori = RepositoryKategoriSqlite(dbHelper);
    repoPeriode = RepositoryPeriodeBudgetSqlite(dbHelper);
    repoTransaksi = RepositoryTransaksiSqlite(dbHelper);
  });

  tearDown(() async {
    await dbHelper.hapusDatabase();
  });

  group('Local Data & Persistence (SQLite CRUD & Persistence Test)', () {
    test('1. [CREATE & READ Kategori] Inisialisasi Kategori Default', () async {
      var kategoriList = await repoKategori.ambilSemua();
      expect(kategoriList, isEmpty);

      // Create default
      await repoKategori.buatDefault();

      // Read
      kategoriList = await repoKategori.ambilSemua();
      expect(kategoriList.length, equals(4));
      expect(kategoriList.map((k) => k.nama), containsAll(['Makan', 'Kos', 'Transport', 'Lain-lain']));
    });

    test('2. [CREATE & READ Transaksi] Simpan Transaksi Pemasukan dan Pengeluaran', () async {
      await repoKategori.buatDefault();
      final kategoriList = await repoKategori.ambilSemua();
      final idMakan = kategoriList.firstWhere((k) => k.nama == 'Makan').id;

      // Create Periode
      await repoPeriode.buatPeriode(
        totalPemasukan: 2000000,
        batasKategori: {idMakan: 600000},
      );

      // CREATE Transaksi Pengeluaran
      final t1 = await repoTransaksi.buat(
        idKategori: idMakan,
        jumlah: 25000,
        jenis: JenisTransaksi.pengeluaran,
        tanggal: DateTime.now(),
        catatan: 'Nasi padang siang',
      );
      expect(t1.id, isNotNull);
      expect(t1.jumlah, equals(25000));

      // READ Transaksi
      final listTransaksi = await repoTransaksi.ambilSemua();
      expect(listTransaksi.length, equals(1));
      expect(listTransaksi.first.catatan, equals('Nasi padang siang'));
      expect(listTransaksi.first.jumlah, equals(25000));
    });

    test('3. [UPDATE Transaksi] Memperbarui Nominal & Catatan Transaksi', () async {
      await repoKategori.buatDefault();
      final kategoriList = await repoKategori.ambilSemua();
      final idMakan = kategoriList.firstWhere((k) => k.nama == 'Makan').id;

      final t1 = await repoTransaksi.buat(
        idKategori: idMakan,
        jumlah: 25000,
        jenis: JenisTransaksi.pengeluaran,
        tanggal: DateTime.now(),
        catatan: 'Nasi padang siang',
      );

      // UPDATE Transaksi
      await repoTransaksi.perbarui(
        t1.id,
        jumlah: 30000,
        catatan: 'Nasi padang + es teh',
      );

      // READ dan Verifikasi perubahan
      final listTransaksi = await repoTransaksi.ambilSemua();
      expect(listTransaksi.length, equals(1));
      expect(listTransaksi.first.id, equals(t1.id));
      expect(listTransaksi.first.jumlah, equals(30000));
      expect(listTransaksi.first.catatan, equals('Nasi padang + es teh'));
    });

    test('4. [DELETE Transaksi] Menghapus Transaksi dari SQLite', () async {
      await repoKategori.buatDefault();
      final kategoriList = await repoKategori.ambilSemua();
      final idMakan = kategoriList.firstWhere((k) => k.nama == 'Makan').id;

      final t1 = await repoTransaksi.buat(
        idKategori: idMakan,
        jumlah: 15000,
        jenis: JenisTransaksi.pengeluaran,
        tanggal: DateTime.now(),
        catatan: 'Kopi',
      );

      var listTransaksi = await repoTransaksi.ambilSemua();
      expect(listTransaksi.length, equals(1));

      // DELETE
      await repoTransaksi.hapus(t1.id);

      // Verifikasi sudah terhapus
      listTransaksi = await repoTransaksi.ambilSemua();
      expect(listTransaksi, isEmpty);
    });

    test('5. [PERSISTENCE TEST] Data tetap ada setelah aplikasi/koneksi ditutup dan dibuka kembali', () async {
      // Step A: Buka db dan tulis data
      await repoKategori.buatDefault();
      final kategoriList = await repoKategori.ambilSemua();
      final idTransport = kategoriList.firstWhere((k) => k.nama == 'Transport').id;

      await repoTransaksi.buat(
        idKategori: idTransport,
        jumlah: 15000,
        jenis: JenisTransaksi.pengeluaran,
        tanggal: DateTime.now(),
        catatan: 'Bensin motor',
      );

      // Step B: Simulasikan aplikasi ditutup (Close db connection)
      await dbHelper.tutup();

      // Step C: Simulasikan aplikasi dibuka kembali (Instansiasi ulang helper & repository baru)
      final repoTransaksiBaru = RepositoryTransaksiSqlite(dbHelper);
      final repoKategoriBaru = RepositoryKategoriSqlite(dbHelper);

      // Step D: Verifikasi data PERSISTEN (tetap tersimpan utuh di storage lokal)
      final kategoriSetelahBukaLagi = await repoKategoriBaru.ambilSemua();
      expect(kategoriSetelahBukaLagi.length, equals(4));

      final transaksiSetelahBukaLagi = await repoTransaksiBaru.ambilSemua();
      expect(transaksiSetelahBukaLagi.length, equals(1));
      expect(transaksiSetelahBukaLagi.first.catatan, equals('Bensin motor'));
      expect(transaksiSetelahBukaLagi.first.jumlah, equals(15000));
    });
  });
}

