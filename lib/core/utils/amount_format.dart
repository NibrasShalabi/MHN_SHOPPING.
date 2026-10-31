import 'package:flutter/services.dart';

/// Amounts the way people write them here: dots between thousands, a comma
/// for decimals only when there are any — `1.400.000`, `12,50`.
class AmountFormat {
  AmountFormat._();

  static String format(double value, {int maxDecimals = 2}) {
    final negative = value < 0;
    final fixed = value.abs().toStringAsFixed(maxDecimals);
    final parts = fixed.split('.');
    final whole = parts.first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
    final fraction = parts.length > 1 ? parts[1].replaceFirst(RegExp(r'0+$'), '') : '';
    return '${negative ? '-' : ''}$whole${fraction.isEmpty ? '' : ',$fraction'}';
  }

  /// Reads back what [format] or [ThousandsInputFormatter] wrote.
  static double? parse(String text) {
    final cleaned = text.trim().replaceAll('.', '').replaceAll(',', '.');
    return cleaned.isEmpty ? null : double.tryParse(cleaned);
  }
}

/// Groups the digits while typing (`14000` → `14.000`) and keeps a comma
/// for decimals. Pair with [AmountFormat.parse].
class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll('.', '');
    if (raw.isEmpty) return newValue.copyWith(text: '');
    if (!RegExp(r'^\d*(,\d{0,2})?$').hasMatch(raw)) return oldValue;

    final parts = raw.split(',');
    final whole = parts.first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
    final text = parts.length > 1 ? '$whole,${parts[1]}' : whole;
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
