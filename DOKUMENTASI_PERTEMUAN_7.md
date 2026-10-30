# Pertemuan 7 — MVP Lengkap & Tiga Fitur Lanjutan

Dokumen ini menutup tugas Pertemuan 7: seluruh alur utama DompetKos dapat
didemonstrasikan, ditambah tiga *advanced feature* yang terintegrasi penuh.

## 1. Status MVP

| Komponen inti | Status | Bukti |
| --- | --- | --- |
| Navigasi | Selesai | `lib/inti/routing/RuteAplikasi.dart` (8 rute, termasuk gerbang & masuk) |
| Form + validasi | Selesai | `LayarTambahTransaksi`, `LayarMasuk`, `LayarOnboarding`, `LayarPengaturan` |
| Penyimpanan data | Selesai | SQLite (`BantuanDatabase` v2) untuk kategori/periode; REST untuk transaksi |
| Loading / empty / error | Selesai | Dasbor, Riwayat, Laporan, Form, Pengaturan (retry + pesan) |
| Penanganan izin / pembatalan | Selesai | Notifikasi & lokasi punya cabang izin ditolak, diblokir permanen, gagal |

Celah yang ditutup pada pertemuan ini:

- `LayarLaporan` tidak lagi memakai data hardcoded; membaca transaksi &
  kategori sungguhan, dengan state loading, empty, error, dan tombol
  **Coba Lagi**.
- Kartu batas kategori di `LayarPengaturan` tidak lagi hardcoded; membaca
  `periode_budget` + `budget_kategori` dari SQLite.
- Ringkasan "Total batas … dari …" di onboarding sekarang ikut berubah saat
  field diisi (listener controller).
- Deep link onboarding dari Pengaturan untuk mengubah periode anggaran.

## 2. Fitur lanjutan #1 — Autentikasi (login lokal)

**Posisi kode**

- `lib/layanan/LayananAuth.dart` — daftar, masuk, keluar, sesi.
- `lib/provider/ProviderAuth.dart` — state, validasi email/sandi/nama.
- `lib/presentasi/layar/auth/LayarGerbang.dart` — cek sesi saat aplikasi dibuka.
- `lib/presentasi/layar/auth/LayarMasuk.dart` — form masuk/daftar.
- `lib/app.dart` — menyuntikkan `LayananAuth` + `ProviderAuth`.
- `lib/presentasi/layar/pengaturan/LayarPengaturan.dart` — kartu akun & tombol Keluar.

**Cara kerja**

1. Aplikasi dibuka → `LayarGerbang` memanggil `periksaSesi()`.
2. Belum masuk → `/masuk`; sudah masuk → `/dashboard`.
3. Sandi di-hash SHA-256 sebelum disimpan ke `shared_preferences`
   (sandi asli tidak pernah ditulis).
4. Keluar hanya menandai sesi tidak aktif; data transaksi tetap tersimpan.

**Manfaat bagi pengguna:** data keuangan mahasiswa tidak terbuka begitu
ponsel dipinjam teman sekamar; pengguna tahu akun mana yang sedang aktif
lewat kartu profil di Pengaturan.

## 3. Fitur lanjutan #2 — Notifikasi lokal

**Posisi kode**

- `lib/layanan/LayananNotifikasi.dart` — kanal `dompet_kos_default`,
  pengingat harian 21:00 (`zonedSchedule`), peringatan batas (`show`).
- `lib/provider/ProviderPengaturan.dart` — izin, toggle, kirim uji.
- `lib/provider/ProviderTransaksi.dart` — `_cekBatasKategori()`.
- `android/app/src/main/AndroidManifest.xml` — izin `POST_NOTIFICATIONS`,
  `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED` + dua receiver
  `flutter_local_notifications`.

**Cara kerja**

1. `LayarPengaturan` memanggil `periksaIzinNotifikasi()` → dialog izin Android.
2. Ditolak → kartu menampilkan "Belum diizinkan" + tombol **Izinkan**,
   toggle pengingat tidak aktif.
3. Diizinkan → toggle pengingat harian menjadwalkan notifikasi 21:00 tiap hari.
4. Setiap transaksi pengeluaran disimpan, `ProviderTransaksi` membandingkan
   total kategori dengan `budget_kategori`; bila terlampaui, notifikasi
   peringatan dikirim. Kegagalan notifikasi tidak menggagalkan penyimpanan.

**Manfaat bagi pengguna:** pengingat mencatat mengurangi pengeluaran
yang lupa dicatat, dan peringatan batas mencegah kategori jebol tanpa sadar.

## 4. Fitur lanjutan #3 — Lokasi transaksi

**Posisi kode**

- `lib/layanan/LayananLokasi.dart` — izin, service check, ambil posisi,
  fallback lokasi terakhir, pesan pembatalan.
- `lib/presentasi/layar/transaksi/LayarTambahTransaksi.dart` — `ListTile`
  "Lokasi Transaksi" + snackbar + tombol **Pengaturan**.
- `lib/data/model/Transaksi.dart` — properti `lokasi`.
- `lib/data/database/BantuanDatabase.dart` — kolom `lokasi` (migrasi v1→v2).
- `server/api.dart` — memvalidasi & menyimpan `lokasi`.

**Cara kerja**

1. Pengguna menekan "Lokasi Transaksi" → `Geolocator.checkPermission()`.
2. GPS mati → pesan "Nyalakan GPS lalu coba lagi".
3. Izin ditolak → pesan "Transaksi tetap bisa disimpan tanpa lokasi" +
   tombol ke Pengaturan Android.
4. Izin diblokir permanen → instruksi membuka Pengaturan Android.
5. Berhasil → koordinat ditampilkan dan ikut tersimpan saat transaksi disimpan.
6. Timeout 25 detik → memakai `getLastKnownPosition()`; bila tetap kosong,
   pengguna diberi pesan dan transaksi tetap bisa disimpan.

**Manfaat bagi pengguna:** mahasiswa bisa mengingat di mana pengeluaran
terjadi (kantin, minimarket, laundry) tanpa mengetik manual.

## 5. Verifikasi

- `flutter test` → **50 test lolos** (41 lama + 9 baru:
  `test/layanan/Auth_test.dart`, `test/data/LokasiTransaksi_test.dart`,
  `test/provider/RingkasanBatas_test.dart`).
- `flutter analyze` → 0 error.
- Uji manual di emulator Medium_Phone_API_37:

| Skenario | Hasil |
| --- | --- |
| Aplikasi baru dibuka | Layar Masuk tampil |
| Daftar akun (Miko / miko@kampus.ac.id) | Masuk ke dashboard, nama tampil di Pengaturan |
| Buka Pengaturan | Dialog izin notifikasi muncul |
| Kirim Notifikasi Uji | `dumpsys notification` menunjukkan `pkg=com.example.dompet_kos id=2 importance=4` |
| Tekan "Lokasi Transaksi" | Dialog izin lokasi muncul |
| Tolak izin | Snackbar "Izin lokasi ditolak…" + tombol Pengaturan |
| Izinkan | Koordinat terisi (`37.42200, -122.08400`) |
| Simpan transaksi tanpa jumlah | Validasi "Jumlah transaksi harus lebih besar dari 0" |
| `POST /transaksi` dengan `lokasi` | 201 + transaksi tersimpan |
| Dashboard & Laporan setelah simpan | Menampilkan Rp 15.000 "Makan siang", laporan total Rp 15.000 |

Screenshot: `dokumentasi/p7_dashboard.png`, `dokumentasi/p7_pengaturan.png`.

## 6. Cara menjalankan

```bash
dart run server/api.dart        # backend lokal, port 8080
flutter run                     # emulator memakai 10.0.2.2:8080
flutter test
```

Izin yang diminta aplikasi: `POST_NOTIFICATIONS`, `ACCESS_FINE_LOCATION`,
`ACCESS_COARSE_LOCATION`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`,
`INTERNET`.
