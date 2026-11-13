import 'package:flutter/material.dart';

import '../data/model/Kategori.dart';
import '../data/model/Transaksi.dart';
import '../data/repository/RepositoryKategori.dart';
import '../data/repository/RepositoryPeriodeBudget.dart';
import '../data/repository/RepositoryTransaksi.dart';
import '../inti/state/StatusData.dart';
import '../inti/validasi/ValidasiAngka.dart';
import '../layanan/LayananNotifikasi.dart';

class ProviderTransaksi extends ChangeNotifier {
  final RepositoryKategori _repositoryKategori;
  final RepositoryTransaksi _repositoryTransaksi;
  final RepositoryPeriodeBudget? _repositoryPeriode;
  final LayananNotifikasi? _notifikasi;

  ProviderTransaksi(
    this._repositoryKategori,
    this._repositoryTransaksi, {
    RepositoryPeriodeBudget? repositoryPeriode,
    LayananNotifikasi? notifikasi,
  })  : _repositoryPeriode = repositoryPeriode,
        _notifikasi = notifikasi;

  StatusData<List<Kategori>> _statusKategori = const StatusData.loading();
  StatusData<Transaksi> _statusSimpan = const StatusData.initial();
  String? _errorForm;
  int? _idTransaksiDiedit;
  String? _lokasi;
  String? _infoLokasi;

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
  int? get idTransaksiDiedit => _idTransaksiDiedit;
  bool get modeEdit => _idTransaksiDiedit != null;
  String? get lokasi => _lokasi;
  String? get infoLokasi => _infoLokasi;

  void setLokasi(String? lokasi, {String? info}) {
    _lokasi = lokasi;
    _infoLokasi = info;
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
        _kategoriTerpilih ??= hasil.first;
      }
    } on Exception catch (e) {
      _statusKategori = StatusData.dariError(e);
    }
    notifyListeners();
  }

  Future<void> muatUntukEdit(Transaksi transaksi) async {
    _idTransaksiDiedit = transaksi.id;
    _adalahPemasukan = transaksi.jenisTransaksi == JenisTransaksi.pemasukan;
    _jumlah = transaksi.jumlah.toString();
    _tanggal = transaksi.tanggalTransaksi;
    controllerCatatan.text = transaksi.catatan;
    _lokasi = transaksi.lokasi;
    _infoLokasi = transaksi.lokasi;
    notifyListeners();
    await muatKategori();
    for (final item in _statusKategori.data ?? const <Kategori>[]) {
      if (item.id == transaksi.idKategori) {
        _kategoriTerpilih = item;
        break;
      }
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
    _idTransaksiDiedit = null;
    _adalahPemasukan = false;
    _jumlah = '0';
    _kategoriTerpilih = _statusKategori.data?.isNotEmpty == true
        ? _statusKategori.data!.first
        : null;
    _tanggal = DateTime.now();
    _errorForm = null;
    controllerCatatan.clear();
    _lokasi = null;
    _infoLokasi = null;
    notifyListeners();
  }

  String? validasiJumlah() => ValidasiAngka.jumlahPositif(
        _jumlah,
        'Jumlah transaksi harus lebih dari 0',
      );

  JenisTransaksi get _jenisTerpilih =>
      _adalahPemasukan ? JenisTransaksi.pemasukan : JenisTransaksi.pengeluaran;

  String? _validasiForm() =>
      validasiJumlah() ??
      (_kategoriTerpilih == null
          ? 'Pilih kategori transaksi terlebih dahulu'
          : null);

  Future<void> simpanTransaksi() async {
    final error = _validasiForm();
    _errorForm = error;
    if (error != null) {
      notifyListeners();
      return;
    }

    _statusSimpan = const StatusData.loading();
    notifyListeners();

    try {
      final transaksi = await _tulisTransaksi();
      _statusSimpan = StatusData.sukses(transaksi);
      await _cekBatasKategori(transaksi);
    } on Exception catch (e) {
      _statusSimpan = StatusData.dariError(e);
    }
    notifyListeners();
  }

  Future<Transaksi> _tulisTransaksi() async {
    final idKategori = _kategoriTerpilih!.id;
    final jumlah = int.parse(_jumlah);
    final catatan = controllerCatatan.text.trim();
    final idEdit = _idTransaksiDiedit;

    if (idEdit == null) {
      return _repositoryTransaksi.buat(
        idKategori: idKategori,
        jumlah: jumlah,
        jenis: _jenisTerpilih,
        tanggal: _tanggal,
        catatan: catatan,
        lokasi: _lokasi,
      );
    }

    await _repositoryTransaksi.perbarui(
      idEdit,
      idKategori: idKategori,
      jumlah: jumlah,
      jenis: _jenisTerpilih,
      tanggal: _tanggal,
      catatan: catatan,
      lokasi: _lokasi,
    );
    final tersimpan = await _repositoryTransaksi.ambilBerdasarkanId(idEdit);
    return tersimpan ??
        (throw Exception('Transaksi tidak ditemukan saat diperbarui'));
  }

  Future<void> _cekBatasKategori(Transaksi transaksi) async {
    final notifikasi = _notifikasi;
    final repositoryPeriode = _repositoryPeriode;
    if (notifikasi == null || repositoryPeriode == null) return;
    if (transaksi.jenisTransaksi != JenisTransaksi.pengeluaran) return;
    try {
      final batas = await _batasKategori(transaksi.idKategori);
      if (batas == null) return;
      final terpakai = await _totalTerpakai(transaksi.idKategori);
      if (terpakai >= batas) {
        await notifikasi.kirimPeringatanBatas(
          _kategoriTerpilih?.nama ?? 'kategori ini',
        );
      }
    } on Exception catch (_) {
      // Kegagalan notifikasi tidak boleh menggagalkan penyimpanan transaksi.
    }
  }

  Future<int?> _batasKategori(int idKategori) async {
    final periode = await _repositoryPeriode!.ambilPeriodeAktif();
    if (periode == null) return null;
    final batas = await _repositoryPeriode!.ambilBatasPeriode(periode.id);
    for (final item in batas) {
      if (item.idKategori == idKategori) return item.jumlahBatas;
    }
    return null;
  }

  Future<int> _totalTerpakai(int idKategori) async {
    final semua = await _repositoryTransaksi.ambilSemua();
    return semua
        .where((t) =>
            t.idKategori == idKategori &&
            t.jenisTransaksi == JenisTransaksi.pengeluaran)
        .fold<int>(0, (total, t) => total + t.jumlah);
  }

  @override
  void dispose() {
    controllerCatatan.dispose();
    super.dispose();
  }
}
