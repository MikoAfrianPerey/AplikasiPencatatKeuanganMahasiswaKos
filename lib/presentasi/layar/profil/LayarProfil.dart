import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../inti/utils/TataLetak.dart';
import '../../../inti/utils/UmpanBalik.dart';
import '../../../provider/ProviderAuth.dart';
import '../../../provider/ProviderProfil.dart';
import '../../widget/FormulirProfil.dart';
import '../../widget/KartuPeringatan.dart';
import '../../widget/TombolUtama.dart';

class LayarProfil extends StatefulWidget {
  const LayarProfil({super.key});

  @override
  State<LayarProfil> createState() => _KeadaanLayarProfil();
}

class _KeadaanLayarProfil extends State<LayarProfil> {
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<ProviderAuth>();
    context.read<ProviderProfil>().isiDari(auth.pengguna);
  }

  Future<void> _simpan(ProviderProfil profil, ProviderAuth auth) async {
    FocusScope.of(context).unfocus();
    final pengguna = await profil.simpanProfil();
    if (!mounted || pengguna == null) return;
    await auth.perbaruiProfil(pengguna);
    if (!mounted) return;
    UmpanBalik.sukses(context, 'Profil berhasil disimpan');
  }

  Future<void> _ubahSandi(ProviderProfil profil) async {
    FocusScope.of(context).unfocus();
    final berhasil = await profil.ubahSandi();
    if (!mounted) return;
    if (berhasil) {
      UmpanBalik.sukses(context, 'Sandi berhasil diubah');
    } else if (profil.statusSandi.adalahError) {
      UmpanBalik.galat(
          context, profil.statusSandi.pesan ?? 'Gagal mengubah sandi');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<ProviderProfil>();
    final auth = context.watch<ProviderAuth>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: TataLetak.pusatkan(
        context,
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _kartuIdentitas(auth),
            const SizedBox(height: 24),
            Text(
              'Informasi Profil',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: FormulirProfil(
                provider: profil,
                saatSimpan: () => _simpan(profil, auth),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Ubah Sandi',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _formSandi(profil),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _kartuIdentitas(ProviderAuth auth) {
    final nama = auth.pengguna?.nama ?? 'Belum masuk';
    final email = auth.pengguna?.email ?? '-';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            nama.isNotEmpty ? nama[0].toUpperCase() : '?',
          ),
        ),
        title: Text(nama),
        subtitle: Text(email),
      ),
    );
  }

  Widget _formSandi(ProviderProfil profil) {
    final sedangMenyimpan = profil.statusSandi.sedangLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (profil.statusSandi.adalahError) ...[
          KartuPeringatan(pesan: profil.statusSandi.pesan!),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: profil.controllerSandiLama,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Sandi Lama',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: profil.controllerSandiBaru,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Sandi Baru',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: profil.controllerKonfirmasi,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Konfirmasi Sandi Baru',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: 24),
        TombolUtama(
          label: 'Ubah Sandi',
          ikon: Icons.lock_reset,
          sedangMemuat: sedangMenyimpan,
          saatDitekan: sedangMenyimpan ? null : () => _ubahSandi(profil),
        ),
      ],
    );
  }
}
