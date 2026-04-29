import 'package:flutter/foundation.dart';
import '../commons/data/models/product.dart';
import '../commons/data/models/transaction.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  PaymentType _paymentType = PaymentType.cash;
  double _interestRate = 0.30; // 30% par défaut

  List<CartItem> get items => List.unmodifiable(_items);
  PaymentType get paymentType => _paymentType;
  double get interestRate => _interestRate;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal =>
      _items.fold(0, (sum, e) => sum + e.subtotal);

  double get interestAmount =>
      _paymentType == PaymentType.credit ? subtotal * _interestRate : 0;

  double get total => subtotal + interestAmount;

  void addProduct(Product product) {
    final idx = _items.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeProduct(int productId) {
    _items.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int qty) {
    if (qty <= 0) {
      removeProduct(productId);
      return;
    }
    final idx = _items.indexWhere((e) => e.product.id == productId);
    if (idx >= 0) {
      _items[idx].quantity = qty;
      notifyListeners();
    }
  }

  void setPaymentType(PaymentType type) {
    _paymentType = type;
    notifyListeners();
  }

  void setInterestRate(double rate) {
    _interestRate = rate;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _paymentType = PaymentType.cash;
    notifyListeners();
  }

  Map<String, dynamic> toOrderPayload(int farmerId) => {
        'farmer_id': farmerId,
        'payment_type': _paymentType == PaymentType.cash ? 'cash' : 'credit',
        'interest_rate': _paymentType == PaymentType.credit ? _interestRate : 0,
        'items': _items
            .map((e) => {
                  'product_id': e.product.id,
                  'quantity': e.quantity,
                  'unit_price': e.product.price,
                })
            .toList(),
      };
}
