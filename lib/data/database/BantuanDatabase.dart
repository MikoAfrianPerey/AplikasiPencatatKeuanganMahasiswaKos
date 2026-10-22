import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BantuanDatabase {
  static final BantuanDatabase instance = BantuanDatabase._internal();

  static Database? _database;

  String? _customPath;

  BantuanDatabase._internal();

  factory BantuanDatabase({String? customPath}) {
    if (customPath != null) {
      instance._customPath = customPath;
    }
    return instance;
  }

  void aturJalurKustom(String? jalur) {
    _customPath = jalur;
  }

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _inisialisasiDatabase();
    return _database!;
  }

  Future<void> tutup() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }

    _database = null;
  }

  Future<String> get _jalurDatabase async {
    if (_customPath != null) {
      return _customPath!;
    }

    final direktori = await getApplicationDocumentsDirectory();
    return join(direktori.path, 'dompet_kos.db');
  }

  Future<Database> _inisialisasiDatabase() async {
    final jalur = await _jalurDatabase;

    return openDatabase(
      jalur,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _buatTabel,
    );
  }

  Future<void> _buatTabel(Database db, int version) async {
    await db.execute('''
      CREATE TABLE kategori (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        nama_ikon TEXT NOT NULL,
        warna INTEGER NOT NULL,
        adalah_default INTEGER DEFAULT 0,
        dibuat_pada TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE periode_budget (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bulan_periode INTEGER NOT NULL,
        tahun_periode INTEGER NOT NULL,
        total_pemasukan INTEGER NOT NULL,
        tanggal_mulai TEXT NOT NULL,
        tanggal_akhir TEXT NOT NULL,
        aktif_sekarang INTEGER DEFAULT 1,
        dibuat_pada TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budget_kategori (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_periode_budget INTEGER NOT NULL,
        id_kategori INTEGER NOT NULL,
        jumlah_batas INTEGER NOT NULL,
        persen_batas_peringatan REAL DEFAULT 80,
        peringatan_sudah_dikirim INTEGER DEFAULT 0,
        dibuat_pada TEXT NOT NULL,
        FOREIGN KEY (id_periode_budget) REFERENCES periode_budget(id),
        FOREIGN KEY (id_kategori) REFERENCES kategori(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transaksi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_periode_budget INTEGER NOT NULL,
        id_kategori INTEGER NOT NULL,
        jenis_transaksi TEXT NOT NULL,
        jumlah INTEGER NOT NULL,
        catatan TEXT DEFAULT '',
        tanggal_transaksi TEXT NOT NULL,
        dibuat_pada TEXT NOT NULL,
        FOREIGN KEY (id_periode_budget) REFERENCES periode_budget(id),
        FOREIGN KEY (id_kategori) REFERENCES kategori(id)
      )
    ''');
  }

  Future<int> sisipkan(String tabel, Map<String, dynamic> data) async {
    final db = await database;
    final map = Map<String, dynamic>.from(data);

    if (map.containsKey('id') && map['id'] == null) {
      map.remove('id');
    }

    return db.insert(tabel, map);
  }

  Future<List<Map<String, dynamic>>> kueri(
    String tabel, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;

    return db.query(
      tabel,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> perbarui(
    String tabel,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;

    return db.update(
      tabel,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> hapus(
    String tabel, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;

    return db.delete(
      tabel,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> hapusDatabase() async {
    await tutup();
    final jalur = await _jalurDatabase;
    await deleteDatabase(jalur);
  }
}
