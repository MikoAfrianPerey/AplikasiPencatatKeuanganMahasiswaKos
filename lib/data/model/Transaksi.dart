enum JenisTransaksi { pemasukan, pengeluaran }

class Transaksi {
  final int id;
  final int idPeriodeBudget;
  final int idKategori;
  final JenisTransaksi jenisTransaksi;
  final int jumlah;
  final String catatan;
  final DateTime tanggalTransaksi;
  final DateTime dibuatPada;

  const Transaksi({
    required this.id,
    required this.idPeriodeBudget,
    required this.idKategori,
    required this.jenisTransaksi,
    required this.jumlah,
    this.catatan = '',
    required this.tanggalTransaksi,
    required this.dibuatPada,
  });

  factory Transaksi.dariMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'] as int,
      idPeriodeBudget: map['id_periode_budget'] as int,
      idKategori: map['id_kategori'] as int,
      jenisTransaksi: map['jenis_transaksi'] == 'PEMASUKAN'
          ? JenisTransaksi.pemasukan
          : JenisTransaksi.pengeluaran,
      jumlah: map['jumlah'] as int,
      catatan: (map['catatan'] as String?) ?? '',
      tanggalTransaksi: DateTime.parse(map['tanggal_transaksi'] as String),
      dibuatPada: DateTime.parse(map['dibuat_pada'] as String),
    );
  }

  Map<String, dynamic> keMap() {
    return {
      'id': id,
      'id_periode_budget': idPeriodeBudget,
      'id_kategori': idKategori,
      'jenis_transaksi':
          jenisTransaksi == JenisTransaksi.pemasukan ? 'PEMASUKAN' : 'PENGELUARAN',
      'jumlah': jumlah,
      'catatan': catatan,
      'tanggal_transaksi': tanggalTransaksi.toIso8601String(),
      'dibuat_pada': dibuatPada.toIso8601String(),
    };
  }
}
