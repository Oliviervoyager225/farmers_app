import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/farmer_provider.dart';
import '../../../commons/data/models/farmer.dart';
import '../../../commons/utils/extensions.dart';
import '../../../theme/app_theme.dart';

class FarmerEditPage extends StatefulWidget {
  final int farmerId;

  const FarmerEditPage({super.key, required this.farmerId});

  @override
  State<FarmerEditPage> createState() => _FarmerEditPageState();
}

class _FarmerEditPageState extends State<FarmerEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _limitCtrl = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final farmer = context.read<FarmerProvider>().selected;
      if (farmer != null) _prefill(farmer);
      _initialized = true;
    }
  }

  void _prefill(Farmer farmer) {
    _firstNameCtrl.text = farmer.firstName;
    _lastNameCtrl.text = farmer.lastName;
    _phoneCtrl.text = farmer.phone;
    _limitCtrl.text = farmer.creditLimit.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<FarmerProvider>();
    final ok = await provider.updateFarmer(widget.farmerId, {
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'credit_limit': double.tryParse(_limitCtrl.text) ?? 0,
    });
    if (mounted) {
      if (ok) {
        context.showSnackSuccess('Agriculteur mis à jour avec succès');
        context.pop();
      } else {
        context.showSnackError(provider.error ?? 'Erreur lors de la mise à jour');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<FarmerProvider>().loading;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_back,
                              size: 16, color: AppTheme.foreground),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Modifier l\'agriculteur',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.foreground)),
                          Text('Mise à jour des informations',
                              style: TextStyle(
                                  fontSize: 13, color: AppTheme.mutedFg)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Form card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Informations personnelles',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.foreground)),
                        const SizedBox(height: 16),
                        _buildRow(
                          left: _buildField(
                            label: 'Prénom *',
                            controller: _firstNameCtrl,
                            hint: 'Jean',
                            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                          ),
                          right: _buildField(
                            label: 'Nom *',
                            controller: _lastNameCtrl,
                            hint: 'Dupont',
                            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          label: 'Téléphone *',
                          controller: _phoneCtrl,
                          hint: '+225 0700000000',
                          keyboard: TextInputType.phone,
                          validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          label: 'Limite de crédit (FCFA) *',
                          controller: _limitCtrl,
                          hint: '50000',
                          keyboard: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requis';
                            if (double.tryParse(v) == null) return 'Nombre invalide';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.mutedFg,
                          side: const BorderSide(color: AppTheme.borderColor),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save, size: 16),
                        label: Text(loading ? 'Sauvegarde...' : 'Enregistrer',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        onPressed: loading ? null : _submit,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.foreground)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.mutedFg, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: validator,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildRow({required Widget left, required Widget right}) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 500) {
        return Column(children: [left, const SizedBox(height: 14), right]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 14),
          Expanded(child: right),
        ],
      );
    });
  }
}
