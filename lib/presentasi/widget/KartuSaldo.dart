import 'package:flutter/material.dart';

import '../../inti/konstanta/WarnaBatas.dart';
import '../../inti/utils/PemformatMataUang.dart';

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

    double persenTerpakai = totalPemasukan == 0
        ? 0
        : (totalPengeluaran / totalPemasukan) * 100;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sisa Saldo Bulan Ini',
              style: tema.textTheme.titleSmall?.copyWith(
                color: warna.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                PemformatMataUang.format(sisaSaldo),
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
                value: (persenTerpakai / 100).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: warna.surfaceContainerHighest,
                color: WarnaBatas.berdasarkanPersen(persenTerpakai),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoRingkas(
                  judul: 'Pemasukan',
                  nilai: PemformatMataUang.format(totalPemasukan),
                  warna: Colors.green,
                ),
                _InfoRingkas(
                  judul: 'Pengeluaran',
                  nilai: PemformatMataUang.format(totalPengeluaran),
                  warna: Colors.red,
                ),
                _InfoRingkas(
                  judul: 'Sisa Hari',
                  nilai: '$sisaHari hari',
                  warna: warna.primary,
                ),
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

  const _InfoRingkas({
    required this.judul,
    required this.nilai,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          judul,
          style: tema.textTheme.labelSmall?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            nilai,
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: warna,
            ),
          ),
        ),
      ],
    );
  }
}
