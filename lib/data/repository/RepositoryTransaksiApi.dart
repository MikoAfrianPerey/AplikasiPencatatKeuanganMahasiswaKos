import 'dart:convert';
import 'dart:io';

import '../model/Transaksi.dart';
import 'RepositoryTransaksi.dart';

class RepositoryTransaksiApi implements RepositoryTransaksi {
  final Uri baseUri;
  final HttpClient _client;

  RepositoryTransaksiApi({
    required this.baseUri,
    HttpClient? client,
  }) : _client = client ?? HttpClient();

  Uri get _endpoint => baseUri.resolve('/transaksi');

  @override
  Future<List<Transaksi>> ambilSemua() async {
    final response = await _kirim('GET', _endpoint);
    final decoded = jsonDecode(response);
    if (decoded is! List) {
      throw const FormatException('Respons transaksi harus berupa daftar');
    }
    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Transaksi tidak valid');
      }
      return Transaksi.dariMap(item);
    }).toList();
  }

  @override
  Future<Transaksi?> ambilBerdasarkanId(int id) async {
    final response =
        await _kirim('GET', _endpoint.replace(queryParameters: {'id': '$id'}));
    final decoded = jsonDecode(response) as List;
    if (decoded.isEmpty) return null;
    return Transaksi.dariMap(Map<String, dynamic>.from(decoded.first as Map));
  }

  @override
  Future<Transaksi> buat({
    required int idKategori,
    required int jumlah,
    required JenisTransaksi jenis,
    required DateTime tanggal,
    String catatan = '',
  }) async {
    final payload = {
      'id_periode_budget': 1,
      'id_kategori': idKategori,
      'jenis_transaksi':
          jenis == JenisTransaksi.pemasukan ? 'PEMASUKAN' : 'PENGELUARAN',
      'jumlah': jumlah,
      'catatan': catatan,
      'tanggal_transaksi': tanggal.toIso8601String(),
      'dibuat_pada': DateTime.now().toIso8601String(),
    };
    final response = await _kirim('POST', _endpoint, payload);
    return Transaksi.dariMap(jsonDecode(response) as Map<String, dynamic>);
  }

  @override
  Future<void> hapus(int id) async {
    await _kirim('DELETE', _endpoint.replace(queryParameters: {'id': '$id'}));
  }

  @override
  Future<void> perbarui(
    int id, {
    int? idKategori,
    int? jumlah,
    JenisTransaksi? jenis,
    DateTime? tanggal,
    String? catatan,
  }) async {
    final payload = <String, dynamic>{};
    if (idKategori != null) payload['id_kategori'] = idKategori;
    if (jumlah != null) payload['jumlah'] = jumlah;
    if (jenis != null) {
      payload['jenis_transaksi'] =
          jenis == JenisTransaksi.pemasukan ? 'PEMASUKAN' : 'PENGELUARAN';
    }
    if (tanggal != null) {
      payload['tanggal_transaksi'] = tanggal.toIso8601String();
    }
    if (catatan != null) {
      payload['catatan'] = catatan;
    }
    await _kirim(
        'PUT', _endpoint.replace(queryParameters: {'id': '$id'}), payload);
  }

  Future<String> _kirim(String method, Uri uri, [Object? payload]) async {
    final request = await _client.openUrl(method, uri);
    request.headers.contentType = ContentType.json;
    if (payload != null) request.write(jsonEncode(payload));
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('API mengembalikan HTTP ${response.statusCode}',
          uri: uri);
    }
    return body;
  }

  void tutup() => _client.close(force: true);
}
