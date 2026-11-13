import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../layanan/LayananAuth.dart';

abstract class RepositoryProfil {
  Future<Pengguna?> ambilProfil();

  Future<Pengguna> perbarui({required String nama, required String email});

  Future<void> ubahSandi({
    required String sandiLama,
    required String sandiBaru,
  });
}

class PenyimpananProfilLokal {
  static const kunciNama = 'auth_nama';
  static const kunciEmail = 'auth_email';
  static const kunciSandi = 'auth_sandi';
  static const kunciMasuk = 'auth_masuk';

  static String hash(String sandi) =>
      base64Encode(sha256.convert(utf8.encode(sandi)).bytes);
}
