# Pertemuan 10 — Release Candidate: Logging Runtime, APK, dan Issues

## Ringkasan

Menyiapkan aplikasi menuju rilis. Tiga deliverable dikerjakan:

1. **Logging runtime** — sistem log untuk membantu tracing masalah saat aplikasi
   berjalan.
2. **APK release** — hasil build siap pasang.
3. **Issues GitHub** — 12 isu (6 bug + 6 fitur) dicatat sebagai backlog.

> Catatan: bug yang tercatat di issues **belum diperbaiki** pada pertemuan ini.
> Isu dibuat untuk melacak masalah yang akan dikerjakan pada iterasi berikutnya.

## 1. Logging runtime

**Helper:** `lib/inti/utils/LogAplikasi.dart`

- Empat level: `debug`, `info`, `peringatan`, `error`.
- Ditulis lewat `dart:developer` (`developer.log`) sehingga muncul di `logcat`
  (Android) dengan tag `DompetKos`, plus `debugPrint` saat mode debug.
- Tanpa dependency baru — memakai API bawaan Flutter/Dart.

**Titik log yang dipasang:**

| Lokasi | Yang dicatat |
|---|---|
| `RepositoryTransaksiApi` | method + path + query setiap request HTTP, dan kegagalan non-2xx |
| `ProviderAuth` | kegagalan daftar/masuk |
| `ProviderOnboarding` | gagal muat kategori, gagal simpan periode |
| `ProviderProfil` | gagal simpan profil, gagal ubah sandi |
| `ProviderTransaksi` | gagal muat kategori, gagal simpan transaksi |

Setiap blok `catch` yang sebelumnya diam kini menulis log error + `StackTrace`,
sehingga masalah saat runtime mudah dilacak.

## 2. APK release

- Perintah: `flutter build apk --release`.
- Hasil: `build/app/outputs/flutter-apk/app-release.apk` (54.8 MB).
- Disalin ke `dist/DompetKos-v1.0.0-release.apk` untuk kemudahan serah-terima.

> `dist/` dan `build/` tidak masuk version control (`/build/` di `.gitignore`).

## 3. Issues GitHub (backlog)

Dibuat 12 issues lewat GitHub CLI (`gh issue create`).

**Bug (6):**

| # | Judul |
|---|---|
| 1 | Saldo dashboard tidak sinkron setelah hapus/edit dari Riwayat |
| 2 | Kelola Kategori di Pengaturan tidak berfungsi |
| 3 | Notifikasi ambang batas pakai 100% bukan persen yang diatur |
| 4 | Reset data demo tidak menghapus transaksi backend lokal |
| 5 | Keypad tombol `000` bisa menghasilkan jumlah tidak konsisten |
| 6 | Pesan error ubah sandi muncul ganda (kartu + snackbar) |

**Fitur (6):**

| # | Judul |
|---|---|
| 7 | Manajemen kategori penuh (tambah/edit/nonaktifkan) |
| 8 | Filter riwayat transaksi berdasarkan rentang tanggal |
| 9 | Tutup periode dan mulai periode baru |
| 10 | Atur waktu pengingat harian (bukan fixed 21:00) |
| 11 | Ekspor laporan ke CSV |
| 12 | Backup & restore data lokal |

Seluruh isu berstatus **open** dan menjadi rencana kerja iterasi selanjutnya.

## Bukti verifikasi

| Bukti | Hasil |
|---|---|
| `flutter analyze` | 0 error, 0 warning (hanya info `file_names` sesuai DOK) |
| `flutter test` | 55 test lolos |
| Log runtime | `[INFO] API GET /transaksi`, `[INFO] API POST /transaksi` tampil di output test |
| APK release | `app-release.apk` 54.8 MB terbangun tanpa error |
| Issues | 12 isu (#1–#12) terbuat di GitHub |

## File yang berubah

**Baru:**
- `lib/inti/utils/LogAplikasi.dart`

**Diubah:**
- `lib/data/repository/RepositoryTransaksiApi.dart` (log request HTTP)
- `lib/provider/ProviderAuth.dart`
- `lib/provider/ProviderOnboarding.dart`
- `lib/provider/ProviderProfil.dart`
- `lib/provider/ProviderTransaksi.dart`

## Status bug

Belum ada perbaikan bug pada pertemuan ini. Keenam bug (#1–#6) tetap terbuka dan
akan ditangani pada pertemuan berikutnya.
