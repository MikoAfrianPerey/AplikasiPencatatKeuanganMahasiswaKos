import 'package:flutter/material.dart';

class TombolUtama extends StatelessWidget {
  final String label;
  final IconData? ikon;
  final VoidCallback? saatDitekan;
  final bool sedangMemuat;

  const TombolUtama({
    super.key,
    required this.label,
    this.ikon,
    this.saatDitekan,
    this.sedangMemuat = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: sedangMemuat ? null : saatDitekan,
      icon: sedangMemuat
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(ikon ?? Icons.check),
      label: Text(label),
    );
  }
}
