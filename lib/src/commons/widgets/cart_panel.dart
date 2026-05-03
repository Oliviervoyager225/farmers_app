import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/transaction.dart';
import '../utils/currency_utils.dart';
import '../../providers/cart_provider.dart';
import '../../providers/farmer_provider.dart';
// ── Design tokens ─────────────────────────────────────────────────────────────
const _kGreen    = Color(0xFF16A34A);
const _kGreenBg  = Color(0xFFF0FDF4);
const _kRed      = Color(0xFFDC2626);
const _kBorder   = Color(0xFFE5E7EB);
const _kBg       = Color(0xFFF9FAFB);
const _kTitle    = Color(0xFF111827);
const _kMuted    = Color(0xFF6B7280);

/// Opens the cart panel as a right-side overlay (matches notification panel UX).
void showCartPanel(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cart',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, __) => const _CartPanelRoot(),
    transitionBuilder: (ctx, anim, _, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
      return SlideTransition(position: slide, child: child);
    },
  );
}

class _CartPanelRoot extends StatelessWidget {
  const _CartPanelRoot();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        elevation: 16,
        color: Colors.white,
        child: SizedBox(
          width: _panelWidth(context),
          height: double.infinity,
          child: Column(
            children: [
              _CartHeader(onClose: () => Navigator.of(context).pop()),
              const Divider(height: 1, color: _kBorder),
              const Expanded(child: _CartBody()),
            ],
          ),
        ),
      ),
    );
  }

  double _panelWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 480) return w * 0.92;
    if (w < 900) return 380;
    return 420;
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _CartHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _CartHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _kGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Panier',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kTitle)),
                Text(
                  cart.itemCount == 0
                      ? 'Vide'
                      : '${cart.itemCount} article${cart.itemCount > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 12, color: _kMuted),
                ),
              ],
            ),
          ),
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => context.read<CartProvider>().clear(),
              style: TextButton.styleFrom(
                foregroundColor: _kRed,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                textStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: const Text('Vider'),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: _kMuted),
            onPressed: onClose,
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _CartBody extends StatelessWidget {
  const _CartBody();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (cart.isEmpty) return const _EmptyCart();

    return Column(
      children: [
        // Items list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 20, endIndent: 20, color: _kBorder),
            itemBuilder: (_, i) => _CartItemTile(item: cart.items[i]),
          ),
        ),
        // Footer
        const Divider(height: 1, color: _kBorder),
        const _CartFooter(),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: _kBg, shape: BoxShape.circle),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 40, color: _kMuted),
            ),
            const SizedBox(height: 20),
            const Text('Votre panier est vide',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kTitle)),
            const SizedBox(height: 6),
            const Text(
              'Ajoutez des produits depuis le Marketplace.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _kMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/products');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.storefront_outlined, size: 16),
              label: const Text('Browse Marketplace',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cart item tile ────────────────────────────────────────────────────────────

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(Icons.grass_outlined,
                size: 26, color: _kGreen),
          ),
          const SizedBox(width: 12),
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kTitle),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${CurrencyUtils.format(item.product.price)} / unité',
                  style:
                      const TextStyle(fontSize: 11, color: _kMuted),
                ),
                const SizedBox(height: 6),
                // Subtotal
                Text(
                  CurrencyUtils.format(item.subtotal),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kGreen),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Qty controls
          Column(
            children: [
              _QtyBtn(
                icon: Icons.add,
                onTap: () => cart.addProduct(item.product),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('${item.quantity}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              _QtyBtn(
                icon: Icons.remove,
                onTap: () =>
                    cart.updateQuantity(item.product.id, item.quantity - 1),
              ),
            ],
          ),
          const SizedBox(width: 4),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () => cart.removeProduct(item.product.id),
            color: _kRed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: _kBorder),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Icon(icon, size: 14, color: _kTitle),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _CartFooter extends StatelessWidget {
  const _CartFooter();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final farmer = context.watch<FarmerProvider>().selected;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Payment type ──────────────────────────────────────────────────
          const Text('Mode de paiement',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kMuted)),
          const SizedBox(height: 8),
          Row(
            children: [
              _PayChip(
                label: '💵  Espèces',
                selected: cart.paymentType == PaymentType.cash,
                color: _kGreen,
                onTap: () =>
                    cart.setPaymentType(PaymentType.cash),
              ),
              const SizedBox(width: 8),
              _PayChip(
                label: '📋  Crédit',
                selected: cart.paymentType == PaymentType.credit,
                color: const Color(0xFFD97706),
                onTap: () =>
                    cart.setPaymentType(PaymentType.credit),
              ),
            ],
          ),

          // ── Interest rate (credit only) ──────────────────────────────────
          if (cart.paymentType == PaymentType.credit) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Taux intérêt :',
                    style:
                        TextStyle(fontSize: 12, color: _kMuted)),
                const SizedBox(width: 8),
                for (final rate in [0.10, 0.20, 0.30, 0.40])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => cart.setInterestRate(rate),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cart.interestRate == rate
                              ? const Color(0xFFFFFBEB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: cart.interestRate == rate
                                ? const Color(0xFFD97706)
                                : _kBorder,
                            width:
                                cart.interestRate == rate ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          '${(rate * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cart.interestRate == rate
                                ? const Color(0xFFD97706)
                                : _kMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          const Divider(color: _kBorder, height: 1),
          const SizedBox(height: 12),

          // ── Totals ────────────────────────────────────────────────────────
          _Row('Sous-total',
              CurrencyUtils.format(cart.subtotal)),
          if (cart.paymentType == PaymentType.credit) ...[
            const SizedBox(height: 4),
            _Row(
              'Intérêts (${(cart.interestRate * 100).toInt()}%)',
              CurrencyUtils.format(cart.interestAmount),
              valueColor: const Color(0xFFD97706),
            ),
          ],
          const SizedBox(height: 8),
          _Row(
            'TOTAL',
            CurrencyUtils.format(cart.total),
            bold: true,
            fontSize: 16,
          ),
          const SizedBox(height: 16),

          // ── Farmer badge ──────────────────────────────────────────────────
          if (farmer != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _kGreenBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kGreen.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: _kGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      farmer.fullName,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kGreen),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFD97706).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 16,
                      color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Sélectionnez un agriculteur avant de passer à la caisse.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

          // ── Checkout button ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: farmer == null
                  ? () {
                      Navigator.of(context).pop();
                      context.go('/farmers');
                    }
                  : () {
                      Navigator.of(context).pop();
                      context.go('/checkout?farmer_id=${farmer.id}');
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: Icon(
                farmer == null
                    ? Icons.person_search_outlined
                    : Icons.point_of_sale_outlined,
                size: 18,
              ),
              label: Text(
                farmer == null
                    ? 'Choisir un agriculteur'
                    : 'Passer à la caisse',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _PayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _PayChip(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : _kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? color : _kMuted,
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final double fontSize;
  final Color? valueColor;
  const _Row(this.label, this.value,
      {this.bold = false, this.fontSize = 13, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: bold ? _kTitle : _kMuted,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value,
            style: style.copyWith(
              color: valueColor ?? (bold ? _kGreen : _kMuted),
            )),
      ],
    );
  }
}
