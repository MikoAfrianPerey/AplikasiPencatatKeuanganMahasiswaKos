import 'package:flutter/material.dart';

import '../../inti/konstanta/WarnaBatas.dart';
import '../../inti/utils/PemformatMataUang.dart';

class ItemKategori extends StatelessWidget {
  final String nama;
  final int batas;
  final int terpakai;

  const ItemKategori({
    super.key,
    required this.nama,
    required this.batas,
    required this.terpakai,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    double persen = batas == 0 ? 0 : (terpakai / batas) * 100;
    double nilaiIndicator = (persen / 100).clamp(0.0, 1.0);

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
                  color: WarnaBatas.berdasarkanPersen(persen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: nilaiIndicator,
              minHeight: 8,
              backgroundColor: tema.colorScheme.surfaceContainerHighest,
              color: WarnaBatas.berdasarkanPersen(persen),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${PemformatMataUang.format(terpakai)} dari ${PemformatMataUang.format(batas)}',
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
