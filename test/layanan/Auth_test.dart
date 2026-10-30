import 'package:dompet_kos/layanan/LayananAuth.dart';
import 'package:dompet_kos/provider/ProviderAuth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('validasi email & sandi menolak input tidak valid', () {
    final auth = ProviderAuth(LayananAuth());
    expect(auth.validasiEmail('bukan-email'), isNotNull);
    expect(auth.validasiEmail('miko@kampus.ac.id'), isNull);
    expect(auth.validasiSandi('123'), isNotNull);
    expect(auth.validasiSandi('rahasia123'), isNull);
  });

  test('daftar lalu masuk menyimpan sesi pengguna', () async {
    final layanan = LayananAuth();
    await layanan.daftar(
      nama: 'Miko',
      email: 'Miko@Kampus.ac.id',
      sandi: 'rahasia123',
    );

    final aktif = await layanan.penggunaAktif();
    expect(aktif, isNotNull);
    expect(aktif!.email, 'miko@kampus.ac.id');

    await layanan.keluar();
    expect(await layanan.penggunaAktif(), isNull);
  });

  test('masuk dengan sandi salah ditolak', () async {
    final layanan = LayananAuth();
    await layanan.daftar(
      nama: 'Miko',
      email: 'miko@kampus.ac.id',
      sandi: 'rahasia123',
    );
    await layanan.keluar();

    expect(
      () => layanan.masuk(email: 'miko@kampus.ac.id', sandi: 'salah'),
      throwsA(isA<Exception>()),
    );
  });

  test('sandi tidak disimpan dalam bentuk teks asli', () async {
    await LayananAuth().daftar(
      nama: 'Miko',
      email: 'miko@kampus.ac.id',
      sandi: 'rahasia123',
    );
    final prefs = await SharedPreferences.getInstance();
    final tersimpan = prefs.getString('auth_sandi');
    expect(tersimpan, isNot('rahasia123'));
    expect(tersimpan, isNotNull);
    expect(tersimpan!.isEmpty, isFalse);
  });

  test('ProviderAuth mengubah state loading lalu sukses', () async {
    final auth = ProviderAuth(LayananAuth());
    auth.modeDaftar = true;
    final hasil = auth.kirim(
      nama: 'Miko',
      email: 'miko@kampus.ac.id',
      sandi: 'rahasia123',
    );
    expect(auth.status.sedangLoading, isTrue);
    await hasil;
    expect(auth.sedangMasuk, isTrue);
    expect(auth.pengguna!.nama, 'Miko');
  });
}
