import 'package:flutter/material.dart';

import '../data/model/Kategori.dart';
import '../data/model/Transaksi.dart';
import '../data/repository/RepositoryKategori.dart';
import '../data/repository/RepositoryTransaksi.dart';
import '../inti/state/StatusData.dart';

class ProviderTransaksi extends ChangeNotifier {
  final RepositoryKategori _repositoryKategori;
  final RepositoryTransaksi _repositoryTransaksi;

  ProviderTransaksi(this._repositoryKategori, this._repositoryTransaksi);

  StatusData<List<Kategori>> _statusKategori = const StatusData.loading();
  StatusData<Transaksi> _statusSimpan = const StatusData.initial();
  String? _errorForm;

  bool _adalahPemasukan = false;
  String _jumlah = '0';
  Kategori? _kategoriTerpilih;
  DateTime _tanggal = DateTime.now();
  final TextEditingController controllerCatatan = TextEditingController();

  StatusData<List<Kategori>> get statusKategori => _statusKategori;
  StatusData<Transaksi> get statusSimpan => _statusSimpan;
  String? get errorForm => _errorForm;
  bool get adalahPemasukan => _adalahPemasukan;
  String get jumlah => _jumlah;
  Kategori? get kategoriTerpilih => _kategoriTerpilih;
  DateTime get tanggal => _tanggal;
  List<Kategori>? get kategori => _statusKategori.data;

  Future<void> muatKategori() async {
    _statusKategori = const StatusData.loading();
    notifyListeners();
    try {
      final hasil = await _repositoryKategori.ambilSemua();
      if (hasil.isEmpty) {
        _statusKategori = const StatusData.kosong();
      } else {
        _statusKategori = StatusData.sukses(hasil);
        _kategoriTerpilih ??= hasil.first;      }
    } on Exception catch (e) {
      _statusKategori = StatusData.error(e.toString());
    }
    notifyListeners();
  }

  void setJenis(bool pemasukan) {
    _adalahPemasukan = pemasukan;
    notifyListeners();
  }

  void ketik(String nilai) {
    if (_jumlah == '0' && nilai != '000') {
      _jumlah = nilai;
    } else if (_jumlah == '0' && nilai == '000') {
      _jumlah = '0';
    } else {
      _jumlah += nilai;
    }
    notifyListeners();
  }

  void hapus() {
    if (_jumlah.length > 1) {
      _jumlah = _jumlah.substring(0, _jumlah.length - 1);
    } else {
      _jumlah = '0';
    }
    notifyListeners();
  }

  void setKategori(Kategori kategori) {
    _kategoriTerpilih = kategori;
    notifyListeners();
  }

  void setTanggal(DateTime tanggal) {
    _tanggal = tanggal;
    notifyListeners();
  }

  void reset() {
    _adalahPemasukan = false;
    _jumlah = '0';
    _kategoriTerpilih = _statusKategori.data?.isNotEmpty == true
        ? _statusKategori.data!.first
        : null;
    _tanggal = DateTime.now();
    _errorForm = null;
    controllerCatatan.clear();
    notifyListeners();
  }

  String? validasiJumlah() {
    final jumlah = int.tryParse(_jumlah);
    if (jumlah == null || jumlah <= 0) {
      return 'Jumlah transaksi harus lebih dari 0';
    }
    return null;
  }

  Future<void> simpanTransaksi() async {
    final errorJumlah = validasiJumlah();
    if (errorJumlah != null) {
      _errorForm = errorJumlah;
      notifyListeners();
      return;
    }
    if (_kategoriTerpilih == null) {
      _errorForm = 'Pilih kategori transaksi terlebih dahulu';
      notifyListeners();
      return;
    }
    _errorForm = null;

    _statusSimpan = const StatusData.loading();
    notifyListeners();

    try {
      final transaksi = await _repositoryTransaksi.buat(
        idKategori: _kategoriTerpilih!.id,
        jumlah: int.parse(_jumlah),
        jenis: _adalahPemasukan
            ? JenisTransaksi.pemasukan
            : JenisTransaksi.pengeluaran,
        tanggal: _tanggal,
        catatan: controllerCatatan.text.trim(),
      );
      _statusSimpan = StatusData.sukses(transaksi);
    } on Exception catch (e) {
      _statusSimpan = StatusData.error(e.toString());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    controllerCatatan.dispose();
    super.dispose();
  }
}
