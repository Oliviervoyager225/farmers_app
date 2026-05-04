class Farmer {
  final int id;
  final String identifier;
  final String firstName;
  final String lastName;
  final String? phone;
  final double creditLimit;
  final double currentDebt;
  final List<String> specialties;
  final List<String> categories;

  const Farmer({
    required this.id,
    required this.identifier,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.creditLimit,
    this.currentDebt = 0,
    this.specialties = const [],
    this.categories = const [],
  });

  String get fullName => '$firstName $lastName';
  double get availableCredit => creditLimit - currentDebt;
  bool get hasCredit => availableCredit > 0;

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
        id: json['id'] as int,
        identifier: json['identifier'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        phone: json['phone'] as String?,
        creditLimit: (json['credit_limit'] as num).toDouble(),
        currentDebt: (json['current_debt'] as num? ?? 0).toDouble(),
        specialties: (json['specialties'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        categories: (json['categories'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}

class FarmerDebtSummary {
  final double totalDebt;
  final double totalPaid;
  final double remaining;
  final List<DebtItem> openDebts;

  const FarmerDebtSummary({
    required this.totalDebt,
    required this.totalPaid,
    required this.remaining,
    required this.openDebts,
  });

  factory FarmerDebtSummary.fromJson(Map<String, dynamic> json) =>
      FarmerDebtSummary(
        totalDebt: (json['total_debt'] as num).toDouble(),
        totalPaid: (json['total_paid'] as num).toDouble(),
        remaining: (json['remaining'] as num).toDouble(),
        openDebts: (json['open_debts'] as List<dynamic>? ?? [])
            .map((e) => DebtItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class DebtItem {
  final int transactionId;
  final double amount;
  final double paid;
  final double balance;
  final DateTime date;

  const DebtItem({
    required this.transactionId,
    required this.amount,
    required this.paid,
    required this.balance,
    required this.date,
  });

  factory DebtItem.fromJson(Map<String, dynamic> json) => DebtItem(
        transactionId: json['transaction_id'] as int,
        amount: (json['amount'] as num).toDouble(),
        paid: (json['paid'] as num).toDouble(),
        balance: (json['balance'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
      );
}
