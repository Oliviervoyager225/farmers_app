class Repayment {
  final int id;
  final int farmerId;
  final String farmerName;
  final String commodity;
  final double kgReceived;
  final double ratePerKg;
  final double fcfaValue;
  final int operatorId;
  final String operatorName;
  final String operatorRole;
  final List<int> debtIds;
  final DateTime createdAt;

  const Repayment({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.commodity,
    required this.kgReceived,
    required this.ratePerKg,
    required this.fcfaValue,
    required this.operatorId,
    required this.operatorName,
    required this.operatorRole,
    required this.debtIds,
    required this.createdAt,
  });

  factory Repayment.fromJson(Map<String, dynamic> json) => Repayment(
        id: json['id'] as int,
        farmerId: json['farmer_id'] as int,
        farmerName: (json['farmer_name'] as String?) ?? '',
        commodity: (json['commodity'] as String?) ?? 'Récolte',
        kgReceived: (json['kg_received'] as num).toDouble(),
        ratePerKg: (json['rate_per_kg'] as num).toDouble(),
        fcfaValue: (json['fcfa_value'] as num).toDouble(),
        operatorId: json['operator_id'] as int? ?? 0,
        operatorName: (json['operator_name'] as String?) ?? '',
        operatorRole: (json['operator_role'] as String?) ?? '',
        debtIds: (json['debt_ids'] as List<dynamic>? ?? [])
            .map((e) => e as int)
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
