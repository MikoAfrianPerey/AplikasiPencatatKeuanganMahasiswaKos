import 'package:intl/intl.dart';

class PemformatMataUang {
  static final NumberFormat _format = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(int jumlah) => _format.format(jumlah);
}
