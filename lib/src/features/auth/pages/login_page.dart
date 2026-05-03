import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../commons/widgets/widgets.dart';
import '../../../commons/utils/extensions.dart';
import '../../../commons/utils/responsive.dart';
import '../../../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (mounted) {
      if (ok) {
        context.go('/');
      } else {
        context.showSnackError(auth.error ?? 'Erreur de connexion');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Couche 1 : image de fond ──────────────────────────────
          Image.asset(
            'assets/images/font accueil 3.png',
            fit: BoxFit.cover,
          ),

          // ── Couche 2 : bloc de connexion (inchangé) ───────────────
          Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo / Titre
                    Icon(Icons.agriculture,
                        size: 64, color: AppTheme.primaryGreen),
                    const SizedBox(height: 8),
                    Text(
                      'Farmers POS',
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Côte d\'Ivoire',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // Email
                    AppTextField(
                      label: 'Email',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Champ requis';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mot de passe
                    AppTextField(
                      label: 'Mot de passe',
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Champ requis';
                        if (v.length < 6) return '6 caractères minimum';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Bouton connexion
                    SizedBox(
                      height: 48,
                      child: AppButton(
                        label: 'Se connecter',
                        isLoading: auth.loading,
                        onPressed: _submit,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),  // ConstrainedBox
        ),
        ),  // Center
        ],  // Stack children
      ),  // Stack
    );
  }
}
