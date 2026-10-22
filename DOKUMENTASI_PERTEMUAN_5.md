# Dokumentasi Tugas Pertemuan 5 — Local Data & Persistence

Aplikasi: **DompetKos**
Storage: **SQLite** (`sqflite`) — sesuai pilihan "Flutter: SQLite"

Tugas ini lanjutan Pertemuan 4. Semua data dilekatkan ke database lokal SQLite di perangkat, sehingga data tidak hilang saat aplikasi ditutup.

## 1. Ringkasan pemenuhan kriteria

| Kriteria | Status | Bukti |
|---|---|---|
| Local Data — data disimpan lokal di device | ✅ | `lib/data/database/BantuanDatabase.dart` — file `dompet_kos.db` di `getApplicationDocumentsDirectory()` |
| Data Model — entity yang disimpan | ✅ | 4 tabel: `kategori`, `periode_budget`, `budget_kategori`, `transaksi` |
| CRUD — Create, Read, Update, Delete | ✅ | Repository SQLite + UI (tambah, lihat, edit, hapus) |
| Persistence Test — data bertahan setelah app ditutup | ✅ | `test/data/PersistensiSqlite_test.dart` (5 test) + demo restart di emulator |

## 2. Posisi Kode Local Data & Persistence

```text
lib/
├── data/
│   ├── database/
│   │   └── BantuanDatabase.dart            ← ★ INTI PERSISTENCE
│   │                                         singleton koneksi SQLite, buat tabel,
│   │                                         helper sisipkan/kueri/perbarui/hapus
│   ├── model/
│   │   ├── Kategori.dart                   ← Entity + keMap()/dariMap()
│   │   ├── PeriodeBudget.dart
│   │   ├── BudgetKategori.dart
│   │   └── Transaksi.dart
│   └── repository/
│       ├── RepositoryKategoriSqlite.dart   ← ★ CRUD kategori
│       ├── RepositoryPeriodeBudgetSqlite.dart
│       └── RepositoryTransaksiSqlite.dart  ← ★ CRUD transaksi (create/read/update/delete)
├── app.dart                                ← ★ DI: repository SQLite di-inject ke provider
└── presentasi/layar/transaksi/
    ├── LayarTambahTransaksi.dart           ← UI Create & Update (mode edit)
    └── LayarRiwayatTransaksi.dart          ← UI Read & Delete
```

**Titik masuk terpenting untuk reviewer:**
1. **Penyimpanan:** `lib/data/database/BantuanDatabase.dart`
2. **Skema tabel:** `BantuanDatabase._buatTabel()` (baris ~52–115)
3. **CRUD transaksi:** `lib/data/repository/RepositoryTransaksiSqlite.dart`
   - Create → `buat()` (baris ~30)
   - Read → `ambilSemua()`, `ambilBerdasarkanId()` (baris ~12, ~25)
   - Update → `perbarui()` (baris ~95)
   - Delete → `hapus()` (baris ~85)
4. **Wiring:** `lib/app.dart` baris ~27–40
5. **Test persistence:** `test/data/PersistensiSqlite_test.dart`

## 3. Data Model yang Disimpan

Model sudah penuh dari Pertemuan 4 — setiap model punya `keMap()` (untuk simpan) dan `dariMap()` (untuk baca). Nama kolom `snake_case` sesuai aturan DOK.

### Tabel `kategori`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | INTEGER PK AUTOINCREMENT | — |
| `nama` | TEXT NOT NULL | Contoh: Makan, Kos |
| `nama_ikon` | TEXT NOT NULL | Nama ikon (dipetakan oleh `PemetaIkon`) |
| `warna` | INTEGER NOT NULL | Nilai ARGB |
| `adalah_default` | INTEGER | 1 = kategori bawaan |
| `dibuat_pada` | TEXT NOT NULL | ISO-8601 |

### Tabel `periode_budget`
| Kolom | Tipe |
|---|---|
| `id`, `bulan_periode`, `tahun_periode`, `total_pemasukan` | INTEGER |
| `tanggal_mulai`, `tanggal_akhir`, `dibuat_pada` | TEXT |
| `aktif_sekarang` | INTEGER (1/0) |

### Tabel `budget_kategori`
| Kolom | Tipe |
|---|---|
| `id`, `id_periode_budget`, `id_kategori`, `jumlah_batas` | INTEGER |
| `persen_batas_peringatan` | REAL |
| `peringatan_sudah_dikirim` | INTEGER |
| `dibuat_pada` | TEXT |

### Tabel `transaksi` (entity utama CRUD)
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | INTEGER PK AUTOINCREMENT | — |
| `id_periode_budget` | INTEGER FK | → `periode_budget(id)` |
| `id_kategori` | INTEGER FK | → `kategori(id)` |
| `jenis_transaksi` | TEXT | `PEMASUKAN` / `PENGELUARAN` |
| `jumlah` | INTEGER | Rupiah, tanpa desimal |
| `catatan` | TEXT | Opsional |
| `tanggal_transaksi` | TEXT | ISO-8601 |
| `dibuat_pada` | TEXT | ISO-8601 |

Relasi dijaga dengan `PRAGMA foreign_keys = ON` pada `onConfigure`.

## 4. Alur Data (satu fitur vertikal: Tambah/Edit/Hapus Transaksi)

```text
UI (LayarTambahTransaksi / LayarRiwayatTransaksi)
      │  user action
      ▼
ProviderTransaksi (state management, validasi)
      │  simpanTransaksi() / perbarui / hapus
      ▼
RepositoryTransaksiSqlite  (implementasi CRUD)
      │  keMap() / dariMap()
      ▼
BantuanDatabase (SQLite file: dompet_kos.db)
```

### CREATE — tambah transaksi
1. Dashboard → tombol **Tambah Transaksi**
2. Isi jumlah via keypad, pilih kategori, tanggal, catatan
3. Tekan **Simpan Transaksi**
4. `ProviderTransaksi.simpanTransaksi()` → `RepositoryTransaksiSqlite.buat()`
5. `db.insert('transaksi', ...)` → data tersimpan di file SQLite

### READ — lihat transaksi
- Dashboard memuat `ambilSemua()` → ringkasan saldo + 5 transaksi terbaru
- Riwayat (`LayarRiwayatTransaksi`) memuat semua transaksi, dikelompokkan per tanggal, bisa difilter per kategori

### UPDATE — edit transaksi
1. Riwayat → **ketuk salah satu transaksi**
2. Layar terbuka dalam mode **Edit Transaksi** (form sudah terisi data lama)
3. Ubah jumlah/kategori/catatan/jenis → **Simpan Perubahan**
4. `ProviderTransaksi.simpanTransaksi()` mendeteksi `modeEdit` → `perbarui(id, ...)`
5. `db.update('transaksi', data, where: 'id = ?')`

### DELETE — hapus transaksi
1. Riwayat → **geser kartu ke kiri**
2. Konfirmasi dialog → **Hapus**
3. `RepositoryTransaksiSqlite.hapus(id)` → `db.delete(...)`

## 5. Persistence Test

File: `test/data/PersistensiSqlite_test.dart`

Test memakai SQLite FFI di memory-disk (file sementara nyata) agar bisa mensimulasikan "aplikasi ditutup lalu dibuka".

| Test | Yang diuji |
|---|---|
| `CREATE` | Data tersimpan dan file `.db` benar-benar terbentuk |
| `READ` | `ambilBerdasarkanId` mengembalikan data yang benar; id tidak ada → `null` |
| `UPDATE` | Perubahan jumlah/catatan/jenis persisten |
| `DELETE` | Data hilang dari DB |
| `PERSISTENSI` | **DB ditutup → dibuka ulang → semua data (transaksi, periode, kategori) masih ada** |

Jalankan:

```bash
flutter test test/data/PersistensiSqlite_test.dart
```

Contoh kunci pada test persistence:

```dart
await db.tutup();                              // tutup koneksi (simulasi app exit)
final dbBaru = BantuanDatabase(customPath: jalurDb);
final semua = await RepositoryTransaksiSqlite(dbBaru).ambilSemua();
expect(semua.length, 2);                       // data masih ada
```

## 6. Demo Persistence di Perangkat

1. Jalankan aplikasi → isi periode anggaran → tambah beberapa transaksi.
2. Tutup aplikasi sepenuhnya (bukan minimize): **Home → swipe app dari recent apps**, atau `adb shell am force-stop com.example.dompet_kos`.
3. Buka aplikasi lagi.
4. Dashboard menampilkan transaksi dan saldo yang sama seperti sebelum ditutup.
5. Coba **edit** salah satu transaksi → tutup/buka lagi → perubahan tetap ada.
6. Coba **hapus** satu transaksi → tutup/buka lagi → transaksi tetap terhapus.

Perintah bantu demo:

```bash
adb shell am force-stop com.example.dompet_kos
adb shell am start -n com.example.dompet_kos/.MainActivity
```

Untuk melihat file database di emulator:

```bash
adb shell run-as com.example.dompet_kos ls -l app_flutter/
```

## 7. Catatan Implementasi

- **Lokasi database:** `getApplicationDocumentsDirectory()/dompet_kos.db`. `BantuanDatabase` adalah singleton sehingga koneksi dibuka sekali dan dipakai bersama semua repository.
- **`customPath`:** parameter opsional saat membuat `BantuanDatabase` — dipakai test untuk menunjuk file DB sementara.
- **Repository abstrak tetap ada:** `RepositoryKategori`, `RepositoryPeriodeBudget`, `RepositoryTransaksi` adalah kontrak; implementasi SQLite (`*Sqlite.dart`) di-inject di `app.dart`. Implementasi mock (dari Pertemuan 4) tetap disimpan untuk test UI yang tidak butuh database.
- **Kategori default** dibuat sekali saat pertama kali (`buatDefault()`); jika tabel sudah berisi, tidak diulang.
- **`perbarui` parsial:** hanya kolom yang diberikan yang di-update (`if (jumlah != null) data['jumlah'] = jumlah;`).
- **Reset data** di Pengaturan menghapus isi tabel `kategori`.

## 8. Test & Build

```bash
flutter test                     # 34 test (29 UI/unit + 5 persistence)
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## 9. Prompt AI yang Digunakan

1. *"Buatkan helper database SQLite untuk Flutter: singleton, onCreate dengan tabel snake_case, dan helper CRUD generik (sisipkan/kueri/perbarui/hapus)."*
2. *"Implementasikan repository SQLite untuk tabel transaksi dengan operasi buat, ambil semua, ambil berdasarkan id, perbarui parsial, dan hapus."*
3. *"Buat test persistence untuk Dart/Flutter yang membuka file SQLite sementara, menulis data, menutup koneksi, membuka ulang, dan memastikan data masih ada. Gunakan sqflite_common_ffi."*
4. *"Tambahkan mode edit pada layar tambah transaksi yang menerima objek Transaksi sebagai argumen rute."*

## 10. Bagian yang Diperiksa dan Diperbaiki Sendiri

- Menyesuaikan `BantuanDatabase` ke **proyek mobile-only**: menghapus `kIsWeb` dan `sqflite_common_ffi_web` karena platform web sudah dulu dihapus dari proyek.
- Menambahkan `ambilBerdasarkanId` ke kontrak `RepositoryTransaksi` (dan mock-nya) agar UPDATE bisa mengembalikan data terbaru setelah `perbarui`.
- Menambahkan metode `muatUntukEdit` di `ProviderTransaksi` — mengisi form dari data lama **setelah** kategori selesai dimuat, sehingga chip kategori yang benar ikut terpilih.
- Menambahkan `idTransaksiDiedit` supaya satu layar bisa dipakai untuk create dan update tanpa duplikasi UI.
- Mengganti alur tambah-transaksi agar memanggil `provider.reset()` dulu; jika tidak, state sisa edit bisa terbawa ke sesi tambah baru.
