import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static final NumberFormat _fcfaFormat = NumberFormat('#,##0', 'fr_FR');

  /// Formate un montant en FCFA : "12 500 FCFA"
  static String format(double amount) =>
      '${_fcfaFormat.format(amount)} FCFA';

  /// Formate sans suffixe : "12 500"
  static String formatRaw(double amount) => _fcfaFormat.format(amount);

  /// Formate de façon compacte : "1,2M FCFA", "50K FCFA", etc.
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K FCFA';
    }
    return format(amount);
  }
}
