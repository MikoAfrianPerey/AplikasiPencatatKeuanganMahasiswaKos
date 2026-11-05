import 'package:flutter/material.dart';

class TataLetak {
  static const double ambangLebar = 720;

  static bool lebar(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= ambangLebar;

  static double lebarKonten(BuildContext context) {
    final lebar = MediaQuery.sizeOf(context).width;
    return lebar > 900 ? 900 : lebar;
  }

  static Widget pusatkan(BuildContext context, Widget child) {
    if (!lebar(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: lebarKonten(context)),
        child: child,
      ),
    );
  }
}
