import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsHelpper extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final number = int.parse(newText);
    final formatter = NumberFormat.decimalPattern('id');
    final formattedText = formatter.format(number);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
