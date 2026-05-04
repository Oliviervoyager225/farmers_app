import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/farmer_provider.dart';
import '../../../commons/widgets/widgets.dart';
import '../../../commons/utils/currency_utils.dart';
import '../../../commons/utils/date_utils.dart' as du;
import '../../../commons/utils/extensions.dart';
import '../../../theme/app_theme.dart';

class FarmerDetailPage extends StatefulWidget {
  final int farmerId;

  const FarmerDetailPage({super.key, required this.farmerId});

  @override
  State<FarmerDetailPage> createState() => _FarmerDetailPageState();
}

class _FarmerDetailPageState extends State<FarmerDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmerProvider>().selectFarmer(widget.farmerId);
    });
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FarmerProvider provider,
    int farmerId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'agriculteur'),
        content: const Text(
            'Cette action est irréversible. Toutes les dettes et transactions associées seront affectées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.creditRed),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await provider.deleteFarmer(farmerId);
      if (!mounted) return;
      if (ok) {
        context.showSnackSuccess('Agriculteur supprimé');
        context.go('/farmers');
      } else {
        context.showSnackError(provider.error ?? 'Erreur lors de la suppression');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmerProvider>();
    final farmer = provider.selected;
    final summary = provider.debtSummary;

    if (provider.loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (farmer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails')),
        body: ErrorView(
          message: provider.error ?? 'Agriculteur introuvable',
          onRetry: () => provider.selectFarmer(widget.farmerId),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(farmer.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Nouvelle vente',
            onPressed: () => context.go('/checkout?farmer_id=${farmer.id}'),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modifier',
            onPressed: () => context.go('/farmers/${farmer.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Supprimer',
            color: AppTheme.creditRed,
            onPressed: () => _confirmDelete(context, provider, farmer.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Infos agriculteur
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow('Identifiant', farmer.identifier),
                    _InfoRow('Téléphone', farmer.phone ?? '—'),
                    _InfoRow('Limite crédit',
                        CurrencyUtils.format(farmer.creditLimit)),
                    _InfoRow('Crédit disponible',
                        CurrencyUtils.format(farmer.availableCredit),
                        valueColor: farmer.availableCredit > 0
                            ? AppTheme.cashGreen
                            : AppTheme.creditRed),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Résumé dettes
            if (summary != null) ...[
              Text('Résumé des dettes',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DebtCard(
                      label: 'Total dette',
                      value: CurrencyUtils.format(summary.totalDebt),
                      color: AppTheme.creditRed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DebtCard(
                      label: 'Payé',
                      value: CurrencyUtils.format(summary.totalPaid),
                      color: AppTheme.cashGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DebtCard(
                      label: 'Restant',
                      value: CurrencyUtils.format(summary.remaining),
                      color: AppTheme.accentOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (summary.openDebts.isNotEmpty) ...[
                Text('Dettes ouvertes',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...summary.openDebts.map((d) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long,
                            color: AppTheme.creditRed),
                        title: Text(
                            'Transaction #${d.transactionId}'),
                        subtitle: Text(
                            du.DateUtils.formatDate(d.date)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(CurrencyUtils.format(d.balance),
                                style: const TextStyle(
                                    color: AppTheme.creditRed,
                                    fontWeight: FontWeight.bold)),
                            Text('sur ${CurrencyUtils.format(d.amount)}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    )),
              ],

              const SizedBox(height: 16),
              AppButton(
                label: 'Enregistrer un remboursement',
                icon: Icons.payments,
                onPressed: () =>
                    context.go('/debts/repay/${farmer.id}'),
                color: AppTheme.accentOrange,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DebtCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
