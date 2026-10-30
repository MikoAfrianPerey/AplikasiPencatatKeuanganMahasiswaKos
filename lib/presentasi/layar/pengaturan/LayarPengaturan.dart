import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/model/BudgetKategori.dart';
import '../../../data/model/Kategori.dart';
import '../../../data/repository/RepositoryKategori.dart';
import '../../../data/repository/RepositoryPeriodeBudget.dart';
import '../../../inti/routing/RuteAplikasi.dart';
import '../../../inti/utils/PemformatMataUang.dart';
import '../../../provider/ProviderAuth.dart';
import '../../../provider/ProviderPengaturan.dart';

class LayarPengaturan extends StatefulWidget {
  const LayarPengaturan({super.key});

  @override
  State<LayarPengaturan> createState() => _KeadaanLayarPengaturan();
}

class _KeadaanLayarPengaturan extends State<LayarPengaturan> {
  bool _sudahCek = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sudahCek) return;
    _sudahCek = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderPengaturan>().periksaIzinNotifikasi();
    });
  }

  Future<(List<BudgetKategori>, List<Kategori>)> _muatBatas() async {
    final periode = context.read<RepositoryPeriodeBudget>();
    final kategori = context.read<RepositoryKategori>();
    final aktif = await periode.ambilPeriodeAktif();
    if (aktif == null) {
      return (<BudgetKategori>[], await kategori.ambilSemua());
    }
    final batas = await periode.ambilBatasPeriode(aktif.id);
    return (batas, await kategori.ambilSemua());
  }

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

  Future<void> _keluar(ProviderAuth auth) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Data transaksi tetap tersimpan. Kamu dapat masuk kembali kapan saja.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (konfirmasi != true || !mounted) return;
    await auth.keluar();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RuteAplikasi.masuk,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final pengaturan = context.watch<ProviderPengaturan>();
    final auth = context.watch<ProviderAuth>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  (auth.pengguna?.nama.isNotEmpty ?? false)
                      ? auth.pengguna!.nama[0].toUpperCase()
                      : '?',
                ),
              ),
              title: Text(auth.pengguna?.nama ?? 'Belum masuk'),
              subtitle: Text(auth.pengguna?.email ?? '-'),
              trailing: TextButton(
                onPressed: () => _keluar(auth),
                child: const Text('Keluar'),
              ),
            ),
          ),
          _bagianHeader('Batas Kategori', tema),
          Card(
            child: ListTile(
              leading: const Icon(Icons.edit_calendar),
              title: const Text('Atur Periode Anggaran'),
              subtitle: const Text('Ubah total pemasukan dan batas kategori'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.pushNamed(context, RuteAplikasi.onboarding),
            ),
          ),
          Card(
            child: FutureBuilder<(List<BudgetKategori>, List<Kategori>)>(
              future: _muatBatas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text('Gagal memuat batas kategori'),
                    subtitle: const Text(
                      'Periksa penyimpanan lalu coba lagi.',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => setState(() {}),
                    ),
                  );
                }
                final batas = snapshot.data?.$1 ?? const <BudgetKategori>[];
                final kategori = snapshot.data?.$2 ?? const <Kategori>[];
                if (batas.isEmpty) {
                  return const ListTile(
                    leading: Icon(Icons.inbox),
                    title: Text('Belum ada batas kategori'),
                    subtitle: Text(
                      'Atur periode anggaran untuk membuat batas.',
                    ),
                  );
                }
                return Column(
                  children: batas.map((item) {
                    final cocok = kategori.where(
                      (k) => k.id == item.idKategori,
                    );
                    return ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: Text(cocok.isEmpty ? 'Lain-lain' : cocok.first.nama),
                      subtitle: Text(
                        'Batas: ${PemformatMataUang.format(item.jumlahBatas)}',
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          _bagianHeader('Notifikasi', tema),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    pengaturan.izinNotifikasi
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                  ),
                  title: const Text('Izin Notifikasi'),
                  subtitle: Text(
                    pengaturan.izinNotifikasi
                        ? 'Diizinkan. Pengingat dan peringatan dapat dikirim.'
                        : 'Belum diizinkan. Aktifkan agar pengingat muncul.',
                  ),
                  trailing: pengaturan.izinNotifikasi
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : TextButton(
                          onPressed: pengaturan.mintaIzinNotifikasi,
                          child: const Text('Izinkan'),
                        ),
                ),
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
                  onChanged: pengaturan.sedangMengaturNotifikasi
                      ? null
                      : pengaturan.setPengingatHarian,
                ),
                ListTile(
                  leading: const Icon(Icons.send),
                  title: const Text('Kirim Notifikasi Uji'),
                  subtitle: const Text(
                    'Memeriksa apakah notifikasi tampil di perangkat.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: pengaturan.kirimUjiNotifikasi,
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
