class AppConstants {
  AppConstants._();

  static const String appName = 'Farmers POS';
  static const String currency = 'FCFA';

  // Default interest rate for credit (30%)
  static const double defaultInterestRate = 0.30;

  // Shared prefs keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'auth_user';
  static const String keyRole = 'user_role';
}
