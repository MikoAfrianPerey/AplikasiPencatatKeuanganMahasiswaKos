import 'package:flutter/material.dart';

class WarnaBatas {
  static Color berdasarkanPersen(double persen) {
    if (persen < 60) return Colors.green;
    if (persen <= 85) return Colors.orange;
    return Colors.red;
  }
}
