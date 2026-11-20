import 'package:flutter/material.dart';

import '../data/repository/RepositoryProfil.dart';
import '../inti/state/StatusData.dart';
import '../inti/utils/LogAplikasi.dart';
import '../inti/validasi/ProfilValidasi.dart';
import '../layanan/LayananAuth.dart';

class ProviderProfil extends ChangeNotifier {
  final RepositoryProfil _repository;

  ProviderProfil(this._repository);

  final TextEditingController controllerNama = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerSandiLama = TextEditingController();
  final TextEditingController controllerSandiBaru = TextEditingController();
  final TextEditingController controllerKonfirmasi = TextEditingController();

  StatusData<Pengguna> _statusSimpan = const StatusData.initial();
  StatusData<Pengguna> _statusSandi = const StatusData.initial();
  bool _sudahDiisi = false;

  StatusData<Pengguna> get statusSimpan => _statusSimpan;
  StatusData<Pengguna> get statusSandi => _statusSandi;

  void isiDari(Pengguna? pengguna) {
    if (_sudahDiisi || pengguna == null) return;
    _sudahDiisi = true;
    controllerNama.text = pengguna.nama;
    controllerEmail.text = pengguna.email;
  }

  String? validasiNama(String? nilai) =>
      ProfilValidasi.nama(nilai, modeDaftar: true);

  String? validasiEmail(String? nilai) => ProfilValidasi.email(nilai);

  String? validasiSandiBaru(String? nilai) => ProfilValidasi.sandiBaru(
        sandiLama: controllerSandiLama.text,
        sandiBaru: nilai,
        konfirmasi: controllerKonfirmasi.text,
      );

  String? validasiKonfirmasi(String? nilai) =>
      nilai == controllerSandiBaru.text ? null : 'Konfirmasi sandi tidak sama';

  void resetStatusSandi() {
    _statusSandi = const StatusData.initial();
    controllerSandiLama.clear();
    controllerSandiBaru.clear();
    controllerKonfirmasi.clear();
  }

  Future<Pengguna?> simpanProfil() async {
    final error = validasiNama(controllerNama.text) ??
        validasiEmail(controllerEmail.text);
    if (error != null) {
      _statusSimpan = StatusData.error(error);
      notifyListeners();
      return null;
    }

    _statusSimpan = const StatusData.loading();
    notifyListeners();
    try {
      final pengguna = await _repository.perbarui(
        nama: controllerNama.text,
        email: controllerEmail.text,
      );
      _statusSimpan = StatusData.sukses(pengguna);
      return pengguna;
    } on Exception catch (error) {
      LogAplikasi.error('Gagal simpan profil', error: error);
      _statusSimpan = StatusData.dariError(error);
      return null;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> ubahSandi() async {
    final error = ProfilValidasi.sandiBaru(
      sandiLama: controllerSandiLama.text,
      sandiBaru: controllerSandiBaru.text,
      konfirmasi: controllerKonfirmasi.text,
    );
    if (error != null) {
      _statusSandi = StatusData.error(error);
      notifyListeners();
      return false;
    }

    _statusSandi = const StatusData.loading();
    notifyListeners();
    try {
      await _repository.ubahSandi(
        sandiLama: controllerSandiLama.text,
        sandiBaru: controllerSandiBaru.text,
      );
      _statusSandi = const StatusData.sukses(Pengguna(nama: '', email: ''));
      resetStatusSandi();
      return true;
    } on Exception catch (error) {
      LogAplikasi.error('Gagal ubah sandi', error: error);
      _statusSandi = StatusData.dariError(error);
      return false;
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    controllerNama.dispose();
    controllerEmail.dispose();
    controllerSandiLama.dispose();
    controllerSandiBaru.dispose();
    controllerKonfirmasi.dispose();
    super.dispose();
  }
}
