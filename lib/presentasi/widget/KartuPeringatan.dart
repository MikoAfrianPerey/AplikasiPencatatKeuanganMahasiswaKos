import 'package:flutter/material.dart';

class KartuPeringatan extends StatelessWidget {
  final String pesan;

  const KartuPeringatan({super.key, required this.pesan});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tema.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: tema.colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                pesan,
                style: TextStyle(color: tema.colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
