import 'package:shared_preferences/shared_preferences.dart';

import '../../layanan/LayananAuth.dart';
import 'RepositoryProfil.dart';

class RepositoryProfilLokal implements RepositoryProfil {
  static const _kunciNama = PenyimpananProfilLokal.kunciNama;
  static const _kunciEmail = PenyimpananProfilLokal.kunciEmail;
  static const _kunciSandi = PenyimpananProfilLokal.kunciSandi;
  static const _kunciMasuk = PenyimpananProfilLokal.kunciMasuk;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<Pengguna?> ambilProfil() async {
    final prefs = await _prefs;
    if (prefs.getBool(_kunciMasuk) != true) return null;
    final nama = prefs.getString(_kunciNama);
    final email = prefs.getString(_kunciEmail);
    if (nama == null || email == null) return null;
    return Pengguna(nama: nama, email: email);
  }

  @override
  Future<Pengguna> perbarui({
    required String nama,
    required String email,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_kunciNama, nama.trim());
    await prefs.setString(_kunciEmail, email.trim().toLowerCase());
    return Pengguna(nama: nama.trim(), email: email.trim().toLowerCase());
  }

  @override
  Future<void> ubahSandi({
    required String sandiLama,
    required String sandiBaru,
  }) async {
    final prefs = await _prefs;
    if (prefs.getString(_kunciSandi) !=
        PenyimpananProfilLokal.hash(sandiLama)) {
      throw Exception('Sandi lama tidak sesuai.');
    }
    await prefs.setString(
      _kunciSandi,
      PenyimpananProfilLokal.hash(sandiBaru),
    );
  }
}
