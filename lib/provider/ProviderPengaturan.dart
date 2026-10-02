import 'package:flutter/material.dart';

import '../data/repository/RepositoryKategori.dart';

class ProviderPengaturan extends ChangeNotifier {
  final RepositoryKategori _repositoryKategori;
  double _ambangNotifikasi = 80;
  bool _pengingatHarian = true;
  bool _simulasiError = false;

  ProviderPengaturan(this._repositoryKategori);

  double get ambangNotifikasi => _ambangNotifikasi;
  bool get pengingatHarian => _pengingatHarian;
  bool get simulasiError => _simulasiError;

  void setAmbangNotifikasi(double nilai) {
    _ambangNotifikasi = nilai;
    notifyListeners();
  }

  void setPengingatHarian(bool nilai) {
    _pengingatHarian = nilai;
    notifyListeners();
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
