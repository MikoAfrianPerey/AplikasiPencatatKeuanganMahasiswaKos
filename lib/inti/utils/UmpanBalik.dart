import 'package:flutter/material.dart';

class UmpanBalik {
  static void sukses(BuildContext context, String pesan) {
    _tampilkan(
        context, pesan, Icons.check_circle_outline, Colors.green.shade600);
  }

  static void info(BuildContext context, String pesan) {
    _tampilkan(context, pesan, Icons.info_outline, null);
  }

  static void galat(BuildContext context, String pesan) {
    _tampilkan(context, pesan, Icons.error_outline, Colors.red.shade600);
  }

  static void _tampilkan(
    BuildContext context,
    String pesan,
    IconData ikon,
    Color? warna,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(ikon, color: warna ?? Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(pesan)),
          ],
        ),
      ),
    );
  }
}
