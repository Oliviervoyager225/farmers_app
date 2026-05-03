import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/farmer_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../commons/utils/currency_utils.dart';
import '../../../commons/utils/extensions.dart';
import '../../../core/services/repayment_service.dart';
import '../../../core/network/api_exception.dart';
import '../../../theme/app_theme.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kGreen  = AppTheme.primaryGreen;
const _kRed    = AppTheme.creditRed;
const _kBorder = AppTheme.borderColor;
const _kMuted  = AppTheme.mutedFg;

// Common commodities for quick-select chips
const _kCommodities = [
  'Cacao', 'Maïs', 'Café', 'Arachide', 'Coton',
  'Riz', 'Manioc', 'Igname', 'Palmier', 'Anacarde',
];

class RepaymentPage extends StatefulWidget {
  final int farmerId;
  const RepaymentPage({super.key, required this.farmerId});

  @override
  State<RepaymentPage> createState() => _RepaymentPageState();
}

class _RepaymentPageState extends State<RepaymentPage> {
  final _formKey   = GlobalKey<FormState>();
  final _commodityCtrl = TextEditingController();
  final _rateCtrl      = TextEditingController();
  final _kgCtrl        = TextEditingController();
  bool _submitting = false;

  double get _rate => double.tryParse(
        _rateCtrl.text.replaceAll(' ', '').replaceAll(',', '.'),
      ) ??
      0;
  double get _kg => double.tryParse(
        _kgCtrl.text.replaceAll(' ', '').replaceAll(',', '.'),
      ) ??
      0;
  double get _total => _kg > 0 && _rate > 0 ? _kg * _rate : 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fp = context.read<FarmerProvider>();
      final sp = context.read<SettingsProvider>();
      if (fp.selected?.id != widget.farmerId) {
        await fp.selectFarmer(widget.farmerId);
      }
      if (sp.settings == null) await sp.load();
      // Pre-fill rate with global setting
      if (mounted && _rateCtrl.text.isEmpty) {
        final rate = context.read<SettingsProvider>().settings?.kgToCfaRate;
        if (rate != null && rate > 0) {
          _rateCtrl.text = rate.toStringAsFixed(0);
        }
      }
    });
  }

  @override
  void dispose() {
    _commodityCtrl.dispose();
    _rateCtrl.dispose();
    _kgCtrl.dispose();
    super.dispose();
  }

  void _selectCommodity(String name) {
    setState(() => _commodityCtrl.text = name);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final farmer = context.read<FarmerProvider>().selected;
    if (farmer == null) return;

    setState(() => _submitting = true);
    try {
      final service = context.read<RepaymentService>();
      await service.create({
        'farmer_id':   farmer.id,
        'commodity':   _commodityCtrl.text.trim(),
        'kg_received': _kg,
        'rate_per_kg': _rate,
        'fcfa_value':  _total,
      });
      if (mounted) {
        context.showSnackSuccess(
          'Remboursement de ${CurrencyUtils.format(_total)} enregistré pour ${_commodityCtrl.text.trim()}',
        );
        context.go('/debts');
      }
    } on ApiException catch (e) {
      if (mounted) context.showSnackError(e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmer   = context.watch<FarmerProvider>().selected;
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: _kBorder,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.foreground),
          onPressed: () => context.go('/debts'),
        ),
        title: Text(
          farmer != null
              ? 'Remboursement — ${farmer.fullName}'
              : 'Remboursement',
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.foreground),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Farmer debt card ───────────────────────────────────────────
              if (farmer != null) _DebtStatusCard(farmer: farmer),
              const SizedBox(height: 24),

              // ── Commodity ─────────────────────────────────────────────────
              _SectionLabel(label: 'Produit / culture'),
              const SizedBox(height: 8),
              _CommodityField(
                controller: _commodityCtrl,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              _CommodityChips(
                selected: _commodityCtrl.text,
                onTap: _selectCommodity,
              ),
              const SizedBox(height: 20),

              // ── Rate per kg ────────────────────────────────────────────────
              Row(
                children: [
                  const _SectionLabel(label: 'Prix par kg (FCFA)'),
                  const Spacer(),
                  if (settings != null && settings.kgToCfaRate > 0)
                    GestureDetector(
                      onTap: () => setState(() =>
                          _rateCtrl.text =
                              settings.kgToCfaRate.toStringAsFixed(0)),
                      child: Text(
                        'Taux global : ${CurrencyUtils.format(settings.kgToCfaRate)}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: _kGreen,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _NumberField(
                controller: _rateCtrl,
                hint: 'ex : 1 500',
                prefix: const Icon(Icons.currency_franc, size: 18),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  final val = double.tryParse(
                      v.replaceAll(' ', '').replaceAll(',', '.'));
                  if (val == null || val < 1) return 'Valeur invalide (min 1)';
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // ── Quantity ──────────────────────────────────────────────────
              const _SectionLabel(label: 'Quantité reçue (kg)'),
              const SizedBox(height: 8),
              _NumberField(
                controller: _kgCtrl,
                hint: 'ex : 42.5',
                prefix: const Icon(Icons.scale_outlined, size: 18),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  final val = double.tryParse(
                      v.replaceAll(' ', '').replaceAll(',', '.'));
                  if (val == null || val <= 0) return 'Valeur invalide';
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // ── Live calculation preview ──────────────────────────────────
              if (_kg > 0 && _rate > 0) ...[
                _CalculationPreview(
                  kg: _kg,
                  rate: _rate,
                  total: _total,
                  commodity: _commodityCtrl.text.trim(),
                ),
                const SizedBox(height: 20),
              ],

              // ── Submit ────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _kGreen.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    _submitting
                        ? 'Enregistrement…'
                        : 'Enregistrer le remboursement',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  onPressed: _submitting ? null : _submit,
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Le remboursement sera appliqué FIFO (dettes les plus anciennes en premier)',
                  style: TextStyle(
                      fontSize: 11,
                      color: _kMuted,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.foreground),
      );
}

// ── Farmer debt status card ───────────────────────────────────────────────────

class _DebtStatusCard extends StatelessWidget {
  final dynamic farmer; // Farmer model
  const _DebtStatusCard({required this.farmer});

  @override
  Widget build(BuildContext context) {
    final ratio = farmer.creditLimit > 0
        ? (farmer.currentDebt / farmer.creditLimit).clamp(0.0, 1.0)
        : 0.0;
    final hasDebt = farmer.currentDebt > 0;
    final color = hasDebt ? _kRed : _kGreen;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Text(
                  farmer.firstName[0].toUpperCase(),
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(farmer.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.foreground)),
                    Text(farmer.identifier,
                        style: const TextStyle(fontSize: 12, color: _kMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Dette actuelle',
                      style: TextStyle(fontSize: 11, color: _kMuted)),
                  Text(
                    CurrencyUtils.format(farmer.currentDebt),
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: color),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: color,
              backgroundColor: _kBorder,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0', style: TextStyle(fontSize: 11, color: _kMuted)),
              Text(
                'Limite : ${CurrencyUtils.format(farmer.creditLimit)}',
                style: const TextStyle(fontSize: 11, color: _kMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Commodity text field ──────────────────────────────────────────────────────

class _CommodityField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _CommodityField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'ex : Cacao, Maïs, Café…',
        hintStyle: const TextStyle(color: _kMuted, fontSize: 14),
        prefixIcon: const Icon(Icons.grass_outlined, color: _kMuted, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kRed),
        ),
      ),
      style: const TextStyle(fontSize: 14, color: AppTheme.foreground),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Indiquez le produit' : null,
      onChanged: onChanged,
    );
  }
}

// ── Quick-select commodity chips ──────────────────────────────────────────────

class _CommodityChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onTap;
  const _CommodityChips({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: _kCommodities.map((c) {
        final active = selected.toLowerCase() == c.toLowerCase();
        return InkWell(
          onTap: () => onTap(c),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: active ? _kGreen : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: active ? _kGreen : _kBorder, width: 1.2),
            ),
            child: Text(
              c,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : AppTheme.foreground,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Generic number text field ─────────────────────────────────────────────────

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget prefix;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;

  const _NumberField({
    required this.controller,
    required this.hint,
    required this.prefix,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kMuted, fontSize: 14),
        prefixIcon: prefix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kRed),
        ),
      ),
      style: const TextStyle(fontSize: 14, color: AppTheme.foreground),
      validator: validator,
      onChanged: onChanged,
    );
  }
}

// ── Live calculation preview ──────────────────────────────────────────────────

class _CalculationPreview extends StatelessWidget {
  final double kg;
  final double rate;
  final double total;
  final String commodity;

  const _CalculationPreview({
    required this.kg,
    required this.rate,
    required this.total,
    required this.commodity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kGreen.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (commodity.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.grass_outlined,
                      size: 14, color: _kGreen),
                  const SizedBox(width: 6),
                  Text(
                    commodity,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kGreen),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${kg % 1 == 0 ? kg.toInt() : kg.toStringAsFixed(2)} kg'
                  '  ×  '
                  '${CurrencyUtils.format(rate)} / kg',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.foreground,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.arrow_forward,
                  size: 14, color: _kMuted),
              const SizedBox(width: 8),
              Text(
                CurrencyUtils.format(total),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _kGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
