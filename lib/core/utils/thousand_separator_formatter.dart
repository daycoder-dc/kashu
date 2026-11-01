import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandSeparatorFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'es');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();

    final number = int.tryParse(digits);
    if (number == null) return oldValue;

    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static final NumberFormat _staticFormatter = NumberFormat('#,###', 'es');

  static double? parse(String text) {
    if (text.isEmpty) return null;
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(digits);
  }

  static String format(double value) {
    return _staticFormatter.format(value.toInt());
  }
}
