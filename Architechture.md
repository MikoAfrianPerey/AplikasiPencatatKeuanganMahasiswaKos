# Arsitektur.md

Bangun aplikasi mobile offline-first yang sederhana bernama **DompetKos**.

Tujuan:
Membantu mahasiswa penghuni kos/kontrakan mengendalikan uang bulanan mereka. Aplikasi mencatat pemasukan dan pengeluaran harian, melacak saldo tersisa per kategori pengeluaran, dan mengirim notifikasi lokal saat kategori mendekati batasnya. Semua data disimpan di perangkat. Tidak perlu koneksi internet dan tidak ada server.

Gunakan stack teknologi ini:

* Platform: Android (mobile)
* Framework: Flutter + Dart
* Database lokal: SQLite via `sqflite`
* State management: Provider
* Notifikasi lokal: `flutter_local_notifications`
* Format tanggal dan mata uang: `intl`
* Grafik: `fl_chart`
* Pola arsitektur: Berlapis (Presentasi, Provider, Repository, Data)

Aturan kode:

* Jangan tambahkan komentar kecuali sangat perlu.
* Gunakan PascalCase untuk semua class, model, enum, dan nama Widget.
* Gunakan camelCase untuk variabel lokal, nama fungsi, dan properti model.
* Gunakan snake_case untuk nama file dan kolom SQLite.
* Usahakan baris kode tidak lebih dari 120 karakter.
* Jangan tambahkan autentikasi di versi pertama ini. Asumsikan satu mahasiswa menggunakan satu perangkat.
* Jangan hardcode nama kategori di dalam Widget. Selalu ambil dari database.

Entitas utama:

1. PeriodeBudget

   * Id
   * BulanPeriode
   * TahunPeriode
   * TotalPemasukan
   * TanggalMulai
   * TanggalAkhir
   * AktifSekarang
   * DibuatPada

2. Kategori

   * Id
   * Nama
   * NamaIkon
   * WarnaSekskademik
   * AdalahalanDefault
   * DibuatPada

3. BudgetKategori

   * Id
   * IdPeriodeBudget
   * IdKategori
   * JumlahBatas
   * PersenBatasPeringatan
   * PeringatanSudahDikirim
   * DibuatPada

4. Transaksi

   * Id
   * IdPeriodeBudget
   * IdKategori
   * JenisTranaksi
   * Jumlah
   * Catatan
   * TanggalTransaksi
   * DibuatPada

Aturan database:

* Hanya satu PeriodeBudget yang boleh memiliki `AktifSekarang = true` pada saat bersamaan.
* Sebuah BudgetKategori harus unik menurut `IdPeriodeBudget` dan `IdKategori`.
* Menghapus Kategori diblokir jika masih dirujuk oleh Transaksi mana pun. Tawarkan deaktivasi sebagai gantinya.
* Menghapus Transaksi tidak boleh mengubah data historis periode lain.
* `Jumlah` disimpan sebagai integer dalam rupiah. Jangan gunakan floating point untuk uang.
* `JenisTranaksi` adalah `PEMASUKAN` atau `PENGELUARAN`.
* Atur ulang `PeringatanSudahDikirim` menjadi false kapan pun `JumlahBatas` diubah atau periode baru dimulai.
* Siapkan empat kategori default saat peluncuran pertama: Makan, Kos, Transport, Lain-lain.

Fitur aplikasi:

1. Pengaturan Periode Anggaran

   * Buat periode bulanan dengan total pemasukan.
   * Tentukan batas pengeluaran per kategori.
   * Validasi bahwa jumlah semua batas kategori tidak melebihi total pemasukan.
   * Tutup periode saat ini dan mulai yang baru.

2. Pencatatan Transaksi

   * Tambahkan pengeluaran dengan jumlah, kategori, tanggal, dan catatan opsional.
   * Tambahkan pemasukan tambahan selama periode aktif.
   * Edit dan hapus transaksi.
   * Default tanggal ke hari ini sehingga pencatatan membutuhkan ketukan sesedikit mungkin.

3. Manajemen Kategori

   * Daftar, buat, edit, dan nonaktifkan kategori.
   * Pilih ikon dan warna untuk setiap kategori.

4. Dashboard

   * Tampilkan saldo tersisa periode aktif.
   * Tampilkan total pengeluaran versus total pemasukan.
   * Tampilkan progress bar per kategori dengan persentase terpakai.
   * Tampilkan lima transaksi paling terbaru.
   * Tampilkan sisa hari dalam periode saat ini.

5. Notifikasi Lokal (fitur perangkat native)

   * Minta izin notifikasi saat peluncuran pertama.
   * Setelah transaksi disimpan, hitung ulang total kategori.
   * Jika pengeluaran mencapai `PersenBatasPeringatan` (default 80 persen) dan `PeringatanSudahDikirim` adalah false, kirim notifikasi lokal dan atur `PeringatanSudahDikirim` menjadi true.
   * Kirim notifikasi terpisah saat batas kategori terlampaui.
   * Jadwalkan pengingat harian pada pukul 21:00 untuk mencatat pengeluaran hari ini.
   * Semua penjadwalan notifikasi berjalan di perangkat. Jangan gunakan Firebase atau layanan push lain mana pun.

6. Laporan

   * Ringkasan pengeluaran mingguan dan bulanan.
   * Grafik pie komposisi pengeluaran per kategori.
   * Grafik batang pengeluaran harian dalam periode.
   * Filter riwayat transaksi menurut rentang tanggal dan kategori.

Layar:

1. Onboarding

   * Ditampilkan hanya saat peluncuran pertama.
   * Input total pemasukan bulanan dan batas kategori.
   * Minta izin notifikasi.

2. Dashboard

   * Kartu saldo tersisa.
   * Daftar progress bar per kategori.
   * Daftar transaksi terbaru.
   * Tombol floating action untuk menambah transaksi.

3. TambahTransaksi

   * Keypad angka numerik.
   * Pemilih kategori.
   * Pemilih tanggal default ke hari ini.
   * Bidang catatan opsional.

4. RiwayatTransaksi

   * Daftar transaksi dikelompokkan menurut tanggal.
   * Filter menurut kategori dan rentang tanggal.
   * Geser untuk menghapus dengan dialog konfirmasi.

5. Laporan

   * Tab mingguan dan bulanan.
   * Grafik pie dan grafik batang.
   * Ringkasan kategori pengeluaran terbesar.

6. Pengaturan

   * Edit batas kategori.
   * Kelola kategori.
   * Atur ambang batas notifikasi dan waktu pengingat harian.
   * Atur ulang semua data dengan dialog konfirmasi.

Persyaratan UI:

* Gunakan bahasa Indonesia untuk semua label, tombol, pesan, dan validasi.
* Format mata uang sebagai `Rp 1.500.000` menggunakan `intl` dengan lokal `id_ID`.
* Gunakan komponen Material 3.
* Dukung tema terang dan gelap mengikuti pengaturan sistem.
* Gunakan warna progress bar menurut persentase penggunaan:

  * Di bawah 60 persen: hijau
  * 60 hingga 85 persen: oranye
  * Di atas 85 persen: merah
* Sediakan ilustrasi state kosong dan pesan untuk setiap daftar.
* Tampilkan dialog konfirmasi sebelum tindakan penghapusan apa pun.

Kontrak Repository:

* `RepositoryPeriodeBudget`: AmbilPeriodeAktif, BuatPeriode, TutupPeriode, AmbilRiwayatPeriode
* `RepositoryKategori`: AmbilSemua, AmbilAktif, Buat, Perbarui, Nonaktifkan
* `RepositoryBudgetKategori`: AmbilBerdasarkanPeriode, TetapkanBatas, PerbauruiBatas, UlangiFlagPeringatan
* `RepositoryTransaksi`: AmbilBerdasarkanPeriode, AmbilBerdasarkanRentangTanggal, AmbilBerdasarkanKategori, Buat, Perbarui, Hapus
* `RepositoryLaporan`: AmbilRingkasanKategori, AmbilRingkasanHarian, AmbilTotalPeriode
* `LayananNotifikasi`: MintaIzin, TampilkanPeringatanBatas, JadwalkanPengingatHarian, BatalkanSemua

Kontrak Provider:

* `ProviderBudget`: menyimpan periode aktif, batas kategori, dan saldo tersisa.
* `ProviderTransaksi`: menyimpan daftar transaksi dan menangani buat, perbarui, dan hapus.
* `ProviderLaporan`: menyimpan data grafik teragregasi.
* `ProviderPengaturan`: menyimpan tema, ambang batas, dan waktu pengingat.
* Setiap Provider memanggil Repository. Widget tidak boleh pernah query SQLite secara langsung.

Struktur proyek:

```text
dompet_kos/
  lib/
    main.dart
    inti/
      konstanta/
      tema/
      utils/
    data/
      database/
        BantuanDatabase.dart
        migrasi/
      model/
        PeriodeBudget.dart
        Kategori.dart
        BudgetKategori.dart
        Transaksi.dart
      repository/
    layanan/
      LayananNotifikasi.dart
    provider/
    presentasi/
      layar/
        onboarding/
        dashboard/
        transaksi/
        laporan/
        pengaturan/
      widget/
  test/
  android/
  pubspec.yaml
```

Aturan layer:

* `presentasi` hanya boleh bergantung pada `provider` dan `inti`.
* `provider` hanya boleh bergantung pada `data/repository` dan `layanan`.
* `data/repository` adalah satu-satunya layer yang diizinkan menyentuh `BantuanDatabase`.
* Model di `data/model` harus mengimplementasikan `KeMap` dan `DariMap` untuk serialisasi SQLite.
* Perhitungan bisnis seperti saldo tersisa dan persentase terpakai berada di layer Repository atau Provider, tidak pernah di dalam Widget.

Di luar cakupan untuk versi ini:

* Integrasi bank atau e-wallet
* Pemindaian struk dengan OCR
* Sinkronisasi cloud, server backend, atau login multi-perangkat
* Multi-pengguna atau anggaran bersama
* Tujuan tabungan dan fitur investasi
* Pembangunan iOS

Deliverable:

* Kode sumber Flutter lengkap mengikuti struktur di atas.
* Skema SQLite dengan jalur migrasi dan penyiapan kategori default.
* APK rilis yang berfungsi.
* README dengan petunjuk pembangunan, daftar ketergantungan, dan tangkapan layar.
* Dokumen pengujian singkat yang mencantumkan skenario pengujian dan hasilnya.

Kriteria keberhasilan:

* Mencatat satu pengeluaran membutuhkan waktu 10 detik atau kurang dari membuka aplikasi.
* Saldo tersisa di dashboard selalu cocok dengan jumlah transaksi yang disimpan.
* Notifikasi lokal muncul dengan benar saat kategori mencapai ambang batasnya.
* Semua data bertahan setelah aplikasi ditutup dan dibuka kembali.
* Aplikasi berjalan tanpa crash di perangkat Android fisik.