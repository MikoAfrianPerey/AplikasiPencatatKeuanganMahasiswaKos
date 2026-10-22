import 'dart:convert';
import 'dart:io';

import 'package:dompet_kos/data/model/Transaksi.dart';
import 'package:dompet_kos/data/repository/RepositoryTransaksiApi.dart';
import 'package:flutter_test/flutter_test.dart';

const _transaksi = {
  'id': 7,
  'id_periode_budget': 1,
  'id_kategori': 2,
  'jenis_transaksi': 'PENGELUARAN',
  'jumlah': 25000,
  'catatan': 'Makan siang',
  'tanggal_transaksi': '2026-10-01T00:00:00.000',
  'dibuat_pada': '2026-10-01T01:00:00.000',
};

void main() {
  late HttpServer server;
  late RepositoryTransaksiApi repository;
  var mode = 'normal';

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    mode = 'normal';
    server.listen((request) async {
      final response = request.response;
      if (request.method == 'POST') {
        final body = jsonDecode(await utf8.decoder.bind(request).join())
            as Map<String, dynamic>;
        response.statusCode = HttpStatus.created;
        response.write(jsonEncode({...body, 'id': 7}));
      } else if (mode == 'http') {
        response.statusCode = HttpStatus.serviceUnavailable;
        response.write('{"error":"offline"}');
      } else if (mode == 'json') {
        response.write('{rusak');
      } else if (mode == 'empty') {
        response.write('[]');
      } else {
        response.write(jsonEncode([_transaksi]));
      }
      await response.close();
    });
    repository = RepositoryTransaksiApi(
      baseUri: Uri.parse('http://${server.address.address}:${server.port}'),
    );
  });

  tearDown(() async {
    repository.tutup();
    await server.close(force: true);
  });

  test('model valid: menerima JSON transaksi', () {
    final transaksi = Transaksi.dariMap(_transaksi);
    expect(transaksi.id, 7);
    expect(transaksi.jumlah, 25000);
    expect(transaksi.jenisTransaksi, JenisTransaksi.pengeluaran);
  });

  test('model invalid: menolak field wajib yang rusak', () {
    expect(
      () => Transaksi.dariMap({..._transaksi, 'jumlah': 'dua puluh'}),
      throwsFormatException,
    );
  });

  test('API sukses: membaca transaksi dari backend', () async {
    final transaksi = await repository.ambilSemua();
    expect(transaksi, hasLength(1));
    expect(transaksi.single.catatan, 'Makan siang');
  });

  test('API simpan: mengirim transaksi ke backend', () async {
    final dibuat = await repository.buat(
      idKategori: 2,
      jumlah: 25000,
      jenis: JenisTransaksi.pengeluaran,
      tanggal: DateTime(2026, 10, 1),
      catatan: 'Makan siang',
    );
    expect(dibuat.id, 7);
    expect(dibuat.jumlah, 25000);
  });

  test('data kosong: mengembalikan daftar kosong', () async {
    mode = 'empty';
    expect(await repository.ambilSemua(), isEmpty);
  });

  test('HTTP gagal: mengembalikan HttpException', () async {
    mode = 'http';
    expect(repository.ambilSemua(), throwsA(isA<HttpException>()));
  });

  test('JSON rusak: mengembalikan FormatException', () async {
    mode = 'json';
    expect(repository.ambilSemua(), throwsFormatException);
  });
}
