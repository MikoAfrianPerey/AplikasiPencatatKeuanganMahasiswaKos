import 'package:flutter/material.dart';

import '../data/model/Kategori.dart';
import '../data/model/Transaksi.dart';
import '../data/repository/RepositoryKategori.dart';
import '../data/repository/RepositoryPeriodeBudget.dart';
import '../data/repository/RepositoryTransaksi.dart';
import '../inti/state/StatusData.dart';
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
      _statusKategori = StatusData.error(e.toString());
    }
    notifyListeners();
  }

  Future<void> muatUntukEdit(Transaksi transaksi) async {
    _idTransaksiDiedit = transaksi.id;
    _adalahPemasukan =
        transaksi.jenisTransaksi == JenisTransaksi.pemasukan;
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
      final Transaksi transaksi;
      if (_idTransaksiDiedit != null) {
        await _repositoryTransaksi.perbarui(
          _idTransaksiDiedit!,
          idKategori: _kategoriTerpilih!.id,
          jumlah: int.parse(_jumlah),
          jenis: _adalahPemasukan
              ? JenisTransaksi.pemasukan
              : JenisTransaksi.pengeluaran,
          tanggal: _tanggal,
          catatan: controllerCatatan.text.trim(),
          lokasi: _lokasi,
        );
        final tersimpan =
            await _repositoryTransaksi.ambilBerdasarkanId(_idTransaksiDiedit!);
        transaksi = tersimpan ??
            (throw Exception('Transaksi tidak ditemukan saat diperbarui'));
      } else {
        transaksi = await _repositoryTransaksi.buat(
          idKategori: _kategoriTerpilih!.id,
          jumlah: int.parse(_jumlah),
          jenis: _adalahPemasukan
              ? JenisTransaksi.pemasukan
              : JenisTransaksi.pengeluaran,
          tanggal: _tanggal,
          catatan: controllerCatatan.text.trim(),
          lokasi: _lokasi,
        );
      }
      _statusSimpan = StatusData.sukses(transaksi);
      await _cekBatasKategori(transaksi);
    } on Exception catch (e) {
      _statusSimpan = StatusData.error(e.toString());
    }
    notifyListeners();
  }

  Future<void> _cekBatasKategori(Transaksi transaksi) async {
    final notifikasi = _notifikasi;
    final repositoryPeriode = _repositoryPeriode;
    if (notifikasi == null || repositoryPeriode == null) return;
    if (transaksi.jenisTransaksi != JenisTransaksi.pengeluaran) return;
    try {
      final periode = await repositoryPeriode.ambilPeriodeAktif();
      if (periode == null) return;
      final batas = await repositoryPeriode.ambilBatasPeriode(periode.id);
      final cocok = batas.where((b) => b.idKategori == transaksi.idKategori);
      if (cocok.isEmpty) return;
      final semua = await _repositoryTransaksi.ambilSemua();
      final terpakai = semua
          .where((t) =>
              t.idKategori == transaksi.idKategori &&
              t.jenisTransaksi == JenisTransaksi.pengeluaran)
          .fold(0, (total, t) => total + t.jumlah);
      if (terpakai >= cocok.first.jumlahBatas) {
        await notifikasi.kirimPeringatanBatas(
          _kategoriTerpilih?.nama ?? 'kategori ini',
        );
      }
    } on Exception catch (_) {
      // Kegagalan notifikasi tidak boleh menggagalkan penyimpanan transaksi.
    }
  }

  @override
  void dispose() {
    controllerCatatan.dispose();
    super.dispose();
  }
}
