import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/farmer_provider.dart';
import '../../../commons/widgets/widgets.dart';
import '../../../commons/utils/currency_utils.dart';
import '../../../theme/app_theme.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmerProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmerProvider>();
    final debtors = provider.farmers
        .where((f) => f.currentDebt > 0)
        .toList()
      ..sort((a, b) => b.currentDebt.compareTo(a.currentDebt));

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des dettes')),
      body: provider.loading
          ? const ListShimmer()
          : provider.error != null
              ? ErrorView(
                  message: provider.error!,
                  onRetry: () => provider.loadAll(),
                )
              : debtors.isEmpty
                  ? const EmptyView(
                      message: 'Aucune dette ouverte',
                      icon: Icons.check_circle_outline,
                    )
                  : Column(
                      children: [
                        // Résumé global
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.creditRed.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.creditRed.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance_wallet,
                                  color: AppTheme.creditRed),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total dettes ouvertes',
                                      style: TextStyle(color: Colors.grey)),
                                  Text(
                                    CurrencyUtils.format(
                                      debtors.fold(
                                          0.0, (s, f) => s + f.currentDebt),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.creditRed,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                '${debtors.length} agriculteur(s)',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        // Liste
                        Expanded(
                          child: ListView.builder(
                            itemCount: debtors.length,
                            itemBuilder: (_, i) {
                              final f = debtors[i];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppTheme.creditRed.withOpacity(0.1),
                                    child: Text(
                                      f.firstName[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: AppTheme.creditRed,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(f.fullName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(f.phone),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CurrencyUtils.format(f.currentDebt),
                                        style: const TextStyle(
                                            color: AppTheme.creditRed,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'sur ${CurrencyUtils.format(f.creditLimit)}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  onTap: () =>
                                      context.go('/debts/repay/${f.id}'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
