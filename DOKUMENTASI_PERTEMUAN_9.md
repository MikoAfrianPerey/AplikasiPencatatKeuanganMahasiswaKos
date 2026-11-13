# Pertemuan 9 — Fitur Profil + Refactor Anti-Duplikasi

## Ringkasan

Dua pekerjaan digabung dalam pertemuan ini:

1. **Refactor anti-duplikasi** — memisahkan tanggung jawab menjadi fungsi/kode kecil
   yang fokus pada perannya (validasi, data, status UI, form) sehingga tidak ada
   penulisan ulang logika yang sama di banyak layar.
2. **Fitur Profil** — layar baru untuk mengubah nama, email, dan sandi, memakai
   pola pemisahan yang sama: `ProfileForm` (input + status UI), `validation`
   (aturan input), dan `profileRepository` (request/akses penyimpanan).

Semua diverifikasi dengan `flutter analyze` (0 error, 0 warning) dan
`flutter test` (55 test lolos).

## 1. Refactor anti-duplikasi

### Pemisahan tanggung jawab

| Peran | File baru | Isi |
|---|---|---|
| Validasi | `lib/inti/validasi/ProfilValidasi.dart` | aturan nama/email/sandi/sandi-baru |
| Validasi | `lib/inti/validasi/ValidasiAngka.dart` | aturan jumlah & batas angka |
| Data beranda | `lib/inti/utils/DataBeranda.dart` | muat transaksi+kategori, cari kategori, total saldo |
| Status UI | `lib/presentasi/widget/TampilanStatus.dart` | `TampilanStatus`, `IndikatorMemuat`, `TampilanGalat` |
| Form | `lib/presentasi/widget/KeypadAngka.dart` | keypad angka Tambah Transaksi |
| Form | `lib/presentasi/widget/KartuPeringatan.dart` | kartu error form |

### Duplikasi yang dihilangkan

| Sebelum | Sesudah |
|---|---|
| `_PemuatanDashboard` / `_PemuatanRiwayat` / `_PemuatanLaporan` (3 widget identik) | 1 `IndikatorMemuat` |
| Blok error + tombol "Coba Lagi" di Riwayat & Laporan | 1 `TampilanGalat` |
| `_cariKategori` / `_namaKategori` di Dashboard/Riwayat/Laporan | 1 `DataBeranda` |
| Validasi email/sandi/angka tertanam di provider | `ProfilValidasi` + `ValidasiAngka` |
| `e.toString()` di 5 blok catch | 1 `pesanException()` + `StatusData.dariError()` |

## 2. Fitur Profil

### Lapisan (sesuai pola ProfileForm / validation / profileRepository)

- **`profileRepository`** — `lib/data/repository/RepositoryProfil.dart` (kontrak) +
  `lib/data/repository/RepositoryProfilLokal.dart` (implementasi
  `SharedPreferences`): `ambilProfil`, `perbarui`, `ubahSandi`.
- **`validation`** — `ProfilValidasi.sandiBaru()` memvalidasi sandi lama/baru/
  konfirmasi; `nama()` dan `email()` dipakai ulang.
- **`ProfileForm`** — `lib/presentasi/widget/FormulirProfil.dart` (input nama/email +
  status loading/error + tombol simpan).
- **Layar** — `lib/presentasi/layar/profil/LayarProfil.dart`: kartu identitas,
  form profil, dan form ubah sandi.
- **Provider** — `lib/provider/ProviderProfil.dart`: memuat controller, validasi,
  `simpanProfil`, `ubahSandi`.

### Alur

1. Dari **Pengaturan** → "Kelola Profil" → layar Profil.
2. Ubah nama/email → "Simpan Profil" → status sukses → `ProviderAuth` ikut
   diperbarui → snackbar "Profil berhasil disimpan".
3. Ubah sandi → validasi sandi lama (cocok dengan hash tersimpan), sandi baru
   minimal 6 karakter dan beda dari lama, konfirmasi sama → "Ubah Sandi" →
   snackbar "Sandi berhasil diubah".

Penyimpanan tetap lokal (`shared_preferences` + hash SHA-256) konsisten dengan
autentikasi Pertemuan 7. Kunci penyimpanan kini disatukan di
`PenyimpananProfilLokal` agar `LayananAuth` dan `RepositoryProfilLokal` tidak
mendefinisikan ulang string kunci yang sama.

## Bukti verifikasi

| Bukti | Hasil |
|---|---|
| `flutter analyze` | 0 error, 0 warning (hanya info `file_names` sesuai DOK) |
| `flutter test` | 55 test lolos (50 lama + 5 profil) |
| Test profil | simpan valid, email invalid ditolak, sandi lama salah ditolak, ubah sandi sukses, konfirmasi beda ditolak |

## File yang berubah

**Baru:**
- `lib/data/repository/RepositoryProfil.dart`
- `lib/data/repository/RepositoryProfilLokal.dart`
- `lib/provider/ProviderProfil.dart`
- `lib/presentasi/layar/profil/LayarProfil.dart`
- `lib/presentasi/widget/FormulirProfil.dart`
- `lib/presentasi/widget/KeypadAngka.dart`
- `lib/presentasi/widget/KartuPeringatan.dart`
- `lib/presentasi/widget/TampilanStatus.dart`
- `lib/inti/validasi/ProfilValidasi.dart`
- `lib/inti/validasi/ValidasiAngka.dart`
- `lib/inti/utils/DataBeranda.dart`
- `test/provider/ProviderProfil_test.dart`

**Diubah:**
- `lib/layanan/LayananAuth.dart` (kunci/hash disatukan ke `PenyimpananProfilLokal`)
- `lib/provider/ProviderAuth.dart` (pakai `ProfilValidasi`, `perbaruiProfil`)
- `lib/provider/ProviderOnboarding.dart` (validasi angka terpisah)
- `lib/provider/ProviderTransaksi.dart` (validasi + simpan dipecah)
- `lib/app.dart`, `lib/inti/routing/RuteAplikasi.dart` (rute + provider profil)
- `lib/presentasi/layar/dashboard/LayarDashboard.dart`,
  `lib/presentasi/layar/transaksi/LayarRiwayatTransaksi.dart`,
  `lib/presentasi/layar/laporan/LayarLaporan.dart`,
  `lib/presentasi/layar/onboarding/LayarOnboarding.dart`,
  `lib/presentasi/layar/transaksi/LayarTambahTransaksi.dart`,
  `lib/presentasi/layar/pengaturan/LayarPengaturan.dart` (pakai widget/helper bersama)
