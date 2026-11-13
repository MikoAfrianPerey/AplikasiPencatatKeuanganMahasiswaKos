import 'package:flutter/material.dart';

import '../inti/state/StatusData.dart';
import '../inti/validasi/ProfilValidasi.dart';
import '../layanan/LayananAuth.dart';

class ProviderAuth extends ChangeNotifier {
  final LayananAuth _layanan;

  ProviderAuth(this._layanan);

  StatusData<Pengguna> _status = const StatusData.initial();
  bool _sudahDaftar = false;
  bool _modeDaftar = false;

  StatusData<Pengguna> get status => _status;
  Pengguna? get pengguna => _status.data;
  bool get sudahDaftar => _sudahDaftar;
  bool get modeDaftar => _modeDaftar;
  bool get sedangMasuk => _status.data != null;

  set modeDaftar(bool nilai) {
    _modeDaftar = nilai;
    notifyListeners();
  }

  Future<void> periksaSesi() async {
    final pengguna = await _layanan.penggunaAktif();
    _sudahDaftar = await _layanan.sudahPernahDaftar();
    _status = pengguna == null
        ? const StatusData.initial()
        : StatusData.sukses(pengguna);
    notifyListeners();
  }

  String? validasiNama(String? nilai) =>
      ProfilValidasi.nama(nilai, modeDaftar: _modeDaftar);

  String? validasiEmail(String? nilai) => ProfilValidasi.email(nilai);

  String? validasiSandi(String? nilai) => ProfilValidasi.sandi(nilai);

  Future<void> kirim({
    required String nama,
    required String email,
    required String sandi,
  }) async {
    final error = ProfilValidasi.profil(
      nama: nama,
      email: email,
      sandi: sandi,
      modeDaftar: _modeDaftar,
    );
    if (error != null) {
      _status = StatusData.error(error);
      notifyListeners();
      return;
    }

    _status = const StatusData.loading();
    notifyListeners();
    try {
      final pengguna = await _daftarAtauMasuk(nama, email, sandi);
      _sudahDaftar = true;
      _status = pengguna == null
          ? const StatusData.error('Gagal menyimpan sesi')
          : StatusData.sukses(pengguna);
    } on Exception catch (error) {
      _status = StatusData.dariError(error);
    }
    notifyListeners();
  }

  Future<Pengguna?> _daftarAtauMasuk(
    String nama,
    String email,
    String sandi,
  ) async {
    if (!_modeDaftar) return _layanan.masuk(email: email, sandi: sandi);
    await _layanan.daftar(nama: nama, email: email, sandi: sandi);
    return _layanan.penggunaAktif();
  }

  Future<void> keluar() async {
    await _layanan.keluar();
    _status = const StatusData.initial();
    notifyListeners();
  }
}
