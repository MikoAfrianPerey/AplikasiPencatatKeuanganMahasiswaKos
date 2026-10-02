class Kategori {
  final int id;
  final String nama;
  final String namaIkon;
  final int nilaiWarna;
  final bool adalahDefault;
  final DateTime dibuatPada;

  const Kategori({
    required this.id,
    required this.nama,
    required this.namaIkon,
    required this.nilaiWarna,
    this.adalahDefault = false,
    required this.dibuatPada,
  });

  factory Kategori.dariMap(Map<String, dynamic> map) {
    return Kategori(
      id: map['id'] as int,
      nama: map['nama'] as String,
      namaIkon: map['nama_ikon'] as String,
      nilaiWarna: map['warna'] as int,
      adalahDefault: (map['adalah_default'] as int?) == 1,
      dibuatPada: DateTime.parse(map['dibuat_pada'] as String),
    );
  }

  Map<String, dynamic> keMap() {
    return {
      'id': id,
      'nama': nama,
      'nama_ikon': namaIkon,
      'warna': nilaiWarna,
      'adalah_default': adalahDefault ? 1 : 0,
      'dibuat_pada': dibuatPada.toIso8601String(),
    };
  }
}
