import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static final NumberFormat _fcfaFormat = NumberFormat('#,##0', 'fr_FR');

  /// Formate un montant en FCFA : "12 500 FCFA"
  static String format(double amount) =>
      '${_fcfaFormat.format(amount)} FCFA';

  /// Formate sans suffixe : "12 500"
  static String formatRaw(double amount) => _fcfaFormat.format(amount);
}
