import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/model/Kategori.dart';
import '../../../inti/utils/PemetaIkon.dart';
import '../../../inti/utils/PemformatMataUang.dart';
import '../../../inti/utils/PemformatTanggal.dart';
import '../../../provider/ProviderTransaksi.dart';
import '../../widget/StateKosong.dart';
import '../../widget/TombolUtama.dart';

class LayarTambahTransaksi extends StatefulWidget {
  const LayarTambahTransaksi({super.key});

  @override
  State<LayarTambahTransaksi> createState() => _KeadaanLayarTambahTransaksi();
}

class _KeadaanLayarTambahTransaksi extends State<LayarTambahTransaksi> {
  bool _sudahMuat = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_sudahMuat) {
      _sudahMuat = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProviderTransaksi>().muatKategori();
      });
    }
  }

  Future<void> _pilihTanggal(ProviderTransaksi provider) async {
    final dipilih = await showDatePicker(
      context: context,
      initialDate: provider.tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (dipilih != null) provider.setTanggal(dipilih);
  }

  Future<void> _simpan(ProviderTransaksi provider) async {
    await provider.simpanTransaksi();
    if (!mounted) return;
    final status = provider.statusSimpan;
    if (status.adalahSukses) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaksi ${provider.adalahPemasukan ? 'pemasukan' : 'pengeluaran'} '
            '${provider.kategoriTerpilih?.nama ?? ''} berhasil disimpan',
          ),
        ),
      );
    } else if (status.adalahError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status.pesan ?? 'Gagal menyimpan transaksi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderTransaksi>();
    final status = provider.statusKategori;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.reset(),
          ),
        ],
      ),
      body: SafeArea(
        child: status.sedangLoading
            ? _bangunLoading(context)
            : status.adalahKosong
                ? _bangunKosong(provider)
                : status.adalahError
                    ? _bangunError(provider)
                    : _bangunKonten(context, provider),
      ),
    );
  }

  Widget _bangunLoading(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Memuat kategori...',
            style: tema.textTheme.bodyLarge?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bangunKosong(ProviderTransaksi provider) {
    return Center(
      child: StateKosong(
        ikon: Icons.category_outlined,
        judul: 'Belum Ada Kategori',
        pesan: 'Tambahkan kategori terlebih dahulu pada layar Onboarding '
            'sebelum mencatat transaksi.',
      ),
    );
  }

  Widget _bangunError(ProviderTransaksi provider) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 80,
              color: tema.colorScheme.error.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Kategori',
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Terjadi kesalahan saat memuat data. Coba lagi beberapa saat.',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TombolUtama(
              label: 'Coba Lagi',
              ikon: Icons.refresh,
              saatDitekan: () => provider.muatKategori(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bangunKonten(BuildContext context, ProviderTransaksi provider) {
    final tema = Theme.of(context);
    final daftar = provider.kategori ?? <Kategori>[];
    final sedangMenyimpan = provider.statusSimpan.sedangLoading;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Pengeluaran')),
                      ButtonSegment(value: true, label: Text('Pemasukan')),
                    ],
                    selected: {provider.adalahPemasukan},
                    onSelectionChanged: (pilihan) =>
                        provider.setJenis(pilihan.first),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    PemformatMataUang.format(int.tryParse(provider.jumlah) ?? 0),
                    style: tema.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: provider.adalahPemasukan
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
                if (provider.errorForm != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tema.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: tema.colorScheme.onErrorContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorForm!,
                              style: TextStyle(
                                color: tema.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: daftar.length,
                    itemBuilder: (context, index) {
                      final item = daftar[index];
                      final terpilih =
                          provider.kategoriTerpilih?.id == item.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(item.nama),
                          avatar: Icon(
                            PemetaIkon.dariNama(item.namaIkon),
                            color: Color(item.nilaiWarna),
                          ),
                          selected: terpilih,
                          onSelected: (_) => provider.setKategori(item),
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Tanggal Transaksi'),
                  subtitle: Text(PemformatTanggal.formatPanjang(provider.tanggal)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pilihTanggal(provider),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: provider.controllerCatatan,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TombolUtama(
                    label: 'Simpan Transaksi',
                    ikon: Icons.save,
                    sedangMemuat: sedangMenyimpan,
                    saatDitekan:
                        sedangMenyimpan ? null : () => _simpan(provider),
                  ),
                ),
              ],
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.6,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final tombol = _tombolKeypad(index);
            final adalahHapus = tombol == '⌫';
            return Padding(
              padding: const EdgeInsets.all(4),
              child: FilledButton(
                onPressed: sedangMenyimpan
                    ? null
                    : adalahHapus
                        ? () => provider.hapus()
                        : () => provider.ketik(tombol),
                style: FilledButton.styleFrom(
                  backgroundColor: adalahHapus
                      ? tema.colorScheme.errorContainer
                      : tema.colorScheme.surfaceContainerHighest,
                  foregroundColor: adalahHapus
                      ? tema.colorScheme.onErrorContainer
                      : tema.colorScheme.onSurface,
                ),
                child: Text(
                  tombol,
                  style: tema.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _tombolKeypad(int index) {
    const tombol = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '000', '0', '⌫'];
    return tombol[index];
  }
}
