import 'package:flutter/material.dart';

import '../data/model/Kategori.dart';
import '../data/model/PeriodeBudget.dart';
import '../data/repository/RepositoryKategori.dart';
import '../data/repository/RepositoryPeriodeBudget.dart';
import '../inti/state/StatusData.dart';
import '../inti/utils/PemformatMataUang.dart';

class ProviderOnboarding extends ChangeNotifier {
  final RepositoryKategori _repositoryKategori;
  final RepositoryPeriodeBudget _repositoryPeriode;

  ProviderOnboarding(this._repositoryKategori, this._repositoryPeriode);

  StatusData<List<Kategori>> _statusKategori = const StatusData.loading();
  StatusData<PeriodeBudget> _statusSimpan = const StatusData.initial();
  String? _errorTotalBatas;
  bool _izinNotifikasi = false;

  final TextEditingController controllerPemasukan = TextEditingController();
  final Map<int, TextEditingController> controllerBatas = {};

  StatusData<List<Kategori>> get statusKategori => _statusKategori;
  StatusData<PeriodeBudget> get statusSimpan => _statusSimpan;
  String? get errorTotalBatas => _errorTotalBatas;
  bool get izinNotifikasi => _izinNotifikasi;
  List<Kategori>? get kategori => _statusKategori.data;

  set izinNotifikasi(bool nilai) {
    _izinNotifikasi = nilai;
    notifyListeners();
  }

  Future<void> muatKategori() async {
    _statusKategori = const StatusData.loading();
    notifyListeners();
    try {
      final hasil = await _repositoryKategori.ambilSemua();
      if (hasil.isEmpty) {
        _statusKategori = const StatusData.kosong();
      } else {
        _statusKategori = StatusData.sukses(hasil);
        _siapkanController(hasil);
      }
    } on Exception catch (e) {
      _statusKategori = StatusData.error(e.toString());
    }
    notifyListeners();
  }

  Future<void> buatKategoriDefault() async {
    await _repositoryKategori.buatDefault();
    await muatKategori();
  }

  void _siapkanController(List<Kategori> daftar) {
    for (final controller in controllerBatas.values) {
      controller.dispose();
    }
    controllerBatas.clear();
    for (final item in daftar) {
      controllerBatas[item.id] = TextEditingController(text: '0');
    }
  }

  int get _totalPemasukan => int.tryParse(controllerPemasukan.text) ?? 0;

  int get _totalBatas {
    var total = 0;
    for (final controller in controllerBatas.values) {
      total += int.tryParse(controller.text) ?? 0;
    }
    return total;
  }

  String? validasiPemasukan(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Total pemasukan tidak boleh kosong';
    }
    final jumlah = int.tryParse(nilai);
    if (jumlah == null || jumlah <= 0) {
      return 'Masukkan angka lebih dari 0';
    }
    return null;
  }

  String? validasiBatas(String? nilai) {
    final batas = int.tryParse(nilai ?? '');
    if (batas == null) {
      return 'Isi dengan angka';
    }
    if (batas < 0) {
      return 'Batas tidak boleh negatif';
    }
    return null;
  }

  String get ringkasanBatas {
    return 'Total batas: ${PemformatMataUang.format(_totalBatas)} '
        'dari ${PemformatMataUang.format(_totalPemasukan)}';
  }

  Future<void> simpanPeriode() async {
    _errorTotalBatas = null;

    if (validasiPemasukan(controllerPemasukan.text) != null) {
      notifyListeners();
      return;
    }

    for (final controller in controllerBatas.values) {
      if (validasiBatas(controller.text) != null) {
        notifyListeners();
        return;
      }
    }

    final totalBatas = _totalBatas;
    if (totalBatas > _totalPemasukan) {
      _errorTotalBatas = 'Total batas kategori (${PemformatMataUang.format(totalBatas)}) '
          'melebihi total pemasukan (${PemformatMataUang.format(_totalPemasukan)}). '
          'Kurangi batas atau tambah pemasukan.';
      notifyListeners();
      return;
    }
    _errorTotalBatas = null;

    _statusSimpan = const StatusData.loading();
    notifyListeners();

    try {
      final batas = <int, int>{};
      for (final item in controllerBatas.entries) {
        batas[item.key] = int.tryParse(item.value.text) ?? 0;
      }
      final periode = await _repositoryPeriode.buatPeriode(
        totalPemasukan: _totalPemasukan,
        batasKategori: batas,
      );
      _statusSimpan = StatusData.sukses(periode);
    } on Exception catch (e) {
      _statusSimpan = StatusData.error(e.toString());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    controllerPemasukan.dispose();
    for (final controller in controllerBatas.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
