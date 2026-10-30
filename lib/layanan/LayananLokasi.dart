import 'dart:async';

import 'package:geolocator/geolocator.dart';

class HasilLokasi {
  final String? label;
  final String? pesan;

  const HasilLokasi.berhasil(this.label) : pesan = null;

  const HasilLokasi.batal(this.pesan) : label = null;

  bool get ada => label != null;
}

class LayananLokasi {
  Future<HasilLokasi> ambilLokasi() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const HasilLokasi.batal(
          'Layanan lokasi mati. Nyalakan GPS lalu coba lagi.',
        );
      }

      var izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }
      if (izin == LocationPermission.denied) {
        return const HasilLokasi.batal(
          'Izin lokasi ditolak. Transaksi tetap bisa disimpan tanpa lokasi.',
        );
      }
      if (izin == LocationPermission.deniedForever) {
        return const HasilLokasi.batal(
          'Izin lokasi diblokir permanen. Aktifkan lewat Pengaturan Android.',
        );
      }

      final posisi = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 25),
      );
      return HasilLokasi.berhasil(
        '${posisi.latitude.toStringAsFixed(5)}, '
        '${posisi.longitude.toStringAsFixed(5)}',
      );
    } on TimeoutException {
      final terakhir = await Geolocator.getLastKnownPosition();
      if (terakhir != null) {
        return HasilLokasi.berhasil(
          '${terakhir.latitude.toStringAsFixed(5)}, '
          '${terakhir.longitude.toStringAsFixed(5)}',
        );
      }
      return const HasilLokasi.batal(
        'Lokasi belum tersedia. Coba lagi di area terbuka.',
      );
    } on Exception catch (error) {
      return HasilLokasi.batal('Gagal mengambil lokasi: $error');
    }
  }
}
