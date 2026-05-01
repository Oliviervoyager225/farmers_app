import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';

class CheckoutSuccessPage extends StatelessWidget {
  final int transactionId;

  const CheckoutSuccessPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle,
                  size: 80, color: AppTheme.cashGreen),
              const SizedBox(height: 16),
              Text(
                'Vente enregistrée !',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.cashGreen,
                    ),
              ),
              const SizedBox(height: 8),
              Text('Transaction #$transactionId',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text("Retour à l'accueil"),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/farmers'),
                icon: const Icon(Icons.people),
                label: const Text('Voir les agriculteurs'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
