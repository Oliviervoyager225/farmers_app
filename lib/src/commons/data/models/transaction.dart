enum PaymentType { cash, credit }

class TransactionItem {
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  const TransactionItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      TransactionItem(
        productId: json['product_id'] as int,
        productName: json['product_name'] as String,
        unitPrice: (json['unit_price'] as num).toDouble(),
        quantity: json['quantity'] as int,
        subtotal: (json['subtotal'] as num).toDouble(),
      );
}

class Transaction {
  final int id;
  final int farmerId;
  final String farmerName;
  final int operatorId;
  final String operatorName;
  final String operatorRole;
  final List<TransactionItem> items;
  final double subtotal;
  final double interestRate;
  final double interestAmount;
  final double total;
  final PaymentType paymentType;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.operatorId,
    required this.operatorName,
    required this.operatorRole,
    required this.items,
    required this.subtotal,
    required this.interestRate,
    required this.interestAmount,
    required this.total,
    required this.paymentType,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as int,
        farmerId: json['farmer_id'] as int,
        farmerName: json['farmer_name'] as String? ?? '',
        operatorId: json['operator_id'] as int? ?? 0,
        operatorName: json['operator_name'] as String? ?? '',
        operatorRole: json['operator_role'] as String? ?? '',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => TransactionItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal: (json['subtotal'] as num).toDouble(),
        interestRate: (json['interest_rate'] as num? ?? 0).toDouble(),
        interestAmount: (json['interest_amount'] as num? ?? 0).toDouble(),
        total: (json['total'] as num).toDouble(),
        paymentType: json['payment_type'] == 'cash'
            ? PaymentType.cash
            : PaymentType.credit,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
