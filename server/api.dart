import 'dart:convert';
import 'dart:io';

const _filePath = 'server/data/transaksi.json';

Future<void> main() async {
  final file = File(_filePath);
  await file.parent.create(recursive: true);
  if (!await file.exists()) await file.writeAsString('[]');

  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  stdout.writeln(
      'DompetKos API: http://${server.address.address}:${server.port}');

  await for (final request in server) {
    try {
      await _layani(request, file);
    } catch (error) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'error': 'Kesalahan server'}));
      await request.response.close();
      stderr.writeln(error);
    }
  }
}

Future<void> _layani(HttpRequest request, File file) async {
  final response = request.response;
  response.headers.contentType = ContentType.json;
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers
      .set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  response.headers.set('Access-Control-Allow-Headers', 'Content-Type');

  if (request.method == 'OPTIONS') {
    response.statusCode = HttpStatus.noContent;
    await response.close();
    return;
  }
  if (request.uri.path != '/transaksi') {
    response.statusCode = HttpStatus.notFound;
    response.write(jsonEncode({'error': 'Endpoint tidak ditemukan'}));
    await response.close();
    return;
  }

  final data = (jsonDecode(await file.readAsString()) as List)
      .cast<Map<String, dynamic>>();
  final id = int.tryParse(request.uri.queryParameters['id'] ?? '');
  switch (request.method) {
    case 'GET':
      final hasil =
          id == null ? data : data.where((item) => item['id'] == id).toList();
      response.write(jsonEncode(hasil));
    case 'POST':
      final body = await _bacaBody(request);
      if (body == null || !_valid(body, create: true)) {
        response.statusCode = HttpStatus.badRequest;
        response.write(jsonEncode({'error': 'Data transaksi tidak valid'}));
        break;
      }
      final novoId = data.fold<int>(
              0,
              (maior, item) =>
                  (item['id'] as int) > maior ? item['id'] as int : maior) +
          1;
      final item = {...body, 'id': novoId};
      data.insert(0, item);
      await file.writeAsString(jsonEncode(data));
      response.statusCode = HttpStatus.created;
      response.write(jsonEncode(item));
    case 'PUT':
      final body = await _bacaBody(request);
      if (body == null || !_valid(body, create: false)) {
        response.statusCode = HttpStatus.badRequest;
        response.write(jsonEncode({'error': 'Data transaksi tidak valid'}));
        break;
      }
      final index = data.indexWhere((item) => item['id'] == id);
      if (index < 0) {
        response.statusCode = HttpStatus.notFound;
        response.write(jsonEncode({'error': 'Transaksi tidak ditemukan'}));
      } else {
        data[index] = {...data[index], ...body, 'id': id};
        await file.writeAsString(jsonEncode(data));
        response.write(jsonEncode(data[index]));
      }
    case 'DELETE':
      final panjangAwal = data.length;
      data.removeWhere((item) => item['id'] == id);
      if (data.length == panjangAwal) response.statusCode = HttpStatus.notFound;
      await file.writeAsString(jsonEncode(data));
      response.write(jsonEncode({'dihapus': data.length != panjangAwal}));
    default:
      response.statusCode = HttpStatus.methodNotAllowed;
      response.write(jsonEncode({'error': 'Metode tidak didukung'}));
  }
  await response.close();
}

Future<Map<String, dynamic>?> _bacaBody(HttpRequest request) async {
  try {
    final body = jsonDecode(await utf8.decoder.bind(request).join());
    return body is Map<String, dynamic> ? body : null;
  } on FormatException {
    return null;
  }
}

bool _valid(Map<String, dynamic> body, {required bool create}) {
  const allowed = {
    'id_periode_budget',
    'id_kategori',
    'jenis_transaksi',
    'jumlah',
    'catatan',
    'tanggal_transaksi',
    'dibuat_pada',
    'lokasi',
  };
  if (body.keys.any((key) => !allowed.contains(key))) {
    return false;
  }
  if (create &&
      !body.keys.toSet().containsAll(allowed.difference({'lokasi'}))) {
    return false;
  }
  if (body.containsKey('id_periode_budget') &&
      (body['id_periode_budget'] is! int || body['id_periode_budget'] < 1)) {
    return false;
  }
  if (body.containsKey('id_kategori') &&
      (body['id_kategori'] is! int || body['id_kategori'] < 1)) {
    return false;
  }
  if (body.containsKey('jumlah') &&
      (body['jumlah'] is! int || body['jumlah'] < 1)) {
    return false;
  }
  if (body.containsKey('jenis_transaksi') &&
      !['PEMASUKAN', 'PENGELUARAN'].contains(body['jenis_transaksi'])) {
    return false;
  }
  if (body.containsKey('catatan') && body['catatan'] is! String) {
    return false;
  }
  if (body.containsKey('lokasi') &&
      body['lokasi'] != null &&
      body['lokasi'] is! String) {
    return false;
  }
  for (final key in ['tanggal_transaksi', 'dibuat_pada']) {
    if (body.containsKey(key)) {
      if (body[key] is! String ||
          DateTime.tryParse(body[key] as String) == null) {
        return false;
      }
    }
  }
  return true;
}
