import 'package:flutter/material.dart';

import '../../provider/ProviderProfil.dart';
import 'KartuPeringatan.dart';
import 'TombolUtama.dart';

class FormulirProfil extends StatelessWidget {
  final ProviderProfil provider;
  final VoidCallback saatSimpan;

  const FormulirProfil({
    super.key,
    required this.provider,
    required this.saatSimpan,
  });

  @override
  Widget build(BuildContext context) {
    final sedangMenyimpan = provider.statusSimpan.sedangLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (provider.statusSimpan.adalahError) ...[
          KartuPeringatan(pesan: provider.statusSimpan.pesan!),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: provider.controllerNama,
          decoration: const InputDecoration(
            labelText: 'Nama',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: provider.controllerEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 24),
        TombolUtama(
          label: 'Simpan Profil',
          ikon: Icons.save,
          sedangMemuat: sedangMenyimpan,
          saatDitekan: sedangMenyimpan ? null : saatSimpan,
        ),
      ],
    );
  }
}
