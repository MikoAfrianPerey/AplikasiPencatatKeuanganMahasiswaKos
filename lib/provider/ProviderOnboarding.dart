import 'package:flutter/material.dart';

import '../data/model/Kategori.dart';
import '../data/model/PeriodeBudget.dart';
import '../data/repository/RepositoryKategori.dart';
import '../data/repository/RepositoryPeriodeBudget.dart';
import '../inti/state/StatusData.dart';
import '../inti/utils/PemformatMataUang.dart';
import '../inti/validasi/ValidasiAngka.dart';

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
      _statusKategori = StatusData.dariError(e);
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
      final controller = TextEditingController(text: '0');
      controller.addListener(notifyListeners);
      controllerBatas[item.id] = controller;
    }
    controllerPemasukan.addListener(notifyListeners);
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
    final kosong = nilai == null || nilai.isEmpty;
    return ValidasiAngka.jumlahPositif(
      nilai,
      kosong
          ? 'Total pemasukan tidak boleh kosong'
          : 'Masukkan angka lebih dari 0',
    );
  }

  String? validasiBatas(String? nilai) =>
      ValidasiAngka.batasTidakNegatif(nilai);

  String get ringkasanBatas {
    return 'Total batas: ${PemformatMataUang.format(_totalBatas)} '
        'dari ${PemformatMataUang.format(_totalPemasukan)}';
  }

  String? _validasiForm() {
    final errorPemasukan = validasiPemasukan(controllerPemasukan.text);
    if (errorPemasukan != null) return errorPemasukan;
    return _validasiTotal();
  }

  String? _validasiTotal() {
    for (final controller in controllerBatas.values) {
      final error = validasiBatas(controller.text);
      if (error != null) return error;
    }
    final totalBatas = _totalBatas;
    if (totalBatas > _totalPemasukan) {
      return 'Total batas kategori (${PemformatMataUang.format(totalBatas)}) '
          'melebihi total pemasukan (${PemformatMataUang.format(_totalPemasukan)}). '
          'Kurangi batas atau tambah pemasukan.';
    }
    return null;
  }

  Map<int, int> _kumpulkanBatas() => {
        for (final item in controllerBatas.entries)
          item.key: int.tryParse(item.value.text) ?? 0,
      };

  Future<void> simpanPeriode() async {
    _errorTotalBatas = _validasiTotal();
    if (_validasiForm() != null) {
      notifyListeners();
      return;
    }

    _statusSimpan = const StatusData.loading();
    notifyListeners();

    try {
      final periode = await _repositoryPeriode.buatPeriode(
        totalPemasukan: _totalPemasukan,
        batasKategori: _kumpulkanBatas(),
      );
      _statusSimpan = StatusData.sukses(periode);
    } on Exception catch (e) {
      _statusSimpan = StatusData.dariError(e);
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
