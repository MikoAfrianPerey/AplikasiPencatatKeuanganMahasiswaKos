import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/model/Kategori.dart';
import '../../../inti/routing/RuteAplikasi.dart';
import '../../../inti/utils/PemetaIkon.dart';
import '../../../inti/utils/PemformatMataUang.dart';
import '../../../provider/ProviderOnboarding.dart';
import '../../widget/BidangTeks.dart';
import '../../widget/StateKosong.dart';
import '../../widget/TombolUtama.dart';

class LayarOnboarding extends StatefulWidget {
  const LayarOnboarding({super.key});

  @override
  State<LayarOnboarding> createState() => _KeadaanLayarOnboarding();
}

class _KeadaanLayarOnboarding extends State<LayarOnboarding> {
  bool _sudahMuat = false;
  final _kunciForm = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_sudahMuat) {
      _sudahMuat = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProviderOnboarding>().muatKategori();
      });
    }
  }

  Future<void> _mulai(ProviderOnboarding provider) async {
    _kunciForm.currentState?.validate();
    await provider.simpanPeriode();
    if (!mounted) return;
    final status = provider.statusSimpan;
    if (status.adalahSukses) {
      Navigator.pushReplacementNamed(context, RuteAplikasi.dashboard);
    } else if (status.adalahError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status.pesan ?? 'Gagal menyimpan periode')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderOnboarding>();
    final status = provider.statusKategori;

    return Scaffold(
      body: SafeArea(
        child: status.sedangLoading
            ? _bangunLoading(context)
            : status.adalahKosong
                ? _bangunKosong(provider)
                : status.adalahError
                    ? _bangunError(provider)
                    : _bangunForm(context, provider),
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

  Widget _bangunKosong(ProviderOnboarding provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StateKosong(
            ikon: Icons.category_outlined,
            judul: 'Belum Ada Kategori',
            pesan: 'Kategori default belum dibuat. Tambahkan dulu '
                'sebelum menentukan batas anggaran.',
          ),
          const SizedBox(height: 16),
          TombolUtama(
            label: 'Tambah Kategori Default',
            ikon: Icons.add,
            saatDitekan: () => provider.buatKategoriDefault(),
          ),
        ],
      ),
    );
  }

  Widget _bangunError(ProviderOnboarding provider) {
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
              'Terjadi kesalahan saat memuat data. Periksa penyimpanan '
              'lalu coba lagi.',
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

  Widget _bangunForm(BuildContext context, ProviderOnboarding provider) {
    final tema = Theme.of(context);
    final daftar = provider.kategori ?? <Kategori>[];
    final sedangMenyimpan = provider.statusSimpan.sedangLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _kunciForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Icon(
              Icons.account_balance_wallet,
              size: 72,
              color: tema.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Selamat Datang di DompetKos',
              style: tema.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan pemasukan bulananmu dan atur batas per kategori.',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            BidangTeks(
              label: 'Total Pemasukan Bulanan',
              petunjuk: 'Contoh: 1500000',
              ikon: Icons.attach_money,
              jenisInput: TextInputType.number,
              controller: provider.controllerPemasukan,
              validator: provider.validasiPemasukan,
            ),
            const SizedBox(height: 8),
            Text(
              'Format: ${PemformatMataUang.format(1500000)} per bulan',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Batas Pengeluaran per Kategori',
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: daftar.map((kategori) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                Color(kategori.nilaiWarna).withOpacity(0.15),
                            child: Icon(
                              PemetaIkon.dariNama(kategori.namaIkon),
                              color: Color(kategori.nilaiWarna),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: provider.controllerBatas[kategori.id],
                              keyboardType: TextInputType.number,
                              validator: provider.validasiBatas,
                              decoration: InputDecoration(
                                labelText: 'Batas ${kategori.nama}',
                                prefixText: 'Rp ',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.ringkasanBatas,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            if (provider.errorTotalBatas != null) ...[
              const SizedBox(height: 8),
              Container(
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
                        provider.errorTotalBatas!,
                        style: TextStyle(
                          color: tema.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Izinkan Notifikasi'),
                subtitle: const Text(
                  'Dapatkan peringatan saat kategori mendekati batas '
                  'dan pengingat harian pukul 21:00.',
                ),
                value: provider.izinNotifikasi,
                onChanged: (nilai) => provider.izinNotifikasi = nilai,
              ),
            ),
            const SizedBox(height: 24),
            TombolUtama(
              label: 'Mulai Kelola Uang',
              ikon: Icons.arrow_forward,
              sedangMemuat: sedangMenyimpan,
              saatDitekan: sedangMenyimpan ? null : () => _mulai(provider),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
