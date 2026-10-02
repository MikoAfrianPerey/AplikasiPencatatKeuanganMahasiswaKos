# AplikasiPencatatKeuanganMahasiswaKos

Deskripsi masalah
Mahasiswa rantau/kos sering kehabisan uang bulanan karena tidak ada pencatatan pengeluaran yang konsisten. Aplikasi keuangan umum (Money Manager, dll) terlalu kompleks dan tidak menyasar pola pengeluaran spesifik mahasiswa (uang makan, kos, transportasi, hiburan).

Profil target pengguna
Mahasiswa S1 usia 18–24 tahun yang tinggal kos/kontrakan, menerima uang bulanan tetap dari orang tua atau beasiswa, belum terbiasa mengatur keuangan sendiri.

Manfaat aplikasi

Membantu memantau sisa uang bulanan secara real-time
Memberi peringatan dini saat pengeluaran mendekati batas
Membentuk kebiasaan mencatat transaksi harian

Daftar fitur inti

Input pemasukan bulanan & kategori pengeluaran (makan, transport, kos, lain-lain)
Dashboard sisa saldo & progress bar per kategori
Riwayat transaksi (list + filter tanggal/kategori)
Notifikasi/alert saat kategori mendekati limit
Laporan ringkas mingguan/bulanan (grafik sederhana)

Fitur yang tidak dikerjakan

Integrasi rekening bank/e-wallet otomatis
Multi-user/family sharing
Prediksi AI atau rekomendasi investasi
Scan struk otomatis (OCR)

Kriteria berhasil

User bisa mencatat transaksi dalam <10 detik
Dashboard menampilkan sisa saldo akurat sesuai input
Minimal 5 user uji coba menyatakan aplikasi membantu mereka sadar pola pengeluaran (via survei singkat)

## Status Implementasi

- **Pertemuan 3** — kerangka UI + routing (6 layar), widget reusable, tema terang/gelap,
  format mata uang `id_ID`.
- **Pertemuan 4** — state management (Provider), form, dan validasi untuk fitur
  Onboarding (Pengaturan Periode Anggaran) dan Tambah Transaksi, termasuk 6 kondisi
  UI (initial loading, data dimuat, empty state, error + retry, validasi input,
  loading saat submit) beserta widget test. Detail lihat
  [DOKUMENTASI_PERTEMUAN_4.md](./DOKUMENTASI_PERTEMUAN_4.md).

## Cara Menjalankan

```bash
flutter pub get
flutter test          # 29 test (widget + unit)
flutter run           # di emulator/perangkat Android
```

