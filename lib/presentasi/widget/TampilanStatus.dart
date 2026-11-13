import 'package:flutter/material.dart';

class TampilanStatus extends StatelessWidget {
  final bool sedangMemuat;
  final String pesanMemuat;
  final String? error;
  final String judulError;
  final IconData ikonError;
  final VoidCallback saatCobaLagi;
  final Widget child;

  const TampilanStatus({
    super.key,
    required this.sedangMemuat,
    required this.pesanMemuat,
    required this.error,
    required this.judulError,
    required this.ikonError,
    required this.saatCobaLagi,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (sedangMemuat) return IndikatorMemuat(pesan: pesanMemuat);
    if (error != null) {
      return TampilanGalat(
        judul: judulError,
        pesan: error!,
        ikon: ikonError,
        saatCobaLagi: saatCobaLagi,
      );
    }
    return child;
  }
}

class IndikatorMemuat extends StatelessWidget {
  final String pesan;

  const IndikatorMemuat({super.key, required this.pesan});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Semantics(
        liveRegion: true,
        label: pesan,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              pesan,
              style: tema.textTheme.bodyLarge?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TampilanGalat extends StatelessWidget {
  final String judul;
  final String pesan;
  final IconData ikon;
  final VoidCallback saatCobaLagi;

  const TampilanGalat({
    super.key,
    required this.judul,
    required this.pesan,
    required this.ikon,
    required this.saatCobaLagi,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 48),
            const SizedBox(height: 12),
            Text(judul, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(pesan, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: saatCobaLagi,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
