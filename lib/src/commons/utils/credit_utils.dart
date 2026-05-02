/// Calcule le total TTC d'un crédit avec intérêts.
double applyInterest(double amount, double rate) => amount * (1 + rate);

/// Convertit des kg en FCFA selon le taux configuré.
double kgToFcfa(double kg, double ratePerKg) => kg * ratePerKg;

/// Vérifie si un nouveau crédit dépasse le plafond autorisé.
bool exceedsCreditLimit({
  required double currentDebt,
  required double newAmount,
  required double creditLimit,
}) => (currentDebt + newAmount) > creditLimit;
