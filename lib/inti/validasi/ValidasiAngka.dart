class ValidasiAngka {
  static String? jumlahPositif(String? nilai, String pesan) {
    final angka = int.tryParse(nilai ?? '');
    if (angka == null || angka <= 0) return pesan;
    return null;
  }

  static String? batasTidakNegatif(String? nilai) {
    final batas = int.tryParse(nilai ?? '');
    if (batas == null) return 'Isi dengan angka';
    if (batas < 0) return 'Batas tidak boleh negatif';
    return null;
  }
}
