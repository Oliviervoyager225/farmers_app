import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../commons/data/models/product.dart';
import '../../../commons/widgets/widgets.dart';
import '../../../commons/utils/currency_utils.dart';
import '../../../commons/utils/responsive.dart';
import '../../../theme/app_theme.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _cartOpen = false;
  double _minPrice = 0;
  double _maxPrice = 5000;
  bool _organicOnly = false;
  String? _sortBy = 'price_asc';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      p.loadCategories();
      p.loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();
    final isMobile = Responsive.isMobile(context);

    // sidebar widget (reused in desktop and bottom sheet)
    final sidebar = _FilterSidebar(
      categories: productProv.categories.map((c) => c.name).toList(),
      selectedCategory: productProv.selectedCategoryId != null
          ? productProv.categories
              .firstWhere(
                (c) => c.id == productProv.selectedCategoryId,
                orElse: () => productProv.categories.first,
              )
              .name
          : null,
      onCategoryChanged: (name) {
        if (name == null) {
          productProv.loadProducts();
        } else {
          final cat =
              productProv.categories.firstWhere((c) => c.name == name);
          productProv.loadProducts(categoryId: cat.id);
        }
      },
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      organicOnly: _organicOnly,
      onPriceChanged: (min, max) => setState(() {
        _minPrice = min;
        _maxPrice = max;
      }),
      onOrganicChanged: (v) => setState(() => _organicOnly = v),
      onReset: () => setState(() {
        _minPrice = 0;
        _maxPrice = 5000;
        _organicOnly = false;
        productProv.loadProducts();
      }),
    );

    // shared header row
    Widget headerRow = Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Marketplace',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.foreground)),
                Text(
                  '${productProv.products.length} crops available',
                  style:
                      const TextStyle(fontSize: 13, color: AppTheme.mutedFg),
                ),
              ],
            ),
          ),
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.tune, color: AppTheme.foreground),
              tooltip: 'Filters',
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.75,
                  maxChildSize: 0.95,
                  minChildSize: 0.4,
                  builder: (ctx, scroll) => Column(
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scroll,
                          child: sidebar,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!isMobile) ...[  
            const Text('Sort:',
                style: TextStyle(fontSize: 13, color: AppTheme.mutedFg)),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _sortBy,
              underline: const SizedBox(),
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.foreground),
              items: const [
                DropdownMenuItem(
                    value: 'price_asc',
                    child: Text('Price: Low to High')),
                DropdownMenuItem(
                    value: 'price_desc',
                    child: Text('Price: High to Low')),
                DropdownMenuItem(value: 'name', child: Text('Name A-Z')),
              ],
              onChanged: (v) => setState(() => _sortBy = v),
            ),
            const SizedBox(width: 12),
          ],
          InkWell(
            onTap: () => setState(() => _cartOpen = true),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Cart (${cart.itemCount})',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget productArea = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerRow,
        const Divider(height: 1, color: AppTheme.borderColor),
        Expanded(
          child: productProv.loading && productProv.products.isEmpty
              ? const ListShimmer()
              : productProv.error != null
                  ? ErrorView(message: productProv.error!)
                  : productProv.products.isEmpty
                      ? const EmptyView(
                          message: 'No crops available',
                          icon: Icons.inventory_2_outlined)
                      : _ProductGrid(
                          products: productProv.products,
                          onAddToCart: (p) =>
                              context.read<CartProvider>().addProduct(p),
                        ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // sidebar visible only on tablet+
              if (!isMobile) sidebar,
              // main content
              Expanded(child: productArea),
              // cart spacer
              if (_cartOpen) const SizedBox(width: 340),
            ],
          ),
          // Cart side panel
          if (_cartOpen)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: isMobile ? MediaQuery.of(context).size.width : 340,
              child: _CartPanel(
                onClose: () => setState(() => _cartOpen = false),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER SIDEBAR
// ─────────────────────────────────────────────────────────────────────────────

class _FilterSidebar extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final void Function(String?) onCategoryChanged;
  final double minPrice;
  final double maxPrice;
  final bool organicOnly;
  final void Function(double, double) onPriceChanged;
  final void Function(bool) onOrganicChanged;
  final VoidCallback onReset;

  const _FilterSidebar({
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.minPrice,
    required this.maxPrice,
    required this.organicOnly,
    required this.onPriceChanged,
    required this.onOrganicChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppTheme.borderColor)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground)),
            const SizedBox(height: 16),
            // Category
            const Text('Category',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedFg)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: const Text('All categories',
                  style: TextStyle(fontSize: 12)),
              style: const TextStyle(fontSize: 13, color: AppTheme.foreground),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                filled: true,
                fillColor: AppTheme.muted,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...categories.map((c) =>
                    DropdownMenuItem(value: c, child: Text(c))),
              ],
              onChanged: onCategoryChanged,
            ),
            const SizedBox(height: 16),
            // Max price
            const Text('Prix Max (FCFA)',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedFg)),
            const SizedBox(height: 4),
            Text('Jusqu\'à ${maxPrice.toInt()} FCFA',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.primaryGreen)),
            Slider(
              value: maxPrice,
              min: 0,
              max: 5000,
              divisions: 50,
              activeColor: AppTheme.primaryGreen,
              onChanged: (v) => onPriceChanged(minPrice, v),
            ),
            const SizedBox(height: 12),
            // Organic toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Organic only',
                    style: TextStyle(fontSize: 13, color: AppTheme.foreground)),
                Switch(
                  value: organicOnly,
                  onChanged: onOrganicChanged,
                  activeColor: AppTheme.primaryGreen,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Reset
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onReset,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.mutedFg,
                  side: const BorderSide(color: AppTheme.borderColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Reset Filters',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT GRID
// ─────────────────────────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onAddToCart;
  const _ProductGrid(
      {required this.products, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(builder: (context, constraints) {
        final cols = constraints.maxWidth < 360
            ? 1
            : constraints.maxWidth < 700
                ? 2
                : 3;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemCount: products.length,
          itemBuilder: (_, i) => _CropCard(
            product: products[i],
            colorIndex: i % _cropGradients.length,
            onAddToCart: () => onAddToCart(products[i]),
          ),
        );
      }),
    );
  }
}

const _cropGradients = [
  [Color(0xFFE8F5E9), Color(0xFFA5D6A7)],
  [Color(0xFFFFF3E0), Color(0xFFFFCC80)],
  [Color(0xFFE3F2FD), Color(0xFF90CAF9)],
  [Color(0xFFF3E5F5), Color(0xFFCE93D8)],
  [Color(0xFFE8EAF6), Color(0xFF9FA8DA)],
  [Color(0xFFFCE4EC), Color(0xFFF48FB1)],
];

// ─────────────────────────────────────────────────────────────────────────────
// CROP CARD
// ─────────────────────────────────────────────────────────────────────────────

class _CropCard extends StatefulWidget {
  final Product product;
  final int colorIndex;
  final VoidCallback onAddToCart;
  const _CropCard({
    required this.product,
    required this.colorIndex,
    required this.onAddToCart,
  });

  @override
  State<_CropCard> createState() => _CropCardState();
}

class _CropCardState extends State<_CropCard> {
  bool _fav = false;

  @override
  Widget build(BuildContext context) {
    final colors = _cropGradients[widget.colorIndex];
    final p = widget.product;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area (160px)
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Crop icon centered
                Center(
                  child: Icon(Icons.grass,
                      size: 56, color: colors.last.withOpacity(0.6)),
                ),
                // AI badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('✨ AI Recommended',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                // Fav button
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => setState(() => _fav = !_fav),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _fav ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: _fav ? Colors.red : AppTheme.mutedFg,
                      ),
                    ),
                  ),
                ),
                // Stock badge bottom-left
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('In Stock',
                        style: TextStyle(
                            color: Colors.white, fontSize: 9)),
                  ),
                ),
              ],
            ),
          ),
          // Card body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + online dot
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.foreground),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(p.categoryName ?? '',
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.mutedFg)),
                  ),
                  const Spacer(),
                  // Price
                  Text(
                    CurrencyUtils.format(p.price),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen),
                  ),
                  Text('per unit',
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.mutedFg)),
                  const SizedBox(height: 10),
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: widget.onAddToCart,
                      child: const Text('Add to Cart',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CART PANEL
// ─────────────────────────────────────────────────────────────────────────────

class _CartPanel extends StatelessWidget {
  final VoidCallback onClose;
  const _CartPanel({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    const fee = 49.0;

    return Material(
      elevation: 8,
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppTheme.borderColor)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_cart_outlined,
                        size: 18, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Cart',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.foreground)),
                        Text('${cart.itemCount} items',
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.mutedFg)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onClose,
                    color: AppTheme.mutedFg,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: cart.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 48, color: AppTheme.mutedFg),
                          SizedBox(height: 12),
                          Text('Your cart is empty',
                              style: TextStyle(color: AppTheme.mutedFg)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: AppTheme.borderColor),
                      itemBuilder: (_, i) {
                        final item = cart.items[i];
                        return _CartItem(item: item);
                      },
                    ),
            ),
            // Footer
            if (!cart.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: AppTheme.borderColor)),
                ),
                child: Column(
                  children: [
                    _CartRow(label: 'Subtotal',
                        value: CurrencyUtils.format(cart.total)),
                    const SizedBox(height: 6),
                    _CartRow(label: 'Platform fee',
                        value: CurrencyUtils.format(fee)),
                    const Divider(color: AppTheme.borderColor, height: 16),
                    _CartRow(
                      label: 'Total',
                      value: CurrencyUtils.format(cart.total + fee),
                      bold: true,
                    ),
                    const SizedBox(height: 4),
                    const Text('No hidden charges',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.mutedFg)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          // Navigate to checkout with first cart item's farmer
                          if (cart.items.isNotEmpty) {
                            context.go('/checkout?farmer_id=1');
                          }
                        },
                        child: const Text('Proceed to Payment',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartItem item;
  const _CartItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.muted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.grass,
              color: AppTheme.primaryGreen, size: 28),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.product.name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text(CurrencyUtils.format(item.product.price),
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.primaryGreen)),
            ],
          ),
        ),
        // Qty controls
        Row(
          children: [
            _QtyBtn(
              icon: Icons.remove,
              onTap: () => context
                  .read<CartProvider>()
                  .updateQuantity(item.product.id, item.quantity - 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('${item.quantity}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            _QtyBtn(
              icon: Icons.add,
              onTap: () =>
                  context.read<CartProvider>().addProduct(item.product),
            ),
          ],
        ),
        const SizedBox(width: 6),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 16),
          onPressed: () => context
              .read<CartProvider>()
              .removeProduct(item.product.id),
          color: AppTheme.creditRed,
        ),
      ],
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
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 12, color: AppTheme.foreground),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _CartRow(
      {required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.foreground)
        : const TextStyle(fontSize: 13, color: AppTheme.mutedFg);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value,
            style: style.copyWith(
                color: bold ? AppTheme.foreground : null)),
      ],
    );
  }
}

