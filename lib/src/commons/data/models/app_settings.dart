class AppSettings {
  final double kgToCfaRate; // 1 kg = X FCFA
  final double defaultInterestRate; // ex: 0.30 = 30%

  const AppSettings({
    required this.kgToCfaRate,
    required this.defaultInterestRate,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        kgToCfaRate: (json['kg_to_cfa_rate'] as num).toDouble(),
        defaultInterestRate:
            (json['default_interest_rate'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'kg_to_cfa_rate': kgToCfaRate,
        'default_interest_rate': defaultInterestRate,
      };

  /// Converts kg to FCFA value.
  double kgToFcfa(double kg) => kg * kgToCfaRate;
}
