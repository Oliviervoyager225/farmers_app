import '../../commons/data/models/user.dart';

/// Centralized permission logic derived from a user's role.
///
/// Roles:
///   admin      → full access, all actions
///   supervisor → full access, cannot add a farmer
///   operator   → full access, cannot add a farmer (same as supervisor)
class AppPermissions {
  final String role;

  const AppPermissions._({required this.role});

  factory AppPermissions.from(User? user) =>
      AppPermissions._(role: user?.role ?? 'operator');

  // ── Action visibility ──────────────────────────────────────────────────────
  bool get canAddFarmer => role == 'admin';

  // ── Route guard ────────────────────────────────────────────────────────────
  /// All authenticated roles can access all routes.
  bool canAccess(String route) => true;

  String get defaultRoute => '/';
}
