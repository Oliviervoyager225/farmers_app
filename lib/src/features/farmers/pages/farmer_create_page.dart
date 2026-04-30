import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/farmer_provider.dart';
import '../../../commons/utils/extensions.dart';
import '../../../theme/app_theme.dart';

class FarmerCreatePage extends StatefulWidget {
  const FarmerCreatePage({super.key});

  @override
  State<FarmerCreatePage> createState() => _FarmerCreatePageState();
}

class _FarmerCreatePageState extends State<FarmerCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _limitCtrl = TextEditingController();
  final _farmSizeCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();

  // Categories
  bool _catVeg = false;
  bool _catAnimal = false;

  // Selected specialties
  final Set<String> _specialties = {};

  static const _vegSpecialties = [
    'Agriculteur', 'Maraîcher', 'Arboriculteur', 'Riziculteur',
    'Cacaoculteur', 'Caféiculteur', 'Horticulteur', 'Pépiniériste',
  ];
  static const _animalSpecialties = [
    'Éleveur', 'Aviculteur', 'Boviniculteur',
    'Porciniculteur', 'Pisciculteur', 'Apiculteur',
  ];

  String? _certification;
  String? _primaryMarket;

  static const _certifications = [
    'Bio Certified', 'Fairtrade', 'FSSAI', 'Organic India', 'None'
  ];
  static const _markets = [
    'Local Market', 'State Market', 'National Market', 'Export'
  ];

  @override
  void dispose() {
    for (final c in [
      _identifierCtrl, _firstNameCtrl, _lastNameCtrl, _phoneCtrl,
      _emailCtrl, _stateCtrl, _cityCtrl, _addressCtrl, _bioCtrl,
      _limitCtrl, _farmSizeCtrl, _experienceCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<FarmerProvider>();
    final ok = await provider.createFarmer({
      'identifier': _identifierCtrl.text.trim(),
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'credit_limit': double.tryParse(_limitCtrl.text) ?? 0,
    });
    if (mounted) {
      if (ok) {
        context.showSnackSuccess('Farmer added successfully!');
        context.pop();
      } else {
        context.showSnackError(provider.error ?? 'Error');
      }
    }
  }

  String get _previewInitials {
    final fn = _firstNameCtrl.text;
    final ln = _lastNameCtrl.text;
    if (fn.isNotEmpty && ln.isNotEmpty) {
      return '${fn[0]}${ln[0]}'.toUpperCase();
    } else if (fn.isNotEmpty) {
      return fn.substring(0, fn.length > 1 ? 2 : 1).toUpperCase();
    }
    return 'FB';
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
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
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
                          Text('Add New Farmer',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.foreground)),
                          Text('Fill in the details to register a new farmer',
                              style: TextStyle(
                                  fontSize: 13, color: AppTheme.mutedFg)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // ── Section: Photo
                  _Section(
                    title: 'Profile Photo',
                    child: Row(
                      children: [
                        ListenableBuilder(
                          listenable: Listenable.merge(
                              [_firstNameCtrl, _lastNameCtrl]),
                          builder: (_, __) => Container(
                            width: 88,
                            height: 88,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _previewInitials,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.upload_outlined,
                                  size: 14),
                              label: const Text('Upload Photo',
                                  style: TextStyle(fontSize: 13)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.foreground,
                                side: const BorderSide(
                                    color: AppTheme.borderColor),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text('JPG, PNG up to 2MB',
                                style: TextStyle(
                                    fontSize: 11, color: AppTheme.mutedFg)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Section: Personal Info
                  _Section(
                    title: 'Personal Information',
                    child: Column(
                      children: [
                        _TwoCol(
                          left: _Field(
                            label: 'First Name *',
                            controller: _firstNameCtrl,
                            hint: 'John',
                            validator: (v) => v == null || v.isEmpty
                                ? 'Required'
                                : null,
                          ),
                          right: _Field(
                            label: 'Last Name *',
                            controller: _lastNameCtrl,
                            hint: 'Doe',
                            validator: (v) => v == null || v.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _TwoCol(
                          left: _Field(
                            label: 'Phone *',
                            controller: _phoneCtrl,
                            hint: '+91 98765 43210',
                            keyboard: TextInputType.phone,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Required'
                                : null,
                          ),
                          right: _Field(
                            label: 'Email',
                            controller: _emailCtrl,
                            hint: 'farmer@example.com',
                            keyboard: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _TwoCol(
                          left: _Field(
                            label: 'State',
                            controller: _stateCtrl,
                            hint: 'Punjab',
                          ),
                          right: _Field(
                            label: 'City',
                            controller: _cityCtrl,
                            hint: 'Amritsar',
                          ),
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          label: 'Farmer ID / Identifier *',
                          controller: _identifierCtrl,
                          hint: 'AGR-0001',
                          validator: (v) => v == null || v.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          label: 'Address',
                          controller: _addressCtrl,
                          hint: 'Village, District...',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          label: 'Bio',
                          controller: _bioCtrl,
                          hint: 'Brief description about this farmer...',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Section: Production Category
                  _Section(
                    title: 'Production Category',
                    child: Row(
                      children: [
                        Expanded(
                          child: _CategoryToggle(
                            emoji: '🌱',
                            label: 'Production végétale',
                            subtitle: 'Crops, fruits, vegetables',
                            selected: _catVeg,
                            onTap: () =>
                                setState(() => _catVeg = !_catVeg),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CategoryToggle(
                            emoji: '🐄',
                            label: 'Production animale',
                            subtitle: 'Livestock, poultry, fishery',
                            selected: _catAnimal,
                            onTap: () =>
                                setState(() => _catAnimal = !_catAnimal),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Section: Specialties
                  _Section(
                    title: 'Specialty / Métier',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_catVeg) ...[
                          const Text('Vegetale',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.mutedFg)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final s in _vegSpecialties)
                                _SpecialtyToggle(
                                  label: s,
                                  selected: _specialties.contains(s),
                                  onTap: () => setState(() {
                                    _specialties.contains(s)
                                        ? _specialties.remove(s)
                                        : _specialties.add(s);
                                  }),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (_catAnimal) ...[
                          const Text('Animale',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.mutedFg)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final s in _animalSpecialties)
                                _SpecialtyToggle(
                                  label: s,
                                  selected: _specialties.contains(s),
                                  onTap: () => setState(() {
                                    _specialties.contains(s)
                                        ? _specialties.remove(s)
                                        : _specialties.add(s);
                                  }),
                                ),
                            ],
                          ),
                        ],
                        if (!_catVeg && !_catAnimal)
                          const Text(
                            'Select a production category above to see specialties.',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.mutedFg),
                          ),
                        if (_specialties.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final s in _specialties)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen
                                        .withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(999),
                                    border: Border.all(
                                      color: AppTheme.primaryGreen
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(s,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.primaryGreen)),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () => setState(
                                            () => _specialties.remove(s)),
                                        child: const Icon(Icons.close,
                                            size: 12,
                                            color: AppTheme.primaryGreen),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Section: Farm Details
                  _Section(
                    title: 'Farm Details',
                    child: Column(
                      children: [
                        _TwoCol(
                          left: _Field(
                            label: 'Farm Size (acres)',
                            controller: _farmSizeCtrl,
                            hint: '5.0',
                            keyboard: TextInputType.number,
                          ),
                          right: _Field(
                            label: 'Experience (years)',
                            controller: _experienceCtrl,
                            hint: '10',
                            keyboard: TextInputType.number,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _TwoCol(
                          left: _DropdownField(
                            label: 'Certification',
                            value: _certification,
                            items: _certifications,
                            onChanged: (v) =>
                                setState(() => _certification = v),
                          ),
                          right: _DropdownField(
                            label: 'Primary Market',
                            value: _primaryMarket,
                            items: _markets,
                            onChanged: (v) =>
                                setState(() => _primaryMarket = v),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          label: 'Limite de Crédit (FCFA) *',
                          controller: _limitCtrl,
                          hint: '50000',
                          keyboard: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (double.tryParse(v) == null) return 'Invalid number';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Footer buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.mutedFg,
                          side: const BorderSide(
                              color: AppTheme.borderColor),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Icon(Icons.check, size: 16),
                        label: Text(loading ? 'Saving...' : 'Add Farmer',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.foreground)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TwoCol extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _TwoCol({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 500) {
        return Column(
          children: [left, const SizedBox(height: 14), right],
        );
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

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final int? maxLines;
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboard,
    this.validator,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.foreground)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: AppTheme.mutedFg, fontSize: 13),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.foreground)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: const Text('Select...', style: TextStyle(fontSize: 13)),
          style: const TextStyle(
              fontSize: 13, color: AppTheme.foreground),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          items: items
              .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _CategoryToggle extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryToggle({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryGreen.withOpacity(0.06)
              : AppTheme.muted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.primaryGreen : AppTheme.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                if (selected)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 12),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppTheme.primaryGreen
                        : AppTheme.foreground)),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.mutedFg)),
          ],
        ),
      ),
    );
  }
}

class _SpecialtyToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SpecialtyToggle(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : AppTheme.muted,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? AppTheme.primaryGreen : AppTheme.borderColor,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: selected ? AppTheme.primaryGreen : AppTheme.mutedFg,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}

