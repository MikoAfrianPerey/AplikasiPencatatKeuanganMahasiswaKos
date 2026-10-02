import 'package:intl/intl.dart';

class PemformatTanggal {
  static String formatPendek(DateTime tanggal) =>
      DateFormat('d MMM yyyy', 'id_ID').format(tanggal);

  static String formatPanjang(DateTime tanggal) =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(tanggal);
}
