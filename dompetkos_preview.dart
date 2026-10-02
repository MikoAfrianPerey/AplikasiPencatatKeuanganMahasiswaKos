// DompetKos - Prototype UI lengkap untuk Flutter online run (DartPad / zapp).
// Nol dependency eksternal: grafik pakai CustomPaint, format rupiah manual.
// Tempel seluruh isi file ini ke https://dartpad.dev lalu tekan Run.

import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const AplikasiDompetKos());

class AplikasiDompetKos extends StatelessWidget {
  const AplikasiDompetKos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DompetKos',
      debugShowCheckedModeBanner: false,
      theme: Tema.terang,
      darkTheme: Tema.gelap,
      themeMode: ThemeMode.system,
      initialRoute: Rute.onboarding,
      routes: {
        Rute.onboarding: (_) => const LayarOnboarding(),
        Rute.dashboard: (_) => const LayarDashboard(),
        Rute.tambahTransaksi: (_) => const LayarTambahTransaksi(),
        Rute.riwayatTransaksi: (_) => const LayarRiwayatTransaksi(),
        Rute.laporan: (_) => const LayarLaporan(),
        Rute.pengaturan: (_) => const LayarPengaturan(),
      },
    );
  }
}

class Rute {
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const tambahTransaksi = '/tambah-transaksi';
  static const riwayatTransaksi = '/riwayat-transaksi';
  static const laporan = '/laporan';
  static const pengaturan = '/pengaturan';
}

class Tema {
  static const benih = Color(0xFF0D9488);

  static ThemeData get terang => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: benih, brightness: Brightness.light),
      );

  static ThemeData get gelap => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: benih, brightness: Brightness.dark),
      );
}

String formatRupiah(int jumlah) {
  final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
  final angka = jumlah.abs().toString().replaceAllMapped(reg, (_) => '.');
  return 'Rp $angka';
}

String formatTanggal(DateTime t) {
  const bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  return '${t.day} ${bulan[t.month - 1]} ${t.year}';
}

Color warnaBatas(double persen) {
  if (persen < 60) return Colors.green;
  if (persen <= 85) return Colors.orange;
  return Colors.red;
}

class TombolUtama extends StatelessWidget {
  final String label;
  final IconData? ikon;
  final VoidCallback? saatDitekan;

  const TombolUtama({super.key, required this.label, this.ikon, this.saatDitekan});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: saatDitekan,
      icon: Icon(ikon ?? Icons.check),
      label: Text(label),
    );
  }
}

class BidangTeks extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? petunjuk;
  final IconData? ikon;
  final TextInputType jenisInput;
  final String? Function(String?)? validator;

  const BidangTeks({
    super.key,
    required this.label,
    this.controller,
    this.petunjuk,
    this.ikon,
    this.jenisInput = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: jenisInput,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: petunjuk,
        prefixIcon: ikon != null ? Icon(ikon) : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class KartuSaldo extends StatelessWidget {
  final int sisaSaldo;
  final int totalPemasukan;
  final int totalPengeluaran;
  final int sisaHari;

  const KartuSaldo({
    super.key,
    required this.sisaSaldo,
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.sisaHari,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;
    final persen = totalPemasukan == 0 ? 0.0 : (totalPengeluaran / totalPemasukan) * 100;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sisa Saldo Bulan Ini',
              style: tema.textTheme.titleSmall?.copyWith(color: warna.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatRupiah(sisaSaldo),
                style: tema.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: warna.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (persen / 100).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: warna.surfaceContainerHighest,
                color: warnaBatas(persen),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoRingkas(judul: 'Pemasukan', nilai: formatRupiah(totalPemasukan), warna: Colors.green),
                _InfoRingkas(judul: 'Pengeluaran', nilai: formatRupiah(totalPengeluaran), warna: Colors.red),
                _InfoRingkas(judul: 'Sisa Hari', nilai: '$sisaHari hari', warna: warna.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRingkas extends StatelessWidget {
  final String judul;
  final String nilai;
  final Color warna;

  const _InfoRingkas({required this.judul, required this.nilai, required this.warna});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(judul, style: tema.textTheme.labelSmall?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            nilai,
            style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: warna),
          ),
        ),
      ],
    );
  }
}

class ItemKategori extends StatelessWidget {
  final String nama;
  final int batas;
  final int terpakai;

  const ItemKategori({super.key, required this.nama, required this.batas, required this.terpakai});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final persen = batas == 0 ? 0.0 : (terpakai / batas) * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(nama, style: tema.textTheme.titleSmall),
              Text(
                '${persen.toStringAsFixed(0)}%',
                style: tema.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: warnaBatas(persen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (persen / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: tema.colorScheme.surfaceContainerHighest,
              color: warnaBatas(persen),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${formatRupiah(terpakai)} dari ${formatRupiah(batas)}',
            style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class ItemTransaksi extends StatelessWidget {
  final IconData ikon;
  final Color warnaIkon;
  final String kategori;
  final String catatan;
  final String tanggal;
  final String jumlah;
  final bool adalahPemasukan;

  const ItemTransaksi({
    super.key,
    required this.ikon,
    required this.warnaIkon,
    required this.kategori,
    required this.catatan,
    required this.tanggal,
    required this.jumlah,
    required this.adalahPemasukan,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: warnaIkon.withOpacity(0.15),
        child: Icon(ikon, color: warnaIkon),
      ),
      title: Text(kategori, style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(
        catatan.isEmpty ? tanggal : '$tanggal - $catatan',
        style: tema.textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${adalahPemasukan ? '+' : '-'} $jumlah',
        style: tema.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: adalahPemasukan ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

class StateKosong extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String pesan;

  const StateKosong({super.key, required this.ikon, required this.judul, required this.pesan});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ikon, size: 80, color: tema.colorScheme.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(judul, style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            pesan,
            style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class LayarOnboarding extends StatefulWidget {
  const LayarOnboarding({super.key});

  @override
  State<LayarOnboarding> createState() => _KeadaanLayarOnboarding();
}

class _KeadaanLayarOnboarding extends State<LayarOnboarding> {
  final _kunciForm = GlobalKey<FormState>();
  final _controllerPemasukan = TextEditingController();
  bool _izinNotifikasi = false;

  @override
  void dispose() {
    _controllerPemasukan.dispose();
    super.dispose();
  }

  String? _validasi(String? nilai) {
    if (nilai == null || nilai.isEmpty) return 'Total pemasukan tidak boleh kosong';
    final jumlah = int.tryParse(nilai.replaceAll(RegExp(r'[^0-9]'), ''));
    if (jumlah == null || jumlah <= 0) return 'Masukkan jumlah yang valid';
    return null;
  }

  void _mulai() {
    if (_kunciForm.currentState?.validate() != true) return;
    Navigator.pushReplacementNamed(context, Rute.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _kunciForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Icon(Icons.account_balance_wallet, size: 88, color: tema.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Selamat Datang di DompetKos',
                  style: tema.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Catat pemasukan bulananmu untuk mulai mengendalikan uang kos.',
                  style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                BidangTeks(
                  label: 'Total Pemasukan Bulanan',
                  petunjuk: 'Contoh: 1500000',
                  ikon: Icons.attach_money,
                  jenisInput: TextInputType.number,
                  controller: _controllerPemasukan,
                  validator: _validasi,
                ),
                const SizedBox(height: 8),
                Text(
                  'Format: ${formatRupiah(1500000)} per bulan',
                  style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                Card(
                  child: SwitchListTile(
                    title: const Text('Izinkan Notifikasi'),
                    subtitle: const Text(
                      'Dapatkan peringatan saat kategori mendekati batas dan pengingat harian pukul 21:00.',
                    ),
                    value: _izinNotifikasi,
                    onChanged: (v) => setState(() => _izinNotifikasi = v),
                  ),
                ),
                const SizedBox(height: 32),
                TombolUtama(label: 'Mulai Kelola Uang', ikon: Icons.arrow_forward, saatDitekan: _mulai),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LayarDashboard extends StatelessWidget {
  const LayarDashboard({super.key});

  void _ke(String rute, BuildContext context) => Navigator.pushNamed(context, rute);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DompetKos'),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), tooltip: 'Laporan', onPressed: () => _ke(Rute.laporan, context)),
          IconButton(icon: const Icon(Icons.settings), tooltip: 'Pengaturan', onPressed: () => _ke(Rute.pengaturan, context)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const KartuSaldo(
            sisaSaldo: 807000,
            totalPemasukan: 1500000,
            totalPengeluaran: 693000,
            sisaHari: 29,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Batas Kategori', style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => _ke(Rute.pengaturan, context), child: const Text('Atur Batas')),
            ],
          ),
          const Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ItemKategori(nama: 'Makan', batas: 600000, terpakai: 420000),
                  ItemKategori(nama: 'Kos', batas: 500000, terpakai: 500000),
                  ItemKategori(nama: 'Transport', batas: 200000, terpakai: 90000),
                  ItemKategori(nama: 'Lain-lain', batas: 200000, terpakai: 60000),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transaksi Terbaru', style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => _ke(Rute.riwayatTransaksi, context), child: const Text('Lihat Semua')),
            ],
          ),
          const Card(
            child: Column(
              children: [
                ItemTransaksi(
                  ikon: Icons.restaurant,
                  warnaIkon: Colors.orange,
                  kategori: 'Makan',
                  catatan: 'Nasi goreng malam',
                  tanggal: '2 Okt 2026',
                  jumlah: 'Rp 25.000',
                  adalahPemasukan: false,
                ),
                ItemTransaksi(
                  ikon: Icons.directions_bus,
                  warnaIkon: Colors.blue,
                  kategori: 'Transport',
                  catatan: 'Gojek ke kampus',
                  tanggal: '2 Okt 2026',
                  jumlah: 'Rp 18.000',
                  adalahPemasukan: false,
                ),
                ItemTransaksi(
                  ikon: Icons.home,
                  warnaIkon: Colors.green,
                  kategori: 'Kos',
                  catatan: 'Bayar kos bulanan',
                  tanggal: '1 Okt 2026',
                  jumlah: 'Rp 500.000',
                  adalahPemasukan: false,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
        onPressed: () => _ke(Rute.tambahTransaksi, context),
      ),
    );
  }
}

class LayarTambahTransaksi extends StatefulWidget {
  const LayarTambahTransaksi({super.key});

  @override
  State<LayarTambahTransaksi> createState() => _KeadaanLayarTambahTransaksi();
}

class _KeadaanLayarTambahTransaksi extends State<LayarTambahTransaksi> {
  bool _adalahPemasukan = false;
  String _jumlah = '0';
  String _kategoriTerpilih = 'Makan';
  DateTime _tanggal = DateTime(2026, 10, 2);
  final _controllerCatatan = TextEditingController();

  static const _kategori = [
    {'nama': 'Makan', 'ikon': Icons.restaurant, 'warna': Colors.orange},
    {'nama': 'Kos', 'ikon': Icons.home, 'warna': Colors.green},
    {'nama': 'Transport', 'ikon': Icons.directions_bus, 'warna': Colors.blue},
    {'nama': 'Lain-lain', 'ikon': Icons.category, 'warna': Colors.purple},
  ];

  static const _tombol = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '000', '0', '⌫'];

  @override
  void dispose() {
    _controllerCatatan.dispose();
    super.dispose();
  }

  void _ketik(String nilai) {
    setState(() {
      if (_jumlah == '0' && nilai != '000') {
        _jumlah = nilai;
      } else if (_jumlah != '0') {
        _jumlah += nilai;
      }
    });
  }

  void _hapus() {
    setState(() {
      _jumlah = _jumlah.length > 1 ? _jumlah.substring(0, _jumlah.length - 1) : '0';
    });
  }

  void _reset() {
    setState(() {
      _jumlah = '0';
      _kategoriTerpilih = 'Makan';
      _tanggal = DateTime(2026, 10, 2);
      _controllerCatatan.clear();
    });
  }

  Future<void> _pilihTanggal() async {
    final dipilih = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (dipilih != null) setState(() => _tanggal = dipilih);
  }

  void _simpan() {
    final jumlah = int.tryParse(_jumlah) ?? 0;
    if (jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah yang valid')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaksi ${_adalahPemasukan ? 'pemasukan' : 'pengeluaran'} '
          '$_kategoriTerpilih berhasil disimpan',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final jumlah = int.tryParse(_jumlah) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _reset)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Pengeluaran')),
                ButtonSegment(value: true, label: Text('Pemasukan')),
              ],
              selected: {_adalahPemasukan},
              onSelectionChanged: (p) => setState(() => _adalahPemasukan = p.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              formatRupiah(jumlah),
              style: tema.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _adalahPemasukan ? Colors.green : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _kategori.length,
              itemBuilder: (context, index) {
                final item = _kategori[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(item['nama'] as String),
                    avatar: Icon(item['ikon'] as IconData, color: item['warna'] as Color),
                    selected: item['nama'] == _kategoriTerpilih,
                    onSelected: (_) => setState(() => _kategoriTerpilih = item['nama'] as String),
                  ),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Tanggal Transaksi'),
            subtitle: Text(formatTanggal(_tanggal)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pilihTanggal,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controllerCatatan,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
          ),
          const Spacer(),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.6,
            ),
            itemCount: _tombol.length,
            itemBuilder: (context, index) {
              final tombol = _tombol[index];
              final hapus = tombol == '⌫';
              return Padding(
                padding: const EdgeInsets.all(4),
                child: FilledButton(
                  onPressed: hapus ? _hapus : () => _ketik(tombol),
                  style: FilledButton.styleFrom(
                    backgroundColor: hapus
                        ? tema.colorScheme.errorContainer
                        : tema.colorScheme.surfaceContainerHighest,
                    foregroundColor: hapus ? tema.colorScheme.onErrorContainer : tema.colorScheme.onSurface,
                  ),
                  child: Text(
                    tombol,
                    style: tema.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TombolUtama(label: 'Simpan Transaksi', ikon: Icons.save, saatDitekan: _simpan),
          ),
        ],
      ),
    );
  }
}

class LayarRiwayatTransaksi extends StatefulWidget {
  const LayarRiwayatTransaksi({super.key});

  @override
  State<LayarRiwayatTransaksi> createState() => _KeadaanLayarRiwayatTransaksi();
}

class _KeadaanLayarRiwayatTransaksi extends State<LayarRiwayatTransaksi> {
  String _filter = 'Semua';

  static const _transaksi = [
    {'kategori': 'Makan', 'catatan': 'Nasi goreng malam', 'tanggal': '2 Okt 2026', 'jumlah': 25000, 'ikon': Icons.restaurant, 'warna': Colors.orange, 'masuk': false},
    {'kategori': 'Transport', 'catatan': 'Gojek ke kampus', 'tanggal': '2 Okt 2026', 'jumlah': 18000, 'ikon': Icons.directions_bus, 'warna': Colors.blue, 'masuk': false},
    {'kategori': 'Kos', 'catatan': 'Bayar kos bulanan', 'tanggal': '1 Okt 2026', 'jumlah': 500000, 'ikon': Icons.home, 'warna': Colors.green, 'masuk': false},
    {'kategori': 'Pemasukan', 'catatan': 'Uang bulanan dari ortu', 'tanggal': '1 Okt 2026', 'jumlah': 1500000, 'ikon': Icons.account_balance_wallet, 'warna': Colors.teal, 'masuk': true},
    {'kategori': 'Lain-lain', 'catatan': 'Voucher game', 'tanggal': '30 Sep 2026', 'jumlah': 50000, 'ikon': Icons.category, 'warna': Colors.purple, 'masuk': false},
  ];

  static const _filterTersedia = ['Semua', 'Makan', 'Kos', 'Transport', 'Lain-lain'];

  List<Map<String, dynamic>> get _hasil {
    if (_filter == 'Semua') return _transaksi;
    return _transaksi.where((t) => t['kategori'] == _filter).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _kelompok {
    final hasil = <String, List<Map<String, dynamic>>>{};
    for (final item in _hasil) {
      hasil.putIfAbsent(item['tanggal'] as String, () => []).add(item);
    }
    return hasil;
  }

  Future<bool?> _konfirmasi(String kategori, int jumlah) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: Text('Transaksi $kategori sebesar ${formatRupiah(jumlah)} akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final kelompok = _kelompok;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filterTersedia.length,
              itemBuilder: (context, index) {
                final f = _filterTersedia[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: f == _filter,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: kelompok.isEmpty
                ? const StateKosong(
                    ikon: Icons.receipt_long,
                    judul: 'Belum Ada Transaksi',
                    pesan: 'Transaksi pada kategori ini belum ada. Coba pilih kategori lain.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: kelompok.length,
                    itemBuilder: (context, index) {
                      final tanggal = kelompok.keys.elementAt(index);
                      final daftar = kelompok[tanggal]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              tanggal,
                              style: tema.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tema.colorScheme.primary,
                              ),
                            ),
                          ),
                          Card(
                            child: Column(
                              children: daftar.map((item) {
                                final masuk = item['masuk'] as bool;
                                return Dismissible(
                                  key: ValueKey('${item['kategori']}${item['jumlah']}$tanggal${item['catatan']}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 16),
                                    color: Colors.red,
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  confirmDismiss: (_) => _konfirmasi(item['kategori'] as String, item['jumlah'] as int),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: (item['warna'] as Color).withOpacity(0.15),
                                      child: Icon(item['ikon'] as IconData, color: item['warna'] as Color),
                                    ),
                                    title: Text(item['kategori'] as String),
                                    subtitle: Text(item['catatan'] as String),
                                    trailing: Text(
                                      '${masuk ? '+' : '-'} ${formatRupiah(item['jumlah'] as int)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: masuk ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Iris {
  final String nama;
  final int nilai;
  final Color warna;

  const _Iris({required this.nama, required this.nilai, required this.warna});
}

class _PelukisPie extends CustomPainter {
  final List<_Iris> iris;

  _PelukisPie(this.iris);

  @override
  void paint(Canvas canvas, Size size) {
    final total = iris.fold<double>(0, (a, e) => a + e.nilai);
    if (total <= 0) return;
    final pusat = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    var mulai = -pi / 2;
    for (final item in iris) {
      final sapuan = 2 * pi * (item.nilai / total);
      canvas.drawArc(
        Rect.fromCircle(center: pusat, radius: radius),
        mulai,
        sapuan,
        true,
        Paint()..color = item.warna,
      );
      mulai += sapuan;
    }
    canvas.drawCircle(pusat, radius * 0.42, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _PelukisPie other) => other.iris != iris;
}

class LayarLaporan extends StatelessWidget {
  const LayarLaporan({super.key});

  static const _iris = [
    _Iris(nama: 'Kos', nilai: 500000, warna: Colors.green),
    _Iris(nama: 'Makan', nilai: 420000, warna: Colors.orange),
    _Iris(nama: 'Transport', nilai: 90000, warna: Colors.blue),
    _Iris(nama: 'Lain-lain', nilai: 60000, warna: Colors.purple),
  ];

  static const _harian = [25000, 18000, 500000, 0, 42000, 31000, 27000];
  static const _labelHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  int get _total => _iris.fold(0, (a, e) => a + e.nilai);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan'),
          bottom: const TabBar(tabs: [Tab(text: 'Mingguan'), Tab(text: 'Bulanan')]),
        ),
        body: TabBarView(
          children: [
            _bangunTab('Mingguan', tema),
            _bangunTab('Bulanan', tema),
          ],
        ),
      ),
    );
  }

  Widget _bangunTab(String jenis, ThemeData tema) {
    final nilaiMax = _harian.reduce(max);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pengeluaran $jenis',
                  style: tema.textTheme.titleSmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(_total),
                  style: tema.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Komposisi Pengeluaran per Kategori', style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: CustomPaint(painter: _PelukisPie(_iris), child: const SizedBox.expand()),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: _iris.map((item) {
              final persen = (item.nilai / _total) * 100;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: item.warna.withOpacity(0.15),
                  child: Icon(Icons.circle, color: item.warna, size: 12),
                ),
                title: Text(item.nama),
                trailing: Text(
                  '${formatRupiah(item.nilai)} (${persen.toStringAsFixed(0)}%)',
                  style: tema.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        Text('Pengeluaran Harian', style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: LayoutBuilder(
            builder: (context, constraint) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_harian.length, (i) {
                  final tinggi = (_harian[i] / nilaiMax) * (constraint.maxHeight - 24);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: tinggi,
                            decoration: BoxDecoration(
                              color: tema.colorScheme.primary,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(_labelHari[i], style: tema.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text('Kategori Pengeluaran Terbesar', style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.home, color: Colors.white)),
            title: const Text('Kos'),
            subtitle: const Text('Pengeluaran terbesar bulan ini'),
            trailing: Text(
              formatRupiah(500000),
              style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class LayarPengaturan extends StatefulWidget {
  const LayarPengaturan({super.key});

  @override
  State<LayarPengaturan> createState() => _KeadaanLayarPengaturan();
}

class _KeadaanLayarPengaturan extends State<LayarPengaturan> {
  double _ambang = 80;
  bool _pengingatHarian = true;
  bool _temaGelap = false;

  Future<bool?> _konfirmasiReset() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Semua Data?'),
        content: const Text(
          'Seluruh transaksi, kategori, dan periode anggaran akan dihapus permanen. '
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }

  void _resetData() async {
    final ok = await _konfirmasiReset();
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data berhasil direset')),
      );
    }
  }

  Widget _bagianHeader(String judul, ThemeData tema) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        judul,
        style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: tema.colorScheme.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          _bagianHeader('Periode Anggaran', tema),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Periode Aktif'),
                  subtitle: const Text('Oktober 2026'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Total Pemasukan'),
                  subtitle: const Text('Rp 1.500.000'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          _bagianHeader('Batas Kategori', tema),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.orange),
                  title: const Text('Makan'),
                  subtitle: const Text('Batas: Rp 600.000'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.green),
                  title: const Text('Kos'),
                  subtitle: const Text('Batas: Rp 500.000'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.directions_bus, color: Colors.blue),
                  title: const Text('Transport'),
                  subtitle: const Text('Batas: Rp 200.000'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.category, color: Colors.purple),
                  title: const Text('Lain-lain'),
                  subtitle: const Text('Batas: Rp 200.000'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          _bagianHeader('Notifikasi', tema),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Ambang Batas Peringatan'),
                  subtitle: Slider(
                    value: _ambang,
                    min: 50,
                    max: 100,
                    divisions: 10,
                    label: '${_ambang.toInt()}%',
                    onChanged: (v) => setState(() => _ambang = v),
                  ),
                  trailing: Text('${_ambang.toInt()}%'),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.alarm),
                  title: const Text('Pengingat Harian'),
                  subtitle: const Text('Pengingat catat transaksi pukul 21:00'),
                  value: _pengingatHarian,
                  onChanged: (v) => setState(() => _pengingatHarian = v),
                ),
              ],
            ),
          ),
          _bagianHeader('Tampilan', tema),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Tema Gelap'),
              subtitle: const Text('Ikuti pengaturan sistem'),
              value: _temaGelap,
              onChanged: (v) => setState(() => _temaGelap = v),
            ),
          ),
          _bagianHeader('Kategori', tema),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Kelola Kategori'),
              subtitle: const Text('Tambah, edit, atau nonaktifkan kategori'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          _bagianHeader('Data', tema),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Reset Semua Data'),
              subtitle: const Text('Hapus seluruh data aplikasi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _resetData,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
