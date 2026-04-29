class ApiEndpoints {
  ApiEndpoints._();

  // ─── Auth ───────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // ─── Users ──────────────────────────────────────────────────────────────────
  static const String users = '/users';
  static String userById(int id) => '/users/$id';

  // ─── Categories ─────────────────────────────────────────────────────────────
  static const String categories = '/categories';
  static String categoryById(int id) => '/categories/$id';

  // ─── Products ───────────────────────────────────────────────────────────────
  static const String products = '/products';
  static String productById(int id) => '/products/$id';

  // ─── Farmers ────────────────────────────────────────────────────────────────
  static const String farmers = '/farmers';
  static String farmerById(int id) => '/farmers/$id';
  static String farmerSearch(String query) => '/farmers/search?q=$query';
  static String farmerDebts(int farmerId) => '/farmers/$farmerId/debts';

  // ─── Transactions ───────────────────────────────────────────────────────────
  static const String transactions = '/transactions';
  static String transactionById(int id) => '/transactions/$id';

  // ─── Repayments ─────────────────────────────────────────────────────────────
  static const String repayments = '/repayments';
  static String repaymentsByFarmer(int farmerId) =>
      '/farmers/$farmerId/repayments';

  // ─── Settings ───────────────────────────────────────────────────────────────
  static const String settings = '/settings';
}
