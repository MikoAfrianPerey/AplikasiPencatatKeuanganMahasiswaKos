import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LayananNotifikasi {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _idPengingatHarian = 1;
  static const _idPeringatanBatas = 2;

  Future<bool> inisialisasi() async {
    tz.initializeTimeZones();
    const pengaturanAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final berhasil = await _plugin.initialize(
      const InitializationSettings(android: pengaturanAndroid),
    );
    await _mintaIzin();
    return berhasil ?? false;
  }

  Future<bool> mintaIzin() => _mintaIzin();

  Future<bool> _mintaIzin() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    final diizinkan = await android.requestNotificationsPermission();
    return diizinkan ?? false;
  }

  NotificationDetails get _detail => const NotificationDetails(
        android: AndroidNotificationDetails(
          'dompet_kos_default',
          'DompetKos',
          channelDescription: 'Pengingat transaksi dan peringatan batas',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

  Future<void> jadwalkanPengingatHarian({required bool aktif}) async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.cancel(_idPengingatHarian);
    if (!aktif) return;
    await _plugin.zonedSchedule(
      _idPengingatHarian,
      'Catat pengeluaran hari ini',
      'Luangkan waktu sebentar untuk mencatat transaksi DompetKos.',
      _jadwalBerikutnya(21, 0),
      _detail,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> kirimPeringatanBatas(String namaKategori) async {
    await _plugin.show(
      _idPeringatanBatas,
      'Batas kategori hampir habis',
      'Pengeluaran $namaKategori sudah mendekati batas bulan ini.',
      _detail,
    );
  }

  tz.TZDateTime _jadwalBerikutnya(int jam, int menit) {
    final sekarang = tz.TZDateTime.now(tz.local);
    var jadwal = tz.TZDateTime(
      tz.local,
      sekarang.year,
      sekarang.month,
      sekarang.day,
      jam,
      menit,
    );
    if (!jadwal.isAfter(sekarang)) {
      jadwal = jadwal.add(const Duration(days: 1));
    }
    return jadwal;
  }
}
