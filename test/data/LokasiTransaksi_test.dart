import 'package:dompet_kos/data/model/Transaksi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dasar = {
    'id': 1,
    'id_periode_budget': 1,
    'id_kategori': 2,
    'jenis_transaksi': 'PENGELUARAN',
    'jumlah': 25000,
    'catatan': 'Makan',
    'tanggal_transaksi': '2026-10-01T00:00:00.000',
    'dibuat_pada': '2026-10-01T01:00:00.000',
  };

  test('transaksi tanpa lokasi tetap valid', () {
    final transaksi = Transaksi.dariMap(dasar);
    expect(transaksi.lokasi, isNull);
  });

  test('lokasi tersimpan dan ikut keMap', () {
    final transaksi = Transaksi.dariMap({
      ...dasar,
      'lokasi': '-6.20000, 106.81667',
    });
    expect(transaksi.lokasi, '-6.20000, 106.81667');
    expect(transaksi.keMap()['lokasi'], '-6.20000, 106.81667');
  });

  test('lokasi bertipe salah ditolak', () {
    expect(
      () => Transaksi.dariMap({...dasar, 'lokasi': 12345}),
      throwsFormatException,
    );
  });
}
