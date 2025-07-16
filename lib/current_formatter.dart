import 'package:intl/intl.dart';

extension CurrentFormatter on int {
  String toRupiah() {
    final formatCurrency = NumberFormat.currency(
      locale: 'id',
      decimalDigits: 0,
    );
    return formatCurrency.format(this);
  }
}
