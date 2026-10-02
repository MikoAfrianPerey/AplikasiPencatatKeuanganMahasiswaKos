import 'package:flutter/material.dart';

class LayarPengaturan extends StatefulWidget {
  const LayarPengaturan({super.key});

  @override
  State<LayarPengaturan> createState() => _KeadaanLayarPengaturan();
}

class _KeadaanLayarPengaturan extends State<LayarPengaturan> {
  double _ambangNotifikasi = 80;
  bool _pengingatHarian = true;
  bool _temaGelap = false;

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

  void _resetData() async {
    final konfirmasi = await _konfirmasiReset();
    if (konfirmasi == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data berhasil direset')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          _bagianHeader('Periode Anggaran', tema),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Periode Aktif'),
                  subtitle: const Text('Oktober 2026'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Total Pemasukan'),
                  subtitle: const Text('Rp 1.500.000'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
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
                  leading: const Icon(Icons.directions_bus, color: Colors.blue),
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
                    value: _ambangNotifikasi,
                    min: 50,
                    max: 100,
                    divisions: 10,
                    label: '${_ambangNotifikasi.toInt()}%',
                    onChanged: (nilai) {
                      setState(() => _ambangNotifikasi = nilai);
                    },
                  ),
                  trailing: Text('${_ambangNotifikasi.toInt()}%'),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.alarm),
                  title: const Text('Pengingat Harian'),
                  subtitle: const Text('Pengingat catat transaksi pukul 21:00'),
                  value: _pengingatHarian,
                  onChanged: (nilai) {
                    setState(() => _pengingatHarian = nilai);
                  },
                ),
              ],
            ),
          ),
          _bagianHeader('Tampilan', tema),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Tema Gelap'),
              subtitle: const Text('Ikuti pengaturan sistem'),
              value: _temaGelap,
              onChanged: (nilai) {
                setState(() => _temaGelap = nilai);
              },
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
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Reset Semua Data'),
              subtitle: const Text('Hapus seluruh data aplikasi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _resetData,
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
