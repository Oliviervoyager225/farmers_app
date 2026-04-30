import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/farmer_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../commons/widgets/widgets.dart';
import '../../../commons/utils/currency_utils.dart';
import '../../../commons/utils/credit_utils.dart';
import '../../../commons/utils/extensions.dart';
import '../../../core/services/repayment_service.dart';
import '../../../core/network/api_exception.dart';
import '../../../theme/app_theme.dart';

class RepaymentPage extends StatefulWidget {
  final int farmerId;

  const RepaymentPage({super.key, required this.farmerId});

  @override
  State<RepaymentPage> createState() => _RepaymentPageState();
}

class _RepaymentPageState extends State<RepaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _kgCtrl = TextEditingController();
  bool _submitting = false;

  double get _kgValue => double.tryParse(_kgCtrl.text) ?? 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fp = context.read<FarmerProvider>();
      final sp = context.read<SettingsProvider>();
      if (fp.selected?.id != widget.farmerId) {
        await fp.selectFarmer(widget.farmerId);
      }
      if (sp.settings == null) sp.load();
    });
  }

  @override
  void dispose() {
    _kgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final settings = context.read<SettingsProvider>().settings;
    final farmer = context.read<FarmerProvider>().selected;
    if (settings == null || farmer == null) return;

    setState(() => _submitting = true);
    try {
      final fcfaValue = kgToFcfa(_kgValue, settings.kgToCfaRate);
      final service = context.read<RepaymentService>();
      await service.create({
        'farmer_id': farmer.id,
        'kg_received': _kgValue,
        'rate_per_kg': settings.kgToCfaRate,
        'fcfa_value': fcfaValue,
      });
      if (mounted) {
        context.showSnackSuccess(
            'Remboursement de ${CurrencyUtils.format(fcfaValue)} enregistré');
        context.go('/farmers/${farmer.id}');
      }
    } on ApiException catch (e) {
      if (mounted) context.showSnackError(e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmer = context.watch<FarmerProvider>().selected;
    final settings = context.watch<SettingsProvider>().settings;
    final kgRate = settings?.kgToCfaRate ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(farmer != null
            ? 'Remboursement — ${farmer.fullName}'
            : 'Remboursement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info agriculteur
            if (farmer != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Dette actuelle'),
                          Text(
                            CurrencyUtils.format(farmer.currentDebt),
                            style: const TextStyle(
                                color: AppTheme.creditRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: farmer.creditLimit > 0
                            ? farmer.currentDebt / farmer.creditLimit
                            : 0,
                        color: AppTheme.creditRed,
                        backgroundColor: Colors.grey.shade200,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500)),
                          Text(
                            CurrencyUtils.format(farmer.creditLimit),
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Taux de conversion
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppTheme.primaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '1 kg = ${CurrencyUtils.format(kgRate)}',
                    style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    '  (taux configurable)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Formulaire
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Quantité reçue (kg)',
                    controller: _kgCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    prefixIcon: const Icon(Icons.scale),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Champ requis';
                      final val = double.tryParse(v);
                      if (val == null || val <= 0) return 'Valeur invalide';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // Aperçu conversion
                  if (_kgValue > 0 && kgRate > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '${_kgValue.toStringAsFixed(2)} kg × ${CurrencyUtils.formatRaw(kgRate)}'),
                          Text(
                            '= ${CurrencyUtils.format(kgToFcfa(_kgValue, kgRate))}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.cashGreen),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  AppButton(
                    label: 'Enregistrer le remboursement',
                    icon: Icons.save,
                    isLoading: _submitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Le remboursement sera appliqué FIFO (dettes les plus anciennes en premier)',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
