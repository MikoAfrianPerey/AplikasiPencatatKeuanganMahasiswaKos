import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../inti/routing/RuteAplikasi.dart';
import '../../../provider/ProviderAuth.dart';

class LayarGerbang extends StatefulWidget {
  const LayarGerbang({super.key});

  @override
  State<LayarGerbang> createState() => _KeadaanLayarGerbang();
}

class _KeadaanLayarGerbang extends State<LayarGerbang> {
  bool _sudahCek = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sudahCek) return;
    _sudahCek = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<ProviderAuth>();
      try {
        await auth.periksaSesi();
      } on Exception catch (_) {
        // Gagal membaca sesi diperlakukan sebagai belum masuk.
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        auth.sedangMasuk ? RuteAplikasi.dashboard : RuteAplikasi.masuk,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
