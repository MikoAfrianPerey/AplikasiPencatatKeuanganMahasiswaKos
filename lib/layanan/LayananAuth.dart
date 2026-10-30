import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pengguna {
  final String nama;
  final String email;

  const Pengguna({required this.nama, required this.email});
}

class LayananAuth {
  static const _kunciNama = 'auth_nama';
  static const _kunciEmail = 'auth_email';
  static const _kunciSandi = 'auth_sandi';
  static const _kunciMasuk = 'auth_masuk';

  Future<bool> sudahPernahDaftar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kunciEmail) != null;
  }

  Future<Pengguna?> penggunaAktif() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kunciMasuk) != true) return null;
    final nama = prefs.getString(_kunciNama);
    final email = prefs.getString(_kunciEmail);
    if (nama == null || email == null) return null;
    return Pengguna(nama: nama, email: email);
  }

  Future<void> daftar({
    required String nama,
    required String email,
    required String sandi,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kunciNama, nama.trim());
    await prefs.setString(_kunciEmail, email.trim().toLowerCase());
    await prefs.setString(_kunciSandi, _hash(sandi));
    await prefs.setBool(_kunciMasuk, true);
  }

  Future<Pengguna> masuk({
    required String email,
    required String sandi,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final emailTersimpan = prefs.getString(_kunciEmail);
    if (emailTersimpan == null) {
      throw Exception('Akun belum terdaftar. Silakan daftar lebih dulu.');
    }
    if (emailTersimpan != email.trim().toLowerCase()) {
      throw Exception('Email atau sandi salah.');
    }
    if (prefs.getString(_kunciSandi) != _hash(sandi)) {
      throw Exception('Email atau sandi salah.');
    }
    await prefs.setBool(_kunciMasuk, true);
    return Pengguna(
      nama: prefs.getString(_kunciNama) ?? 'Pengguna',
      email: emailTersimpan,
    );
  }

  Future<void> keluar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kunciMasuk, false);
  }

  String _hash(String sandi) =>
      base64Encode(sha256.convert(utf8.encode(sandi)).bytes);
}
