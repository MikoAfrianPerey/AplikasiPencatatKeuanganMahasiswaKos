import 'package:flutter/material.dart';

class BidangTeks extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? petunjuk;
  final IconData? ikon;
  final TextInputType jenisInput;
  final bool teksSandi;
  final String? Function(String?)? validator;
  final void Function(String)? saatBerubah;

  const BidangTeks({
    super.key,
    required this.label,
    this.controller,
    this.petunjuk,
    this.ikon,
    this.jenisInput = TextInputType.text,
    this.teksSandi = false,
    this.validator,
    this.saatBerubah,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: teksSandi,
      keyboardType: jenisInput,
      validator: validator,
      onChanged: saatBerubah,
      decoration: InputDecoration(
        labelText: label,
        hintText: petunjuk,
        prefixIcon: ikon != null ? Icon(ikon) : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
