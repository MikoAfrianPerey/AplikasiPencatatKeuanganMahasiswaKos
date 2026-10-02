import '../model/Kategori.dart';

abstract class RepositoryKategori {
  Future<List<Kategori>> ambilSemua();

  Future<void> buatDefault();

  void aktifkanModeError();

  void nonaktifkanModeError();

  bool get modeErrorAktif;

  Future<void> reset();
}

class RepositoryKategoriMock implements RepositoryKategori {
  final List<Kategori> _kategori = [];
  final Duration jeda;
  bool _modeError = false;

  RepositoryKategoriMock({this.jeda = const Duration(milliseconds: 700)});

  @override
  Future<List<Kategori>> ambilSemua() async {
    await Future.delayed(jeda);
    if (_modeError) {
      throw Exception('Gagal memuat kategori. Periksa penyimpanan dan coba lagi.');
    }
    return List.unmodifiable(_kategori);
  }

  @override
  Future<void> buatDefault() async {
    await Future.delayed(jeda);
    isiKategoriDefault();
  }

  void isiKategoriDefault() {
    if (_kategori.isNotEmpty) return;
    final sekarang = DateTime.now();
    _kategori.addAll([
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
    ]);
  }

  @override
  void aktifkanModeError() => _modeError = true;

  @override
  void nonaktifkanModeError() => _modeError = false;

  @override
  bool get modeErrorAktif => _modeError;

  @override
  Future<void> reset() async {
    _kategori.clear();
    _modeError = false;
  }
}
