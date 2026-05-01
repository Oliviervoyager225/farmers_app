import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/farmer_provider.dart';
import '../../../commons/data/models/transaction.dart';
import '../../../commons/utils/currency_utils.dart';
import '../../../commons/widgets/app_button.dart';
import '../../../theme/app_theme.dart';

class CartBottomSheet extends StatefulWidget {
  const CartBottomSheet({super.key});

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Panier',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Type de paiement
            Row(
              children: [
                const Text('Paiement : '),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Espèces'),
                  selected: cart.paymentType == PaymentType.cash,
                  selectedColor: AppTheme.cashGreen.withOpacity(0.2),
                  onSelected: (_) =>
                      cart.setPaymentType(PaymentType.cash),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Crédit'),
                  selected: cart.paymentType == PaymentType.credit,
                  selectedColor: AppTheme.creditRed.withOpacity(0.2),
                  onSelected: (_) =>
                      cart.setPaymentType(PaymentType.credit),
                ),
              ],
            ),
            const Divider(),

            // Items
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: cart.items.length,
                itemBuilder: (_, i) {
                  final item = cart.items[i];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text(
                        CurrencyUtils.format(item.product.price) + ' / unité'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              size: 20),
                          onPressed: () => cart.updateQuantity(
                              item.product.id, item.quantity - 1),
                        ),
                        Text('${item.quantity}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              size: 20),
                          onPressed: () => cart.updateQuantity(
                              item.product.id, item.quantity + 1),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),

            // Totaux
            _TotalRow('Sous-total',
                CurrencyUtils.format(cart.subtotal)),
            if (cart.paymentType == PaymentType.credit)
              _TotalRow(
                'Intérêts (${(cart.interestRate * 100).toStringAsFixed(0)}%)',
                CurrencyUtils.format(cart.interestAmount),
                color: AppTheme.creditRed,
              ),
            _TotalRow('TOTAL', CurrencyUtils.format(cart.total),
                bold: true),
            const SizedBox(height: 12),

            // Bouton Checkout
            AppButton(
              label: 'Passer à la caisse',
              icon: Icons.point_of_sale,
              onPressed: () {
                final farmer = context.read<FarmerProvider>().selected;
                if (farmer == null) {
                  Navigator.of(context).pop();
                  context.go('/farmers');
                } else {
                  Navigator.of(context).pop();
                  context.go('/checkout?farmer_id=${farmer.id}');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const _TotalRow(this.label, this.value,
      {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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
                  color: color)),
        ],
      ),
    );
  }
}
