import 'package:flutter/material.dart';

class ItemTransaksi extends StatelessWidget {
  final IconData ikon;
  final Color warnaIkon;
  final String kategori;
  final String catatan;
  final String tanggal;
  final String jumlah;
  final bool adalahPemasukan;

  const ItemTransaksi({
    super.key,
    required this.ikon,
    required this.warnaIkon,
    required this.kategori,
    required this.catatan,
    required this.tanggal,
    required this.jumlah,
    required this.adalahPemasukan,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: warnaIkon.withOpacity(0.15),
        child: Icon(ikon, color: warnaIkon),
      ),
      title: Text(
        kategori,
        style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        catatan.isEmpty ? tanggal : '$tanggal - $catatan',
        style: tema.textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${adalahPemasukan ? '+' : '-'} $jumlah',
        style: tema.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: adalahPemasukan ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
