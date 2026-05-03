class ApiEndpoints {
  ApiEndpoints._();

  // ─── Auth ───────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // ─── Users (admin/supervisor) ───────────────────────────────────────────────
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
  static String farmerDebts(int farmerId) => '/farmers/$farmerId/debts';
  static String farmerRepayments(int farmerId) => '/farmers/$farmerId/repayments';

  // ─── Transactions ───────────────────────────────────────────────────────────
  static const String transactions = '/transactions';
  static String transactionById(int id) => '/transactions/$id';

  // ─── Repayments ─────────────────────────────────────────────────────────────
  static const String repayments = '/repayments';
  static String repaymentById(int id) => '/repayments/$id';

  // ─── Debts ──────────────────────────────────────────────────────────────────
  static String debtById(int id) => '/debts/$id';

  // ─── Settings ───────────────────────────────────────────────────────────────
  static const String settings = '/settings';
  static String settingByKey(String key) => '/settings/$key';

  // ─── Notifications ───────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationMarkRead(String key) => '/notifications/$key/read';
}
