import 'package:flutter/material.dart';

class PemetaIkon {
  static const Map<String, IconData> _peta = {
    'restaurant': Icons.restaurant,
    'home': Icons.home,
    'directions_bus': Icons.directions_bus,
    'category': Icons.category,
    'shopping_bag': Icons.shopping_bag,
    'sports_esports': Icons.sports_esports,
    'school': Icons.school,
    'wifi': Icons.wifi,
    'local_hospital': Icons.local_hospital,
    'savings': Icons.savings,
  };

  static IconData dariNama(String nama) => _peta[nama] ?? Icons.category;
}
