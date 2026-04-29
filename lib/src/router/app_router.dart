import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../features/auth/pages/login_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/home/pages/home_shell.dart';
import '../features/farmers/pages/farmers_list_page.dart';
import '../features/farmers/pages/farmer_create_page.dart';
import '../features/farmers/pages/farmer_detail_page.dart';
import '../features/products/pages/products_page.dart';
import '../features/checkout/pages/checkout_page.dart';
import '../features/checkout/pages/checkout_success_page.dart';
import '../features/debts/pages/debts_page.dart';
import '../features/debts/pages/repayment_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/analytics/pages/analytics_page.dart';

class AppRouter {
  static GoRouter router(AuthProvider auth) => GoRouter(
        initialLocation: '/',
        redirect: (context, state) {
          final loggedIn = auth.isAuthenticated;
          final isLogin = state.matchedLocation == '/login';
          final isUnknown = auth.status == AuthStatus.unknown;

          if (isUnknown) return null;
          if (!loggedIn && !isLogin) return '/login';
          if (loggedIn && isLogin) return '/';
          return null;
        },
        refreshListenable: auth,
        routes: [
          GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
          ShellRoute(
            builder: (context, state, child) => HomeShell(child: child),
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const HomePage(),
              ),
              GoRoute(
                path: '/farmers',
                builder: (_, __) => const FarmersListPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, __) => const FarmerCreatePage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => FarmerDetailPage(
                      farmerId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/products',
                builder: (_, __) => const ProductsPage(),
              ),
              GoRoute(
                path: '/analytics',
                builder: (_, __) => const AnalyticsPage(),
              ),
              GoRoute(
                path: '/dashboard',
                builder: (_, __) => const DashboardPage(),
              ),
              GoRoute(
                path: '/checkout',
                builder: (context, state) {
                  final farmerId =
                      int.parse(state.uri.queryParameters['farmer_id']!);
                  return CheckoutPage(farmerId: farmerId);
                },
              ),
              GoRoute(
                path: '/checkout/success',
                builder: (_, state) {
                  final txId =
                      int.parse(state.uri.queryParameters['tx_id']!);
                  return CheckoutSuccessPage(transactionId: txId);
                },
              ),
              GoRoute(
                path: '/debts',
                builder: (_, __) => const DebtsPage(),
                routes: [
                  GoRoute(
                    path: 'repay/:farmerId',
                    builder: (context, state) => RepaymentPage(
                      farmerId:
                          int.parse(state.pathParameters['farmerId']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
}
