# Dokumentasi Pertemuan 6 — Integrasi API & Vertical Slice

Fitur vertikal: **Transaksi** — UI → Provider → repository HTTP → REST API → file JSON backend.

## Kriteria reviewer

- Koneksi API nyata: `RepositoryTransaksiApi` memakai `dart:io HttpClient`; backend REST di `server/api.dart` menerima GET/POST/PUT/DELETE dan menyimpan data di `server/data/transaksi.json`.
- UI terhubung: `LayarRiwayatTransaksi` memuat daftar dari API; `ProviderTransaksi` menyimpan/mengubah transaksi lewat repository; aksi hapus juga memakai API.
- UI state: loading, empty, error dengan tombol **Coba Lagi**, success (daftar transaksi).
- Unit test: `test/data/api_transaksi_test.dart`, 7 tes.

## Posisi kode

| Bagian | File |
|---|---|
| Backend REST + penyimpanan JSON | `server/api.dart` |
| Model + validasi JSON | `lib/data/model/Transaksi.dart` (`dariMap`, `keMap`) |
| HTTP client / repository | `lib/data/repository/RepositoryTransaksiApi.dart` |
| Wiring base URL | `lib/app.dart` (`API_BASE_URL`) |
| UI loading/empty/error/retry | `lib/presentasi/layar/transaksi/LayarRiwayatTransaksi.dart` |
| Panggilan create/update | `lib/provider/ProviderTransaksi.dart` |
| 7 unit test | `test/data/api_transaksi_test.dart` |

## Jalankan demo lokal

1. Jalankan backend dari root proyek:

   ```bash
   dart run server/api.dart
   ```

   Backend listen pada port `8080`; file awal dibuat otomatis di `server/data/transaksi.json`.

2. Jalankan aplikasi Android emulator (host emulator dipetakan sebagai `10.0.2.2`):

   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
   ```

   Default `API_BASE_URL` di app juga `http://10.0.2.2:8080`. Untuk device fisik, set ke IP LAN komputer yang menjalankan server, contoh `http://192.168.1.10:8080`.

3. Buat periode/kategori bila onboarding memintanya; tambah transaksi. UI mengirim POST ke backend.
4. Buka Riwayat: GET memuat daftar transaksi. Ketuk item untuk edit (PUT), geser untuk hapus (DELETE).
5. Stop lalu start backend lagi. Data JSON tetap ada; refresh Riwayat untuk membaca ulang.
6. Matikan server untuk melihat error state; tekan **Coba Lagi** setelah server hidup kembali.

Catatan Android: `android/app/src/main/AndroidManifest.xml` memiliki permission INTERNET dan cleartext HTTP untuk backend development lokal. Jangan gunakan cleartext atau server ini untuk deployment produksi.

## Endpoint

| Method | URL | Fungsi |
|---|---|---|
| GET | `/transaksi` | Daftar transaksi |
| GET | `/transaksi?id=7` | Ambil satu transaksi |
| POST | `/transaksi` | Simpan transaksi, server membuat ID |
| PUT | `/transaksi?id=7` | Update parsial |
| DELETE | `/transaksi?id=7` | Hapus transaksi |

## Unit test

Jalankan:

```bash
flutter test test/data/api_transaksi_test.dart
```

| Test | Hasil yang diharapkan |
|---|---|
| Model valid | JSON valid menjadi entity `Transaksi` |
| Model invalid | Nominal bukan integer ditolak (`FormatException`) |
| API sukses | GET sukses mengembalikan data |
| API simpan | POST mengirim data dan menerima entity hasil server |
| Data kosong | GET `[]` menghasilkan daftar kosong |
| HTTP gagal | Status 503 melempar `HttpException` |
| JSON rusak | Body JSON tidak valid melempar `FormatException` |

Test menggunakan `HttpServer` loopback sementara; tidak perlu internet atau backend berjalan.
