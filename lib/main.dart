import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/core/network/api_client.dart';
import 'src/core/services/services.dart';
import 'src/providers/providers.dart';
import 'src/router/app_router.dart';
import 'src/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const FarmersApp());
}

class FarmersApp extends StatelessWidget {
  const FarmersApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        // ── Services ─────────────────────────────────────────────────────────
        Provider<AuthService>(create: (_) => AuthService(apiClient)),
        Provider<FarmerService>(create: (_) => FarmerService(apiClient)),
        Provider<ProductService>(create: (_) => ProductService(apiClient)),
        Provider<TransactionService>(
            create: (_) => TransactionService(apiClient)),
        Provider<RepaymentService>(
            create: (_) => RepaymentService(apiClient)),
        Provider<SettingsService>(
            create: (_) => SettingsService(apiClient)),
        Provider<UserService>(create: (_) => UserService(apiClient)),
        Provider<NotificationService>(
            create: (_) => NotificationService(apiClient)),

        // ── State providers ──────────────────────────────────────────────────
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) =>
              AuthProvider(ctx.read<AuthService>())..init(),
        ),
        ChangeNotifierProvider<FarmerProvider>(
          create: (ctx) => FarmerProvider(ctx.read<FarmerService>()),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (ctx) => ProductProvider(ctx.read<ProductService>()),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (ctx) => SettingsProvider(ctx.read<SettingsService>()),
        ),
        ChangeNotifierProvider<TransactionProvider>(
          create: (ctx) =>
              TransactionProvider(ctx.read<TransactionService>()),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (ctx) => UserProvider(ctx.read<UserService>()),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (ctx) => NotificationProvider(ctx.read<NotificationService>()),
        ),
        ChangeNotifierProvider<ActivityProvider>(
          create: (ctx) => ActivityProvider(
            ctx.read<TransactionService>(),
            ctx.read<RepaymentService>(),
          ),
        ),
      ],
      child: const _AppWithRouter(),
    );
  }
}

class _AppWithRouter extends StatefulWidget {
  const _AppWithRouter();

  @override
  State<_AppWithRouter> createState() => _AppWithRouterState();
}

class _AppWithRouterState extends State<_AppWithRouter> {
  late final _router =
      AppRouter.router(context.read<AuthProvider>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Farmers POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
