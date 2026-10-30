import 'package:flutter/material.dart';

import '../data/repository/RepositoryKategori.dart';
import '../layanan/LayananNotifikasi.dart';

class ProviderPengaturan extends ChangeNotifier {
  final RepositoryKategori _repositoryKategori;
  final LayananNotifikasi _notifikasi;
  double _ambangNotifikasi = 80;
  bool _pengingatHarian = true;
  bool _simulasiError = false;
  bool _izinNotifikasi = false;
  bool _sedangMengaturNotifikasi = false;

  ProviderPengaturan(this._repositoryKategori, this._notifikasi);

  double get ambangNotifikasi => _ambangNotifikasi;
  bool get pengingatHarian => _pengingatHarian;
  bool get simulasiError => _simulasiError;
  bool get izinNotifikasi => _izinNotifikasi;
  bool get sedangMengaturNotifikasi => _sedangMengaturNotifikasi;

  Future<void> periksaIzinNotifikasi() async {
    _izinNotifikasi = await _notifikasi.inisialisasi();
    notifyListeners();
  }

  Future<bool> mintaIzinNotifikasi() async {
    _izinNotifikasi = await _notifikasi.mintaIzin();
    notifyListeners();
    return _izinNotifikasi;
  }

  void setAmbangNotifikasi(double nilai) {
    _ambangNotifikasi = nilai;
    notifyListeners();
  }

  Future<void> setPengingatHarian(bool nilai) async {
    _sedangMengaturNotifikasi = true;
    notifyListeners();
    if (!_izinNotifikasi) {
      _izinNotifikasi = await _notifikasi.mintaIzin();
    }
    if (_izinNotifikasi) {
      await _notifikasi.jadwalkanPengingatHarian(aktif: nilai);
      _pengingatHarian = nilai;
    }
    _sedangMengaturNotifikasi = false;
    notifyListeners();
  }

  Future<void> kirimUjiNotifikasi() async {
    if (!_izinNotifikasi) {
      _izinNotifikasi = await _notifikasi.mintaIzin();
      notifyListeners();
    }
    if (_izinNotifikasi) {
      await _notifikasi.kirimPeringatanBatas('makan');
    }
  }

  void setSimulasiError(bool nilai) {
    _simulasiError = nilai;
    if (nilai) {
      _repositoryKategori.aktifkanModeError();
    } else {
      _repositoryKategori.nonaktifkanModeError();
    }
    notifyListeners();
  }

  Future<void> resetDataDemo() async {
    await _repositoryKategori.reset();
    _simulasiError = false;
    notifyListeners();
  }
}
