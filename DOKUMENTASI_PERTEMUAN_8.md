# Pertemuan 8 — Layout Adaptif, Keyboard-Safe, Accessibility, Feedback Aksi

## Ringkasan

Empat peningkatan UX diterapkan pada MVP DompetKos. Semua perubahan sudah dijalankan
di emulator Android (API 37) dan diverifikasi lewat `uiautomator dump`, screenshot, dan
50 unit/widget test.

## 1. Layout adaptif (layar besar / layar kecil)

**Helper:** `lib/inti/utils/TataLetak.dart`

- Ambang lebar: `720` dp. Di bawahnya → layout satu kolom (HP).
- Di atasnya → konten dibatasi maksimal `900` dp dan dipusatkan, sehingga teks tidak
  melebar berlebihan di tablet/desktop.
- `TataLetak.pusatkan(context, child)` dipakai di: Dashboard, Laporan, Pengaturan,
  Onboarding, Tambah Transaksi.

**Adaptasi khusus di Dashboard** (`LayarDashboard.dart`):

- Layar kecil: daftar transaksi terbaru dalam satu `Card` + `Column`.
- Layar lebar: transaksi terbaru ditata dua kolom memakai `Wrap` + `Card` per item.

**Keypad Tambah Transaksi** (`LayarTambahTransaksi.dart`):

- Layar kecil: 4 kolom. Layar lebar: 6 kolom.
- Tombol hapus (`⌫`) dipindah ke kolom keempat baris pertama agar susunan angka
  tetap berurutan 7 8 9 / 4 5 6 / 1 2 3.

## 2. Keyboard-safe UI

- `LayarTambahTransaksi`: `SingleChildScrollView` diberi
  `padding.bottom = MediaQuery.viewInsetsOf(context).bottom`, sehingga isi form dapat
  digulir melewati keyboard.
- `LayarOnboarding`: padding bawah form ikut menyesuaikan tinggi keyboard.
- `LayarMasuk` sudah memakai `ListView` di dalam `SafeArea` — aman terhadap keyboard.

**Verifikasi emulator:** tap field `Catatan (opsional)` → keyboard muncul
(`mInputShown=true`), viewport menyusut dari 2400 px ke ±1495 px, field tetap terlihat
penuh di `[42,746][1038,893]` (screenshot `p8_03_keyboard.png`). Pada Onboarding field
yang difokuskan otomatis digulir ke atas keyboard.

## 3. Accessibility dasar

- **`ItemTransaksi`**: dibungkus `Semantics` + `ExcludeSemantics` dengan label
  `Transaksi pengeluaran <kategori> sebesar <jumlah>, <tanggal>` — pembaca layar
  membacanya sebagai satu kesatuan, bukan potongan teks.
- **`KartuSaldo`**: `LinearProgressIndicator` diberi label
  `Pemakaian anggaran <n> persen`.
- **`StateKosong`**: satu label gabungan `judul. pesan`.
- **Input loading**: semua layar pemuatan memakai `Semantics(liveRegion: true)` +
  teks status, contoh "Memuat data transaksi...", "Menghitung laporan...".
- **Tombol ikon** sudah memiliki `tooltip` (`Pengaturan`, `Tambah transaksi baru`,
  `Hapus lokasi`) sehingga terbaca sebagai label aksesibilitas.
- Karena itu `uiautomator dump` menampilkan seluruh konten sebagai `content-desc`
  (bukti label aksesibilitas terpasang benar).

## 4. Feedback aksi

**Helper:** `lib/inti/utils/UmpanBalik.dart` — `sukses()`, `info()`, `galat()` dengan
ikon+snackbar 3 detik, dan `hideCurrentSnackBar()` agar tidak menumpuk.

| Aksi | Sebelum | Sesudah |
|---|---|---|
| Simpan transaksi | layar tertutup diam-diam | snackbar "Transaksi berhasil disimpan" di Dashboard |
| Edit transaksi | tanpa konfirmasi | snackbar "Transaksi berhasil diperbarui" |
| Hapus transaksi | ada snackbar, tanpa error handler | snackbar sukses / gagal eksplisit |
| Ambil lokasi | spinner tanpa teks | info "Mengambil lokasi perangkat..." → sukses/gagal |
| Simpan periode Onboarding | snackbar hanya saat gagal | snackbar galat dengan ikon |
| Reset data demo | snackbar polos | snackbar sukses |
| Izin notifikasi | tanpa umpan balik | "Izin notifikasi diberikan" / pesan tolak + arahan |
| Kirim notifikasi uji | tanpa umpan balik | info "Mengirim..." lalu "Notifikasi uji terkirim. Cek panel notifikasi." |
| Memuat Dashboard/Riwayat/Laporan | spinner telanjang | spinner + teks + liveRegion |

## Bukti verifikasi

| Bukti | Hasil |
|---|---|
| `flutter analyze` | 0 error, 0 warning baru (hanya info `file_names` sesuai DOK) |
| `flutter test` | 50 test lolos |
| Keypad susunan | `7 8 9 ⌫ / 4 5 6 000 / 1 2 3 0` |
| Snackbar simpan | `Transaksi berhasil disimpan` tampil, saldo berubah Rp 9.175.000 → Rp 8.170.000 |
| Snackbar notifikasi uji | `Notifikasi uji terkirim. Cek panel notifikasi.` |
| Layout lebar 900 dp | konten 1736 px terpusat, transaksi 2 kolom |
| Sesi terdahulu | 50 test, build APK debug sukses |

## Screenshot (`dokumentasi/`)

1. `p8_01_layout_lebar.png` — Dashboard pada layar lebar: konten terpusat, transaksi 2 kolom.
2. `p8_02_tambah_transaksi_lebar.png` — Tambah Transaksi layar lebar: keypad 6 kolom, form terpusat.
3. `p8_03_keyboard.png` — Catatan terfokus, keyboard aktif, field tetap terlihat.
4. `p8_04_pengaturan.png` — Pengaturan dengan section, slider berlabel, snackbar umpan balik.

## File yang berubah

- Baru: `lib/inti/utils/TataLetak.dart`, `lib/inti/utils/UmpanBalik.dart`
- Dashboard, Laporan, Pengaturan, Onboarding, Tambah Transaksi, Riwayat Transaksi,
  `StateKosong`, `KartuSaldo`, `ItemTransaksi`
- `test/provider/RingkasanBatas_test.dart` (hapus kelas fixture tak terpakai)
