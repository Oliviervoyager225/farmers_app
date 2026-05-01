import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/farmer_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../commons/data/models/transaction.dart';
import '../../../commons/utils/currency_utils.dart';
import '../../../commons/utils/credit_utils.dart';
import '../../../commons/widgets/widgets.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/network/api_exception.dart';
import '../../../commons/utils/extensions.dart';
import '../../../theme/app_theme.dart';

class CheckoutPage extends StatefulWidget {
  final int farmerId;

  const CheckoutPage({super.key, required this.farmerId});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fp = context.read<FarmerProvider>();
      final sp = context.read<SettingsProvider>();
      if (fp.selected?.id != widget.farmerId) {
        await fp.selectFarmer(widget.farmerId);
      }
      if (sp.settings == null) sp.load();

      // Appliquer le taux d'intérêt depuis les paramètres
      if (sp.settings != null) {
        context
            .read<CartProvider>()
            .setInterestRate(sp.settings!.defaultInterestRate);
      }
    });
  }

  Future<void> _confirm() async {
    final cart = context.read<CartProvider>();
    final farmer = context.read<FarmerProvider>().selected;
    if (farmer == null) return;

    // Vérification plafond crédit
    if (cart.paymentType == PaymentType.credit) {
      if (exceedsCreditLimit(
        currentDebt: farmer.currentDebt,
        newAmount: cart.total,
        creditLimit: farmer.creditLimit,
      )) {
        context.showSnackError(
            'Transaction refusée : plafond de crédit dépassé\n'
            'Disponible : ${CurrencyUtils.format(farmer.availableCredit)}');
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final service = context.read<TransactionService>();
      final payload = cart.toOrderPayload(farmer.id);
      final tx = await service.create(payload);
      cart.clear();
      if (mounted) {
        context.go('/checkout/success?tx_id=${tx.id}');
      }
    } on ApiException catch (e) {
      if (mounted) context.showSnackError(e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final farmer = context.watch<FarmerProvider>().selected;
    context.watch<SettingsProvider>(); // écoute les changements de settings

    return Scaffold(
      appBar: AppBar(title: const Text('Validation commande')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agriculteur
            if (farmer != null)
              Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.person, color: AppTheme.primaryGreen),
                  title: Text(farmer.fullName,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Crédit disponible : ${CurrencyUtils.format(farmer.availableCredit)}'),
                  trailing: StatusBadge(
                    label: farmer.availableCredit > 0 ? 'OK' : 'Plafond atteint',
                    color: farmer.availableCredit > 0
                        ? AppTheme.cashGreen
                        : AppTheme.creditRed,
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
            ...cart.items.map((item) => Card(
                  child: ListTile(
                    title: Text(item.product.name),
                    subtitle: Text(
                        '${item.quantity} × ${CurrencyUtils.format(item.product.price)}'),
                    trailing: Text(
                      CurrencyUtils.format(item.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
            const SizedBox(height: 16),

            // Type paiement
            Text('Mode de paiement',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PaymentChip(
                    label: 'Espèces',
                    icon: Icons.payments,
                    selected: cart.paymentType == PaymentType.cash,
                    color: AppTheme.cashGreen,
                    onTap: () =>
                        cart.setPaymentType(PaymentType.cash),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PaymentChip(
                    label: 'Crédit',
                    icon: Icons.credit_card,
                    selected: cart.paymentType == PaymentType.credit,
                    color: AppTheme.creditRed,
                    onTap: () =>
                        cart.setPaymentType(PaymentType.credit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Résumé
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SummaryRow('Sous-total',
                        CurrencyUtils.format(cart.subtotal)),
                    if (cart.paymentType == PaymentType.credit) ...[
                      _SummaryRow(
                        'Intérêts (${(cart.interestRate * 100).toStringAsFixed(0)}%)',
                        CurrencyUtils.format(cart.interestAmount),
                        color: AppTheme.creditRed,
                      ),
                      if (farmer != null &&
                          exceedsCreditLimit(
                            currentDebt: farmer.currentDebt,
                            newAmount: cart.total,
                            creditLimit: farmer.creditLimit,
                          ))
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(Icons.warning,
                                  color: AppTheme.creditRed, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Plafond dépassé !',
                                style: TextStyle(
                                    color: AppTheme.creditRed,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const Divider(),
                    _SummaryRow('TOTAL À PAYER',
                        CurrencyUtils.format(cart.total),
                        bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            AppButton(
              label: 'Confirmer la vente',
              icon: Icons.check_circle,
              isLoading: _submitting,
              onPressed: cart.isEmpty ? null : _confirm,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _PaymentChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? color : Colors.grey.shade300, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : Colors.grey),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: selected ? color : Colors.grey,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const _SummaryRow(this.label, this.value,
      {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal,
                  color: color,
                  fontSize: bold ? 16 : 14)),
        ],
      ),
    );
  }
}
