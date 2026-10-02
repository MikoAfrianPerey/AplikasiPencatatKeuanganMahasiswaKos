class PeriodeBudget {
  final int id;
  final int bulanPeriode;
  final int tahunPeriode;
  final int totalPemasukan;
  final DateTime tanggalMulai;
  final DateTime tanggalAkhir;
  final bool aktifSekarang;
  final DateTime dibuatPada;

  const PeriodeBudget({
    required this.id,
    required this.bulanPeriode,
    required this.tahunPeriode,
    required this.totalPemasukan,
    required this.tanggalMulai,
    required this.tanggalAkhir,
    this.aktifSekarang = true,
    required this.dibuatPada,
  });

  factory PeriodeBudget.dariMap(Map<String, dynamic> map) {
    return PeriodeBudget(
      id: map['id'] as int,
      bulanPeriode: map['bulan_periode'] as int,
      tahunPeriode: map['tahun_periode'] as int,
      totalPemasukan: map['total_pemasukan'] as int,
      tanggalMulai: DateTime.parse(map['tanggal_mulai'] as String),
      tanggalAkhir: DateTime.parse(map['tanggal_akhir'] as String),
      aktifSekarang: (map['aktif_sekarang'] as int?) == 1,
      dibuatPada: DateTime.parse(map['dibuat_pada'] as String),
    );
  }

  Map<String, dynamic> keMap() {
    return {
      'id': id,
      'bulan_periode': bulanPeriode,
      'tahun_periode': tahunPeriode,
      'total_pemasukan': totalPemasukan,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_akhir': tanggalAkhir.toIso8601String(),
      'aktif_sekarang': aktifSekarang ? 1 : 0,
      'dibuat_pada': dibuatPada.toIso8601String(),
    };
  }
}
