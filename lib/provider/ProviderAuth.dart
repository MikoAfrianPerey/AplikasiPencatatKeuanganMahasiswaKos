import 'package:flutter/material.dart';

import '../inti/state/StatusData.dart';
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

  String? validasiNama(String? nilai) {
    if (_modeDaftar && (nilai == null || nilai.trim().length < 3)) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? validasiEmail(String? nilai) {
    final email = nilai?.trim() ?? '';
    if (email.isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validasiSandi(String? nilai) {
    if (nilai == null || nilai.length < 6) {
      return 'Sandi minimal 6 karakter';
    }
    return null;
  }

  Future<void> kirim({
    required String nama,
    required String email,
    required String sandi,
  }) async {
    if (validasiEmail(email) != null ||
        validasiSandi(sandi) != null ||
        validasiNama(nama) != null) {
      _status = StatusData.error(
        validasiNama(nama) ?? validasiEmail(email) ?? validasiSandi(sandi)!,
      );
      notifyListeners();
      return;
    }

    _status = const StatusData.loading();
    notifyListeners();
    try {
      final pengguna = _modeDaftar
          ? await _layanan.daftar(nama: nama, email: email, sandi: sandi).then(
              (_) => _layanan.penggunaAktif(),
            )
          : await _layanan.masuk(email: email, sandi: sandi);
      _sudahDaftar = true;
      _status = pengguna == null
          ? const StatusData.error('Gagal menyimpan sesi')
          : StatusData.sukses(pengguna);
    } on Exception catch (error) {
      _status = StatusData.error(error.toString().replaceFirst('Exception: ', ''));
    }
    notifyListeners();
  }

  Future<void> keluar() async {
    await _layanan.keluar();
    _status = const StatusData.initial();
    notifyListeners();
  }
}
