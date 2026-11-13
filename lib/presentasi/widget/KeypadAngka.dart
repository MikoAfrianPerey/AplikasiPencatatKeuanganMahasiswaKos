import 'package:flutter/material.dart';

import '../../inti/utils/TataLetak.dart';

class KeypadAngka extends StatelessWidget {
  static const _tombol = [
    '7', '8', '9', '⌫', //
    '4', '5', '6', '000', //
    '1', '2', '3', '0',
  ];

  final bool nonaktif;
  final ValueChanged<String> saatKetik;
  final VoidCallback saatHapus;

  const KeypadAngka({
    super.key,
    required this.saatKetik,
    required this.saatHapus,
    this.nonaktif = false,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: TataLetak.lebar(context) ? 6 : 4,
        childAspectRatio: 1.6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _tombol.length,
      itemBuilder: (context, index) {
        final nilai = _tombol[index];
        final adalahHapus = nilai == '⌫';
        return FilledButton(
          onPressed: nonaktif
              ? null
              : adalahHapus
                  ? saatHapus
                  : () => saatKetik(nilai),
          style: FilledButton.styleFrom(
            backgroundColor: adalahHapus
                ? tema.colorScheme.errorContainer
                : tema.colorScheme.surfaceContainerHighest,
            foregroundColor: adalahHapus
                ? tema.colorScheme.onErrorContainer
                : tema.colorScheme.onSurface,
          ),
          child: Text(
            nilai,
            style: tema.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
