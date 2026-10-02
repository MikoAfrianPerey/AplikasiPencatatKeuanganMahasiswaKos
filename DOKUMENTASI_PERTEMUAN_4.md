# Dokumentasi Tugas Pertemuan 4 — State Management, Form, dan Validasi

Aplikasi: **DompetKos** (pencatat keuangan mahasiswa kos)
State management: **Provider** (sesuai DOK `architecture.md`)

## 1. Fitur yang Diimplementasikan

Dua fitur menerapkan state management, form, dan validasi secara nyata:

1. **Onboarding / Pengaturan Periode Anggaran** — memuat kategori dari repository,
   lalu pengguna mengisi total pemasukan bulanan dan batas pengeluaran per kategori.
2. **Tambah Transaksi** — memuat kategori, keypad angka, pemilih kategori dan tanggal,
   lalu menyimpan transaksi.

Kedua fitur memenuhi **enam kondisi UI** yang diminta tugas (lihat bagian 4).

## 2. Posisi Kode State Management

```text
lib/
├── app.dart                     ← dependency injection (MultiProvider)
├── inti/
│   └── state/
│       └── StatusData.dart      ← enum Status + pembungkus state generik
├── data/
│   ├── model/                   ← Kategori, PeriodeBudget, BudgetKategori, Transaksi
│   │                             (semua mengimplementasikan keMap/dariMap)
│   └── repository/              ← kontrak abstrak + implementasi mock
│       ├── RepositoryKategori.dart
│       ├── RepositoryPeriodeBudget.dart
│       └── RepositoryTransaksi.dart
├── provider/                    ← STATE MANAGEMENT (ChangeNotifier)
│   ├── ProviderOnboarding.dart  ← state fitur onboarding (6 kondisi UI)
│   ├── ProviderTransaksi.dart   ← state fitur tambah transaksi
│   └── ProviderPengaturan.dart  ← state pengaturan + toggle demo error
└── presentasi/
    └── layar/
        ├── onboarding/LayarOnboarding.dart       ← widget (hanya baca provider)
        ├── transaksi/LayarTambahTransaksi.dart   ← widget (hanya baca provider)
        └── pengaturan/LayarPengaturan.dart       ← kontrol demo state
```

Inti state management ada di tiga tempat:
- `lib/inti/state/StatusData.dart` — definisi kondisi state.
- `lib/provider/Provider*.dart` — pemegang state + logika (notifier).
- `lib/app.dart` — penyediaan (injection) provider ke seluruh aplikasi.

## 3. Proses State Management (Cara Kerjanya)

### StatusData — kondisi state yang seragam

```dart
enum Status { initial, loading, sukses, kosong, error }

class StatusData<T> {
  final Status status;
  final T? data;      // payload saat sukses
  final String? pesan; // pesan saat error
  ...
}
```

Setiap proses async (muat data, simpan data) direpresentasikan sebagai
`StatusData`. Widget tinggal membaca `status` untuk menentukan tampilan.

### Alur satu proses (contoh: muat kategori di Onboarding)

```text
LayarOnboarding (widget)
   │  didChangeDependencies → addPostFrameCallback
   ▼
ProviderOnboarding.muatKategori()
   │  1. _statusKategori = StatusData.loading()   → notifyListeners()
   │  2. await repository.ambilSemua()            (async, bisa gagal)
   ├── sukses & ada data  → StatusData.sukses(list) → siapkan controller form
   ├── sukses & kosong    → StatusData.kosong()
   └── gagal (Exception)  → StatusData.error(pesan)
   │
   ▼
Widget membaca status via context.watch<ProviderOnboarding>()
   → sedangLoading  : CircularProgressIndicator
   → adalahKosong   : StateKosong + tombol "Tambah Kategori Default"
   → adalahError    : pesan error + tombol "Coba Lagi"
   → adalahSukses   : form input
```

### Alur submit (contoh: simpan periode anggaran)

```text
Tombol "Mulai Kelola Uang" ditekan
   │
   ▼
ProviderOnboarding.simpanPeriode()
   │  1. validasi pemasukan & setiap batas (validasiPemasukan/validasiBatas)
   │  2. cek total batas ≤ total pemasukan  → jika lewat, tampilkan error inline
   │  3. _statusSimpan = StatusData.loading() → notifyListeners()
   │     (tombol ter-disable di UI → tidak bisa double tap)
   │  4. await repository.buatPeriode(...)
   ├── sukses → StatusData.sukses(periode)
   └── gagal  → StatusData.error(pesan)
   │
   ▼
Widget: jika sukses → Navigator.pushReplacementNamed(dashboard)
        jika error  → SnackBar pesan error
```

### Pemisahan tanggung jawab

| Layer | Tugas | Tidak boleh |
|-------|-------|-------------|
| **Widget** (`presentasi/layar/`) | membaca state via `context.watch`, menampilkan UI, validasi tampilan form | menyentuh repository, query database |
| **Provider** (`provider/`) | memegang state, validasi bisnis, memanggil repository, `notifyListeners()` | menyentuh SQLite langsung |
| **Repository** (`data/repository/`) | satu-satunya layer akses data (abstrak + implementasi) | tahu soal UI |

Widget **tidak pernah** memanggil repository langsung — selalu lewat provider,
sesuai aturan layer DOK.

## 4. Enam Kondisi UI dan Lokasinya

| # | Kondisi | Implementasi Onboarding | Implementasi Tambah Transaksi |
|---|---------|--------------------------|-------------------------------|
| 1 | **Initial loading** | `LayarOnboarding._bangunLoading` | `LayarTambahTransaksi._bangunLoading` |
| 2 | **Data berhasil dimuat** | `_bangunForm` (form pemasukan + batas) | `_bangunKonten` (keypad + chip kategori) |
| 3 | **Empty state** | `_bangunKosong` + tombol "Tambah Kategori Default" | `_bangunKosong` |
| 4 | **Error + retry** | `_bangunError` + tombol "Coba Lagi" | `_bangunError` + tombol "Coba Lagi" |
| 5 | **Validasi input** | `ProviderOnboarding.validasiPemasukan`, `validasiBatas`, cek total batas | `ProviderTransaksi.validasiJumlah`, cek kategori terpilih |
| 6 | **Loading saat submit** | `TombolUtama(sedangMemuat: true)` → tombol disabled + spinner | sama, keypad juga dinonaktifkan |

### Cara melihat keenam kondisi secara langsung

1. **Loading** — buka aplikasi (layar Onboarding menampilkan spinner ~0,7 detik).
2. **Data dimuat** — setelah loading selesai, form muncul (4 kategori default
   dibuat dengan tombol di empty state pada kondisi sebelumnya).
3. **Empty state** — layar **Pengaturan → bagian "Demo & Pengujian State" →
   "Reset Data Demo"**, lalu buka Onboarding: belum ada kategori.
4. **Error state** — layar **Pengaturan → aktifkan "Simulasikan Error Saat Memuat
   Kategori"**, lalu buka Onboarding: muncul pesan error + tombol "Coba Lagi".
   Nonaktifkan toggle lalu tekan "Coba Lagi" untuk melihat pemulihan.
5. **Validasi** — di Onboarding, tekan "Mulai Kelola Uang" dengan field kosong;
   atau isi pemasukan kecil lalu batas besar (lihat pesan melebihi pemasukan).
6. **Loading submit** — isi form valid lalu tekan "Mulai Kelola Uang": tombol
   berubah jadi spinner dan tidak bisa ditekan dua kali.

## 5. Widget Test

Semua state utama punya widget test (29 test, semuanya lolos):

```text
test/
├── pembantu/AplikasiTest.dart           ← helper: injection provider + ukuran layar
├── layar/
│   ├── LayarOnboarding_test.dart        ← 10 test (loading, empty, loaded, error,
│   │                                      retry, 3 validasi, loading submit, sukses)
│   └── LayarTambahTransaksi_test.dart   ← 7 test (loading, loaded, empty, error,
│                                          retry, validasi, loading submit)
└── provider/
    └── ProviderOnboarding_test.dart     ← 12 unit test validasi & transisi state
```

Menjalankan:

```bash
flutter test
```

## 6. Prompt AI yang Digunakan

Berikut prompt yang dipakai untuk membantu menyusun kode (hasil tetap ditinjau
dan disesuaikan manual):

1. *"Buatkan kerangka state management dengan Provider untuk fitur onboarding
   aplikasi Flutter, dengan 6 kondisi: initial loading, data loaded, empty state,
   error state dengan retry, validasi form, dan loading saat submit. Pisahkan
   widget, provider/notifier, dan repository."*
2. *"Buat widget test untuk setiap state utama pada layar onboarding dan tambah
   transaksi, menggunakan mock repository dengan jeda dan pemicu error."*
3. *"Tulis ulang kode ini tanpa komentar yang tidak perlu, dengan konvensi
   PascalCase untuk class, camelCase untuk variabel, dan label bahasa Indonesia."*
4. *"Review kode state management ini; periksa apakah ada kemungkinan bug,
   memory leak, atau double-tap pada saat submit."*

## 7. Bagian yang Diperiksa dan Diperbaiki Sendiri

Hasil AI ditinjau manual. Beberapa hal yang saya perbaiki/ubah sendiri:

- **Deadlock timer di widget test**: pemanggilan `await repository.buatDefault()`
  sebelum `pumpWidget` membuat test hang karena `Future.delayed` hanya berjalan
  saat fake clock maju. Saya tambahkan metode sinkron `isiKategoriDefault()`
  khusus setup test, dan mengganti `pumpAndSettle` dengan `pump(durasi)` yang
  deterministik.
- **`notifyListeners` saat fase build**: memuat data langsung di
  `didChangeDependencies` memicu assertion `!_dirty`. Saya pindahkan trigger
  ke `WidgetsBinding.instance.addPostFrameCallback`.
- **Validasi terpisah dari `GlobalKey`**: semula `simpanPeriode` memakai
  `kunciForm.currentState?.validate()` yang butuh binding; dipindahkan agar
  provider melakukan validasi sendiri sehingga bisa di-unit-test murni.
- **Batas 120 karakter & tanpa komentar**: menyesuaikan semua file dengan
  aturan DOK.
- **Pencegahan double tap**: `TombolUtama` menerima `sedangMemuat` yang
  meng-disable `onPressed` saat submit berlangsung; keypad juga dinonaktifkan.
- **Ukuran layar test**: test default 800×600 membuat tombol di luar viewport;
  ditambahkan `aturUkuranPonsel` di helper test.

## 8. Catatan Implementasi

- Repository memakai **implementasi mock** (in-memory dengan jeda simulasi)
  agar keenam state bisa didemokan dan diuji dengan stabil. Kontrak repository
  (`abstract class`) sudah didefinisikan sehingga implementasi SQLite
  (`sqflite`) cukup mengganti class implementasi di `app.dart` tanpa mengubah
  provider maupun widget — sesuai pola berlapis DOK.
- Model sudah mengimplementasikan `keMap`/`dariMap` dengan nama kolom
  `snake_case` siap untuk skema SQLite di pertemuan berikutnya.
- Penambahan toggle "Simulasikan Error" dan "Reset Data Demo" di layar
  Pengaturan adalah fitur bantu untuk **uji coba/demonstrasi state**;
  ini sengaja ditulis terbuka di UI agar reviewer bisa melihat error state
  dan empty state secara langsung.
