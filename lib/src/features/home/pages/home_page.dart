import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../commons/utils/responsive.dart';
import '../../../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroSection(),
            _StatsBanner(),
            _FeaturesSection(),
            _CtaCard(),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.pagePadding(context);

    return Container(
      color: AppTheme.background,
      padding: padding.copyWith(top: isMobile ? 32 : 64, bottom: isMobile ? 32 : 64),
      child: isMobile
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroLeft(),
                SizedBox(height: 32),
                _HeroRight(),
              ],
            )
          : const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 55, child: _HeroLeft()),
                SizedBox(width: 48),
                Expanded(flex: 45, child: _HeroRight()),
              ],
            ),
    );
  }
}

class _HeroLeft extends StatelessWidget {
  const _HeroLeft();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppTheme.primaryGreen.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('🌾', style: TextStyle(fontSize: 13)),
              SizedBox(width: 6),
              Text(
                'Plateforme POS Agricole',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Builder(builder: (ctx) {
          final fs = Responsive.isMobile(ctx) ? 28.0 : Responsive.isTablet(ctx) ? 34.0 : 42.0;
          return Text(
            'Achetez vos produits\nagricoles simplement',
            style: TextStyle(
              fontSize: fs,
              fontWeight: FontWeight.w800,
              color: AppTheme.foreground,
              height: 1.15,
            ),
          );
        }),
        const SizedBox(height: 16),
        const Text(
          'Enregistrez vos achats auprès des agriculteurs, gérez les crédits,\n'
          'suivez les dettes et pilotez vos remboursements en un seul endroit.',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.mutedFg,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _HeroButton(
              label: 'Nouvelle vente',
              primary: true,
              icon: Icons.storefront_outlined,
              onTap: (ctx) => ctx.go('/products'),
            ),
            _HeroButton(
              label: 'Voir les agriculteurs',
              primary: false,
              icon: Icons.people_outline,
              onTap: (ctx) => ctx.go('/farmers'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Trust items
        Wrap(
          spacing: 20,
          runSpacing: 8,
          children: const [
            _TrustItem(icon: Icons.security_outlined, label: 'Paiements sécurisés'),
            _TrustItem(
                icon: Icons.account_balance_wallet_outlined, label: 'Crédit contrôlé'),
            _TrustItem(
                icon: Icons.verified_outlined, label: 'Agriculteurs vérifiés'),
          ],
        ),
      ],
    );
  }
}

class _HeroButton extends StatelessWidget {
  final String label;
  final bool primary;
  final IconData icon;
  final void Function(BuildContext) onTap;
  const _HeroButton(
      {required this.label,
      required this.primary,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor:
            primary ? AppTheme.primaryGreen : Colors.transparent,
        foregroundColor: primary ? Colors.white : AppTheme.primaryGreen,
        side: BorderSide(
          color: primary ? AppTheme.primaryGreen : AppTheme.primaryGreen,
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600)),
      onPressed: () => onTap(context),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryGreen),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                color: AppTheme.mutedFg,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _HeroRight extends StatelessWidget {
  const _HeroRight();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient image placeholder
        Container(
          height: 320,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Icon(Icons.agriculture,
                size: 80, color: AppTheme.primaryGreen),
          ),
        ),
        // Floating stat card
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Achats enregistrés',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.mutedFg,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '25 M FCFA+',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const Text(
                  'Volume total traité',
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.mutedFg),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATS BANNER
// ─────────────────────────────────────────────────────────────────────────────

class _StatsBanner extends StatelessWidget {
  const _StatsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryGreen,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        runSpacing: 24,
        spacing: 48,
        children: const [
          _StatItem(value: '500+', label: 'Agriculteurs enregistrés'),
          _StatItem(value: '1 200+', label: 'Produits disponibles'),
          _StatItem(value: '8 500+', label: 'Achats complétés'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FEATURES SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  static const _features = [
    (
      Icons.point_of_sale_outlined,
      'Caisse POS intégrée',
      'Sélectionnez les produits, choisissez le mode de paiement (espèces ou crédit) et validez l\'achat en quelques secondes.'
    ),
    (
      Icons.account_balance_wallet_outlined,
      'Gestion du crédit',
      'Définissez une limite de crédit par agriculteur. Le système bloque automatiquement toute transaction qui dépasse le plafond autorisé.'
    ),
    (
      Icons.receipt_long_outlined,
      'Suivi des transactions',
      'Consultez l\'historique complet de tous les achats et remboursements, avec le profil de l\'opérateur qui a effectué chaque opération.'
    ),
    (
      Icons.agriculture_outlined,
      'Remboursements en nature',
      'Enregistrez les remboursements de dettes via les récoltes : produit, quantité en kg, taux au kg et crédit calculé automatiquement.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);
    return Container(
      color: AppTheme.background,
      padding: padding.copyWith(top: 48, bottom: 48),
      child: Column(
        children: [
          const Text(
            'Tout ce dont vous avez besoin',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.foreground,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Des outils pensés pour la gestion des achats agricoles au quotidien',
            style: TextStyle(color: AppTheme.mutedFg, fontSize: 15),
          ),
          const SizedBox(height: 40),
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth < 600
                ? 1
                : constraints.maxWidth < 960
                    ? 2
                    : 4;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                for (final f in _features)
                  _FeatureCard(icon: f.$1, title: f.$2, description: f.$3),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureCard(
      {required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 22),
          ),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.foreground)),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.mutedFg, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA CARD
// ─────────────────────────────────────────────────────────────────────────────

class _CtaCard extends StatelessWidget {
  const _CtaCard();

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);
    return Container(
      color: AppTheme.background,
      padding: padding.copyWith(top: 24, bottom: 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 40),
        child: Column(
          children: [
            const Text(
              'Prêt à enregistrer une vente ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sélectionnez un agriculteur, choisissez les produits et finalisez\nl\'achat en espèces ou à crédit en quelques clics.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => context.go('/products'),
                  child: const Text('Nouvelle vente',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => context.go('/farmers'),
                  child: const Text('Voir les agriculteurs',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOTER
// ─────────────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.foreground,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Text('FB',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              const Text('FarmBridge',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Gestion des achats de produits agricoles en Côte d\'Ivoire.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          const Text(
            '© 2026 FarmBridge. Tous droits réservés.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}


