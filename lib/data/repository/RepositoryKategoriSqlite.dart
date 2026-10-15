import '../database/BantuanDatabase.dart';
import '../model/Kategori.dart';
import 'RepositoryKategori.dart';

class RepositoryKategoriSqlite implements RepositoryKategori {
  final BantuanDatabase _db;
  bool _modeError = false;

  RepositoryKategoriSqlite([BantuanDatabase? db])
      : _db = db ?? BantuanDatabase.instance;

  @override
  Future<List<Kategori>> ambilSemua() async {
    if (_modeError) {
      throw Exception('Gagal memuat kategori. Periksa penyimpanan dan coba lagi.');
    }
    final hasil = await _db.kueri('kategori', orderBy: 'id ASC');
    return hasil.map((m) => Kategori.dariMap(m)).toList();
  }

  @override
  Future<void> buatDefault() async {
    final ada = await _db.kueri('kategori');
    if (ada.isNotEmpty) return;

    final sekarang = DateTime.now();
    final defaultKategori = [
      Kategori(
        id: 1,
        nama: 'Makan',
        namaIkon: 'restaurant',
        nilaiWarna: 0xFFFF9800,
        adalahDefault: true,
        dibuatPada: sekarang,
      ),
      Kategori(
        id: 2,
        nama: 'Kos',
        namaIkon: 'home',
        nilaiWarna: 0xFF4CAF50,
        adalahDefault: true,
        dibuatPada: sekarang,
      ),
      Kategori(
        id: 3,
        nama: 'Transport',
        namaIkon: 'directions_bus',
        nilaiWarna: 0xFF2196F3,
        adalahDefault: true,
        dibuatPada: sekarang,
      ),
      Kategori(
        id: 4,
        nama: 'Lain-lain',
        namaIkon: 'category',
        nilaiWarna: 0xFF9C27B0,
        adalahDefault: true,
        dibuatPada: sekarang,
      ),
    ];

    for (final item in defaultKategori) {
      await _db.sisipkan('kategori', item.keMap());
    }
  }

  @override
  void aktifkanModeError() => _modeError = true;

  @override
  void nonaktifkanModeError() => _modeError = false;

  @override
  bool get modeErrorAktif => _modeError;

  @override
  Future<void> reset() async {
    await _db.hapus('kategori', where: '1 = 1', whereArgs: []);
    _modeError = false;
  }
}
