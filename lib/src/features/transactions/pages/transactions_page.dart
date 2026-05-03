import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/activity_provider.dart';
import '../../../commons/data/models/activity_entry.dart';
import '../../../commons/data/models/transaction.dart';
import '../../../commons/data/models/repayment.dart';
import '../../../commons/utils/currency_utils.dart';
import '../../../commons/utils/date_utils.dart' as du;
import '../../../commons/widgets/widgets.dart';
import '../../../theme/app_theme.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Activité',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.foreground)),
                      Text(
                        '${provider.entries.length} opération(s) au total',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.mutedFg),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => provider.reload(),
                  tooltip: 'Actualiser',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderColor),
          Expanded(
            child: provider.loading && provider.entries.isEmpty
                ? const ListShimmer()
                : provider.error != null && provider.entries.isEmpty
                    ? ErrorView(
                        message: provider.error!,
                        onRetry: () => provider.reload(),
                      )
                    : provider.entries.isEmpty
                        ? const EmptyView(
                            message: 'Aucune opération enregistrée',
                            icon: Icons.receipt_long_outlined,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.entries.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final entry = provider.entries[i];
                              return switch (entry) {
                                PurchaseEntry(:final transaction) =>
                                  _PurchaseCard(transaction: transaction),
                                RepaymentEntry(:final repayment) =>
                                  _RepaymentCard(repayment: repayment),
                              };
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Purchase card ─────────────────────────────────────────────────────────────

class _PurchaseCard extends StatelessWidget {
  final Transaction transaction;
  const _PurchaseCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCash = transaction.paymentType == PaymentType.cash;
    final typeColor = isCash ? AppTheme.cashGreen : AppTheme.creditRed;
    final typeLabel = isCash ? 'Espèces' : 'Crédit';
    final typeIcon =
        isCash ? Icons.payments_outlined : Icons.credit_card_outlined;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/transactions/${transaction.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.farmerName.isNotEmpty
                              ? transaction.farmerName
                              : 'Agriculteur #${transaction.farmerId}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.foreground),
                        ),
                        Text(
                          du.DateUtils.formatDate(transaction.createdAt),
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.mutedFg),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyUtils.format(transaction.total),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: typeColor),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(typeLabel,
                            style: TextStyle(
                                fontSize: 11,
                                color: typeColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
              if (transaction.items.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ...transaction.items.take(3).map((item) => _Chip(
                          '${item.quantity}× ${item.productName}',
                        )),
                    if (transaction.items.length > 3)
                      _Chip('+${transaction.items.length - 3} autre(s)'),
                  ],
                ),
              ],
              if (transaction.operatorName.isNotEmpty) ...[
                const SizedBox(height: 8),
                _AuditRow(
                  name: transaction.operatorName,
                  role: transaction.operatorRole,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Repayment card ─────────────────────────────────────────────────────────────

class _RepaymentCard extends StatelessWidget {
  final Repayment repayment;
  const _RepaymentCard({required this.repayment});

  static const _repayColor = Color(0xFF7C3AED); // purple

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _repayColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.agriculture_outlined,
                        color: _repayColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          repayment.farmerName.isNotEmpty
                              ? repayment.farmerName
                              : 'Agriculteur #${repayment.farmerId}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.foreground),
                        ),
                        Text(
                          du.DateUtils.formatDate(repayment.createdAt),
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.mutedFg),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyUtils.format(repayment.fcfaValue),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _repayColor),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _repayColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Remboursement',
                            style: TextStyle(
                                fontSize: 11,
                                color: _repayColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Chip(repayment.commodity),
                  const SizedBox(width: 6),
                  _Chip(
                      '${repayment.kgReceived.toStringAsFixed(1)} kg × ${CurrencyUtils.format(repayment.ratePerKg)}/kg'),
                ],
              ),
              if (repayment.operatorName.isNotEmpty) ...[
                const SizedBox(height: 8),
                _AuditRow(
                  name: repayment.operatorName,
                  role: repayment.operatorRole,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remboursement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Agriculteur',
                repayment.farmerName.isNotEmpty
                    ? repayment.farmerName
                    : '#${repayment.farmerId}'),
            _DetailRow('Produit', repayment.commodity),
            _DetailRow('Quantité', '${repayment.kgReceived.toStringAsFixed(2)} kg'),
            _DetailRow('Taux / kg', CurrencyUtils.format(repayment.ratePerKg)),
            _DetailRow('Total crédité', CurrencyUtils.format(repayment.fcfaValue)),
            if (repayment.operatorName.isNotEmpty)
              _DetailRow('Opérateur',
                  '${repayment.operatorName} (${repayment.operatorRole})'),
            _DetailRow('Date',
                du.DateUtils.formatDate(repayment.createdAt)),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

// ── Shared small widgets ───────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.muted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 11, color: AppTheme.mutedFg)),
    );
  }
}

class _AuditRow extends StatelessWidget {
  final String name;
  final String role;
  const _AuditRow({required this.name, required this.role});

  static const _roleColors = {
    'admin': Color(0xFFDC2626),
    'supervisor': Color(0xFF0891B2),
    'operator': Color(0xFF16A34A),
  };

  @override
  Widget build(BuildContext context) {
    final color = _roleColors[role] ?? AppTheme.mutedFg;
    return Row(
      children: [
        Icon(Icons.person_outline, size: 12, color: AppTheme.mutedFg),
        const SizedBox(width: 4),
        Text(name,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.mutedFg)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(role,
              style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.mutedFg)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.foreground)),
          ),
        ],
      ),
    );
  }
}
