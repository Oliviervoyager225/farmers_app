import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/farmer_provider.dart';
import '../../../commons/data/models/farmer.dart';
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
                        _DebtSummaryBanner(debtors: debtors),
                        Expanded(
                          child: ListView.builder(
                            itemCount: debtors.length,
                            itemBuilder: (_, i) =>
                                _DebtorTile(farmer: debtors[i]),
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class _DebtSummaryBanner extends StatelessWidget {
  final List<Farmer> debtors;
  const _DebtSummaryBanner({required this.debtors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.creditRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.creditRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, color: AppTheme.creditRed),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total dettes ouvertes',
                  style: TextStyle(color: Colors.grey)),
              Text(
                CurrencyUtils.format(
                    debtors.fold(0.0, (s, f) => s + f.currentDebt)),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.creditRed),
              ),
            ],
          ),
          const Spacer(),
          Text('${debtors.length} agriculteur(s)',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _DebtorTile extends StatelessWidget {
  final Farmer farmer;
  const _DebtorTile({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.creditRed.withValues(alpha: 0.1),
          child: Text(
            farmer.firstName[0].toUpperCase(),
            style: const TextStyle(
                color: AppTheme.creditRed, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(farmer.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(farmer.phone),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(CurrencyUtils.format(farmer.currentDebt),
                style: const TextStyle(
                    color: AppTheme.creditRed, fontWeight: FontWeight.bold)),
            Text('sur ${CurrencyUtils.format(farmer.creditLimit)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        onTap: () => context.go('/debts/repay/${farmer.id}'),
      ),
    );
  }
}
