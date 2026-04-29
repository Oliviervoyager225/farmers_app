class Repayment {
  final int id;
  final int farmerId;
  final double kgReceived;
  final double ratePerKg; // FCFA per kg
  final double fcfaValue;
  final List<int> debtIds; // transactions impactées
  final DateTime createdAt;

  const Repayment({
    required this.id,
    required this.farmerId,
    required this.kgReceived,
    required this.ratePerKg,
    required this.fcfaValue,
    required this.debtIds,
    required this.createdAt,
  });

  factory Repayment.fromJson(Map<String, dynamic> json) => Repayment(
        id: json['id'] as int,
        farmerId: json['farmer_id'] as int,
        kgReceived: (json['kg_received'] as num).toDouble(),
        ratePerKg: (json['rate_per_kg'] as num).toDouble(),
        fcfaValue: (json['fcfa_value'] as num).toDouble(),
        debtIds: (json['debt_ids'] as List<dynamic>? ?? [])
            .map((e) => e as int)
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
