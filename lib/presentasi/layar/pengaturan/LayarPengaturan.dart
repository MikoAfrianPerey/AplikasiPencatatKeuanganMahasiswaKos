import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/ProviderPengaturan.dart';

class LayarPengaturan extends StatefulWidget {
  const LayarPengaturan({super.key});

  @override
  State<LayarPengaturan> createState() => _KeadaanLayarPengaturan();
}

class _KeadaanLayarPengaturan extends State<LayarPengaturan> {
  Future<bool?> _konfirmasiReset() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Semua Data?'),
        content: const Text(
          'Seluruh transaksi, kategori, dan periode anggaran akan dihapus '
          'permanen. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData(ProviderPengaturan pengaturan) async {
    final konfirmasi = await _konfirmasiReset();
    if (konfirmasi == true && mounted) {
      await pengaturan.resetDataDemo();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data demo berhasil direset')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final pengaturan = context.watch<ProviderPengaturan>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          _bagianHeader('Batas Kategori', tema),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.orange),
                  title: const Text('Makan'),
                  subtitle: const Text('Batas: Rp 600.000'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.green),
                  title: const Text('Kos'),
                  subtitle: const Text('Batas: Rp 500.000'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading:
                      const Icon(Icons.directions_bus, color: Colors.blue),
                  title: const Text('Transport'),
                  subtitle: const Text('Batas: Rp 200.000'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.category, color: Colors.purple),
                  title: const Text('Lain-lain'),
                  subtitle: const Text('Batas: Rp 200.000'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          _bagianHeader('Notifikasi', tema),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Ambang Batas Peringatan'),
                  subtitle: Slider(
                    value: pengaturan.ambangNotifikasi,
                    min: 50,
                    max: 100,
                    divisions: 10,
                    label: '${pengaturan.ambangNotifikasi.toInt()}%',
                    onChanged: pengaturan.setAmbangNotifikasi,
                  ),
                  trailing:
                      Text('${pengaturan.ambangNotifikasi.toInt()}%'),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.alarm),
                  title: const Text('Pengingat Harian'),
                  subtitle: const Text('Pengingat catat transaksi pukul 21:00'),
                  value: pengaturan.pengingatHarian,
                  onChanged: pengaturan.setPengingatHarian,
                ),
              ],
            ),
          ),
          _bagianHeader('Kategori', tema),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Kelola Kategori'),
              subtitle: const Text('Tambah, edit, atau nonaktifkan kategori'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          _bagianHeader('Data', tema),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Reset Semua Data'),
                  subtitle: const Text('Hapus seluruh data aplikasi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _resetData(pengaturan),
                ),
              ],
            ),
          ),
          _bagianHeader('Demo & Pengujian State', tema),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.bug_report),
                  title: const Text('Simulasikan Error Saat Memuat Kategori'),
                  subtitle: const Text(
                    'Aktifkan lalu buka layar Onboarding untuk melihat '
                    'tampilan error state beserta tombol retry.',
                  ),
                  value: pengaturan.simulasiError,
                  onChanged: pengaturan.setSimulasiError,
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: const Text('Reset Data Demo'),
                  subtitle: const Text(
                    'Kosongkan kategori untuk melihat empty state pada '
                    'layar Onboarding dan Tambah Transaksi.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _resetData(pengaturan),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _bagianHeader(String judul, ThemeData tema) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        judul,
        style: tema.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: tema.colorScheme.primary,
        ),
      ),
    );
  }
}
