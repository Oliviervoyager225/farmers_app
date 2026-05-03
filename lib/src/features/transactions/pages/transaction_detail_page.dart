import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../commons/data/models/transaction.dart';
import '../../../commons/utils/currency_utils.dart';
import '../../../commons/utils/date_utils.dart' as du;
import '../../../commons/widgets/widgets.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/network/api_exception.dart';
import '../../../theme/app_theme.dart';

class TransactionDetailPage extends StatefulWidget {
  final int transactionId;

  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  Transaction? _transaction;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = context.read<TransactionService>();
      final tx = await service.getById(widget.transactionId);
      if (mounted) setState(() => _transaction = tx);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction #${widget.transactionId}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _transaction == null
                  ? const EmptyView(
                      message: 'Transaction introuvable',
                      icon: Icons.receipt_long_outlined,
                    )
                  : _buildContent(_transaction!),
    );
  }

  Widget _buildContent(Transaction tx) {
    final isCash = tx.paymentType == PaymentType.cash;
    final typeColor = isCash ? AppTheme.cashGreen : AppTheme.creditRed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isCash ? Icons.payments : Icons.credit_card,
                          color: typeColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.farmerName.isNotEmpty
                                  ? tx.farmerName
                                  : 'Agriculteur #${tx.farmerId}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Text(
                              du.DateUtils.formatDate(tx.createdAt),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(
                        label: isCash ? 'Espèces' : 'Crédit',
                        color: typeColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Articles
          Text('Articles',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (int i = 0; i < tx.items.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.items[i].productName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              Text(
                                '${tx.items[i].quantity} × ${CurrencyUtils.format(tx.items[i].unitPrice)}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyUtils.format(tx.items[i].subtotal),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (i < tx.items.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Totaux
          Text('Récapitulatif',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SummaryRow('Sous-total', CurrencyUtils.format(tx.subtotal)),
                  if (tx.paymentType == PaymentType.credit &&
                      tx.interestAmount > 0) ...[
                    const SizedBox(height: 8),
                    _SummaryRow(
                      'Intérêts (${(tx.interestRate * 100).toStringAsFixed(0)}%)',
                      CurrencyUtils.format(tx.interestAmount),
                      valueColor: AppTheme.creditRed,
                    ),
                  ],
                  const Divider(height: 24),
                  _SummaryRow(
                    'TOTAL',
                    CurrencyUtils.format(tx.total),
                    bold: true,
                    valueColor: typeColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Audit trail
          if (tx.operatorName.isNotEmpty) ...[
            Text('Opérateur',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tx.operatorName
                            .split(' ')
                            .take(2)
                            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                            .join(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.operatorName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('Enregistré par ce compte',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    _RoleBadge(tx.operatorRole),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action
          OutlinedButton.icon(
            onPressed: () => context.go('/farmers/${tx.farmerId}'),
            icon: const Icon(Icons.person_outline),
            label: const Text('Voir le profil de l\'agriculteur'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge(this.role);

  static const _roleColors = {
    'admin': Color(0xFFDC2626),
    'supervisor': Color(0xFF0891B2),
    'operator': Color(0xFF16A34A),
  };

  @override
  Widget build(BuildContext context) {
    final color = _roleColors[role] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        role,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryRow(this.label, this.value,
      {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 15 : 14)),
        Text(value,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 16 : 14,
                color: valueColor)),
      ],
    );
  }
}
