import 'package:flutter/material.dart';

import '../../../inti/routing/RuteAplikasi.dart';
import '../../../inti/utils/PemformatMataUang.dart';
import '../../widget/BidangTeks.dart';
import '../../widget/TombolUtama.dart';

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

  String? _validasiPemasukan(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Total pemasukan tidak boleh kosong';
    }
    final jumlah = int.tryParse(nilai.replaceAll(RegExp(r'[^0-9]'), ''));
    if (jumlah == null || jumlah <= 0) {
      return 'Masukkan jumlah yang valid';
    }
    return null;
  }

  void _mulai() {
    if (_kunciForm.currentState?.validate() != true) return;

    Navigator.pushReplacementNamed(context, RuteAplikasi.dashboard);
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
                Icon(
                  Icons.account_balance_wallet,
                  size: 88,
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
                  'Catat pemasukan bulananmu untuk mulai mengendalikan uang kos.',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                BidangTeks(
                  label: 'Total Pemasukan Bulanan',
                  petunjuk: 'Contoh: 1500000',
                  ikon: Icons.attach_money,
                  jenisInput: TextInputType.number,
                  controller: _controllerPemasukan,
                  validator: _validasiPemasukan,
                ),
                const SizedBox(height: 8),
                Text(
                  'Format: ${PemformatMataUang.format(1500000)} per bulan',
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: SwitchListTile(
                    title: const Text('Izinkan Notifikasi'),
                    subtitle: const Text(
                      'Dapatkan peringatan saat kategori mendekati batas '
                      'dan pengingat harian pukul 21:00.',
                    ),
                    value: _izinNotifikasi,
                    onChanged: (nilai) {
                      setState(() => _izinNotifikasi = nilai);
                    },
                  ),
                ),
                const SizedBox(height: 32),
                TombolUtama(
                  label: 'Mulai Kelola Uang',
                  ikon: Icons.arrow_forward,
                  saatDitekan: _mulai,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
