import 'package:dompet_kos/data/repository/RepositoryProfil.dart';
import 'package:dompet_kos/layanan/LayananAuth.dart';
import 'package:dompet_kos/provider/ProviderProfil.dart';
import 'package:flutter_test/flutter_test.dart';

class _ProfilUji implements RepositoryProfil {
  Pengguna? tersimpan;
  String sandi = '';

  @override
  Future<Pengguna?> ambilProfil() async => tersimpan;

  @override
  Future<Pengguna> perbarui({required String nama, required String email}) async {
    tersimpan = Pengguna(nama: nama.trim(), email: email.trim().toLowerCase());
    return tersimpan!;
  }

  @override
  Future<void> ubahSandi({
    required String sandiLama,
    required String sandiBaru,
  }) async {
    if (sandiLama != sandi) throw Exception('Sandi lama tidak sesuai.');
    sandi = sandiBaru;
  }
}

void main() {
  test('simpan profil valid memperbarui nama dan email', () async {
    final repo = _ProfilUji();
    final provider = ProviderProfil(repo);
    provider.isiDari(const Pengguna(nama: 'Miko', email: 'miko@kampus.ac.id'));

    provider.controllerNama.text = 'Miko Afrian';
    provider.controllerEmail.text = 'Miko@Kampus.ac.id';
    final hasil = await provider.simpanProfil();

    expect(hasil, isNotNull);
    expect(hasil!.nama, 'Miko Afrian');
    expect(hasil.email, 'miko@kampus.ac.id');
    expect(provider.statusSimpan.adalahSukses, isTrue);
  });

  test('simpan profil menolak email tidak valid', () async {
    final provider = ProviderProfil(_ProfilUji());
    provider.isiDari(const Pengguna(nama: 'Miko', email: 'miko@kampus.ac.id'));

    provider.controllerEmail.text = 'bukan-email';
    final hasil = await provider.simpanProfil();

    expect(hasil, isNull);
    expect(provider.statusSimpan.adalahError, isTrue);
    expect(provider.statusSimpan.pesan, 'Format email tidak valid');
  });

  test('ubah sandi memerlukan sandi lama yang benar', () async {
    final repo = _ProfilUji()..sandi = 'rahasia123';
    final provider = ProviderProfil(repo);

    provider.controllerSandiLama.text = 'salah';
    provider.controllerSandiBaru.text = 'baru123456';
    provider.controllerKonfirmasi.text = 'baru123456';
    final hasil = await provider.ubahSandi();

    expect(hasil, isFalse);
    expect(provider.statusSandi.adalahError, isTrue);
    expect(provider.statusSandi.pesan, 'Sandi lama tidak sesuai.');
  });

  test('ubah sandi sukses saat sandi lama benar', () async {
    final repo = _ProfilUji()..sandi = 'rahasia123';
    final provider = ProviderProfil(repo);

    provider.controllerSandiLama.text = 'rahasia123';
    provider.controllerSandiBaru.text = 'baru123456';
    provider.controllerKonfirmasi.text = 'baru123456';
    final hasil = await provider.ubahSandi();

    expect(hasil, isTrue);
    expect(repo.sandi, 'baru123456');
  });

  test('validasi sandi baru menolak konfirmasi beda', () {
    final provider = ProviderProfil(_ProfilUji());
    provider.controllerSandiBaru.text = 'baru123456';
    expect(provider.validasiKonfirmasi('beda'), isNotNull);
    expect(provider.validasiKonfirmasi('baru123456'), isNull);
  });
}
