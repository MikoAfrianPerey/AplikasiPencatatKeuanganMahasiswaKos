import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../inti/routing/RuteAplikasi.dart';
import '../../../provider/ProviderAuth.dart';
import '../../widget/TombolUtama.dart';

class LayarMasuk extends StatefulWidget {
  const LayarMasuk({super.key});

  @override
  State<LayarMasuk> createState() => _KeadaanLayarMasuk();
}

class _KeadaanLayarMasuk extends State<LayarMasuk> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _sandi = TextEditingController();
  bool _sandiTerlihat = false;

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    _sandi.dispose();
    super.dispose();
  }

  Future<void> _kirim(ProviderAuth auth) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await auth.kirim(
      nama: _nama.text,
      email: _email.text,
      sandi: _sandi.text,
    );
    if (!mounted) return;
    if (auth.sedangMasuk) {
      Navigator.pushReplacementNamed(context, RuteAplikasi.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ProviderAuth>();
    final sedangMemuat = auth.status.sedangLoading;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.account_balance_wallet, size: 72),
              const SizedBox(height: 16),
              Text(
                'DompetKos',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                auth.modeDaftar
                    ? 'Buat akun untuk mulai mencatat keuanganmu.'
                    : 'Masuk untuk melanjutkan pencatatan.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              if (auth.modeDaftar) ...[
                TextFormField(
                  controller: _nama,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: auth.validasiNama,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: auth.validasiEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sandi,
                obscureText: !_sandiTerlihat,
                decoration: InputDecoration(
                  labelText: 'Sandi',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    tooltip: _sandiTerlihat ? 'Sembunyikan sandi' : 'Lihat sandi',
                    icon: Icon(
                      _sandiTerlihat ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(
                      () => _sandiTerlihat = !_sandiTerlihat,
                    ),
                  ),
                ),
                validator: auth.validasiSandi,
                onFieldSubmitted: (_) => _kirim(auth),
              ),
              if (auth.status.adalahError) ...[
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline),
                        const SizedBox(width: 8),
                        Expanded(child: Text(auth.status.pesan ?? 'Gagal')),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              TombolUtama(
                label: auth.modeDaftar ? 'Daftar' : 'Masuk',
                ikon: auth.modeDaftar ? Icons.person_add : Icons.login,
                sedangMemuat: sedangMemuat,
                saatDitekan: sedangMemuat ? null : () => _kirim(auth),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: sedangMemuat
                    ? null
                    : () => auth.modeDaftar = !auth.modeDaftar,
                child: Text(
                  auth.modeDaftar
                      ? 'Sudah punya akun? Masuk'
                      : 'Belum punya akun? Daftar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
