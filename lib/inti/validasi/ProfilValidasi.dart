class ProfilValidasi {
  static final _polaEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static const int panjangMinimalNama = 3;
  static const int panjangMinimalSandi = 6;

  static String? nama(String? nilai, {required bool modeDaftar}) {
    if (!modeDaftar) return null;
    if (nilai == null || nilai.trim().length < panjangMinimalNama) {
      return 'Nama minimal $panjangMinimalNama karakter';
    }
    return null;
  }

  static String? email(String? nilai) {
    final email = nilai?.trim() ?? '';
    if (email.isEmpty) return 'Email tidak boleh kosong';
    if (!_polaEmail.hasMatch(email)) return 'Format email tidak valid';
    return null;
  }

  static String? sandi(String? nilai) {
    if (nilai == null || nilai.length < panjangMinimalSandi) {
      return 'Sandi minimal $panjangMinimalSandi karakter';
    }
    return null;
  }

  static String? profil({
    required String? nama,
    required String? email,
    required String? sandi,
    required bool modeDaftar,
  }) =>
      ProfilValidasi.nama(nama, modeDaftar: modeDaftar) ??
      ProfilValidasi.email(email) ??
      ProfilValidasi.sandi(sandi);

  static String? sandiBaru({
    required String? sandiLama,
    required String? sandiBaru,
    required String? konfirmasi,
  }) {
    final lama = sandiLama ?? '';
    if (lama.isEmpty) return 'Sandi lama tidak boleh kosong';
    final baru = ProfilValidasi.sandi(sandiBaru);
    if (baru != null) return baru;
    if (sandiBaru == lama) return 'Sandi baru harus berbeda dari sandi lama';
    if (konfirmasi != sandiBaru) return 'Konfirmasi sandi tidak sama';
    return null;
  }
}
