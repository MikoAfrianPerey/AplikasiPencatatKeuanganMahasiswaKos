class BudgetKategori {
  final int id;
  final int idPeriodeBudget;
  final int idKategori;
  final int jumlahBatas;
  final double persenBatasPeringatan;
  final bool peringatanSudahDikirim;
  final DateTime dibuatPada;

  const BudgetKategori({
    required this.id,
    required this.idPeriodeBudget,
    required this.idKategori,
    required this.jumlahBatas,
    this.persenBatasPeringatan = 80,
    this.peringatanSudahDikirim = false,
    required this.dibuatPada,
  });

  factory BudgetKategori.dariMap(Map<String, dynamic> map) {
    return BudgetKategori(
      id: map['id'] as int,
      idPeriodeBudget: map['id_periode_budget'] as int,
      idKategori: map['id_kategori'] as int,
      jumlahBatas: map['jumlah_batas'] as int,
      persenBatasPeringatan: (map['persen_batas_peringatan'] as num).toDouble(),
      peringatanSudahDikirim: (map['peringatan_sudah_dikirim'] as int?) == 1,
      dibuatPada: DateTime.parse(map['dibuat_pada'] as String),
    );
  }

  Map<String, dynamic> keMap() {
    return {
      'id': id,
      'id_periode_budget': idPeriodeBudget,
      'id_kategori': idKategori,
      'jumlah_batas': jumlahBatas,
      'persen_batas_peringatan': persenBatasPeringatan,
      'peringatan_sudah_dikirim': peringatanSudahDikirim ? 1 : 0,
      'dibuat_pada': dibuatPada.toIso8601String(),
    };
  }
}
