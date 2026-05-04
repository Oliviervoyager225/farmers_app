import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/farmer_provider.dart';
import '../../../commons/utils/extensions.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _kBorder  = Color(0xFFE5E7EB);
const _kBg      = Color(0xFFF9FAFB);
const _kCardBg  = Colors.white;
const _kLabel   = Color(0xFF374151);
const _kTitle   = Color(0xFF111827);
const _kMuted   = Color(0xFF6B7280);
const _kGreen   = Color(0xFF16A34A);
const _kGreenBg = Color(0xFFF0FDF4);

class FarmerCreatePage extends StatefulWidget {
  const FarmerCreatePage({super.key});

  @override
  State<FarmerCreatePage> createState() => _FarmerCreatePageState();
}

class _FarmerCreatePageState extends State<FarmerCreatePage> {
  final _formKey        = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _stateCtrl      = TextEditingController();
  final _cityCtrl       = TextEditingController();
  final _addressCtrl    = TextEditingController();
  final _bioCtrl        = TextEditingController();
  final _limitCtrl      = TextEditingController();

  bool _catVeg    = false;
  bool _catAnimal = false;
  final Set<String> _specialties = {};

  static const _vegSpecialties = [
    'Agriculteur', 'Maraîcher', 'Arboriculteur', 'Riziculteur',
    'Cacaoculteur', 'Caféiculteur', 'Horticulteur', 'Pépiniériste',
  ];
  static const _animalSpecialties = [
    'Éleveur', 'Aviculteur', 'Boviniculteur',
    'Porciniculteur', 'Pisciculteur', 'Apiculteur',
  ];

  @override
  void dispose() {
    for (final c in [
      _identifierCtrl, _firstNameCtrl, _lastNameCtrl, _phoneCtrl,
      _emailCtrl, _stateCtrl, _cityCtrl, _addressCtrl, _bioCtrl,
      _limitCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _initials {
    final fn = _firstNameCtrl.text.trim();
    final ln = _lastNameCtrl.text.trim();
    if (fn.isNotEmpty && ln.isNotEmpty) {
      return '${fn[0]}${ln[0]}'.toUpperCase();
    } else if (fn.isNotEmpty) {
      return fn.substring(0, fn.length > 1 ? 2 : 1).toUpperCase();
    }
    return 'FB';
  }

  List<String> get _selectedCategories => [
    if (_catVeg) 'vegetale',
    if (_catAnimal) 'animale',
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<FarmerProvider>();
    final ok = await provider.createFarmer({
      'first_name'   : _firstNameCtrl.text.trim(),
      'last_name'    : _lastNameCtrl.text.trim(),
      'phone'        : _phoneCtrl.text.trim(),
      'email'        : _emailCtrl.text.trim(),
      'state'        : _stateCtrl.text.trim(),
      'city'         : _cityCtrl.text.trim(),
      'address'      : _addressCtrl.text.trim(),
      'bio'          : _bioCtrl.text.trim(),
      'categories'   : _selectedCategories,
      'specialties'  : _specialties.toList(),
      'credit_limit' : double.tryParse(_limitCtrl.text) ?? 0,
    });
    if (mounted) {
      if (ok) {
        context.showSnackSuccess('Agriculteur ajouté avec succès !');
        context.pop();
      } else {
        context.showSnackError(provider.error ?? 'Erreur');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<FarmerProvider>().loading;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Page header ───────────────────────────────────────
                    _PageHeader(onBack: () => context.pop()),
                    const SizedBox(height: 24),

                    // ── Profile Photo ─────────────────────────────────────
                    _FormCard(
                      title: 'Profile Photo',
                      child: ListenableBuilder(
                        listenable: Listenable.merge([_firstNameCtrl, _lastNameCtrl]),
                        builder: (_, __) => Row(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: const BoxDecoration(
                                color: _kGreen,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.upload_outlined, size: 15),
                                  label: const Text('Upload Photo',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _kTitle,
                                    side: const BorderSide(color: _kBorder),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text('JPG, PNG up to 2MB',
                                    style: TextStyle(fontSize: 11, color: _kMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Personal Information ──────────────────────────────
                    _FormCard(
                      title: 'Personal Information',
                      child: Column(
                        children: [
                          _Row2(
                            left: _Field(
                              label: 'First Name *',
                              ctrl: _firstNameCtrl,
                              hint: 'John',
                              validator: _required,
                            ),
                            right: _Field(
                              label: 'Last Name *',
                              ctrl: _lastNameCtrl,
                              hint: 'Doe',
                              validator: _required,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _Row2(
                            left: _Field(
                              label: 'Phone *',
                              ctrl: _phoneCtrl,
                              hint: '+225 07 00 00 00',
                              keyboard: TextInputType.phone,
                              validator: _required,
                            ),
                            right: _Field(
                              label: 'Email',
                              ctrl: _emailCtrl,
                              hint: 'farmer@example.com',
                              keyboard: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _Row2(
                            left: _Field(
                              label: 'State / Région',
                              ctrl: _stateCtrl,
                              hint: 'Abidjan',
                            ),
                            right: _Field(
                              label: 'City / Ville',
                              ctrl: _cityCtrl,
                              hint: 'Cocody',
                            ),
                          ),
                          const SizedBox(height: 14),
                          _ReadOnlyField(
                            label: 'Farmer ID / Identifier',
                            value: 'Généré automatiquement (AGR-CI-XXX)',
                          ),
                          const SizedBox(height: 14),
                          _Field(
                            label: 'Address',
                            ctrl: _addressCtrl,
                            hint: 'Village, Commune, Département...',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 14),
                          _Field(
                            label: 'Bio',
                            ctrl: _bioCtrl,
                            hint: 'Brief description about this farmer...',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Production Category ───────────────────────────────
                    _FormCard(
                      title: 'Production Category',
                      child: Row(
                        children: [
                          Expanded(
                            child: _CatCard(
                              emoji: '🌱',
                              label: 'Production végétale',
                              subtitle: 'Crops, fruits, vegetables',
                              selected: _catVeg,
                              onTap: () => setState(() {
                                _catVeg = !_catVeg;
                                if (!_catVeg) {
                                  _specialties.removeAll(_vegSpecialties);
                                }
                              }),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CatCard(
                              emoji: '🐄',
                              label: 'Production animale',
                              subtitle: 'Livestock, poultry, fishery',
                              selected: _catAnimal,
                              onTap: () => setState(() {
                                _catAnimal = !_catAnimal;
                                if (!_catAnimal) {
                                  _specialties.removeAll(_animalSpecialties);
                                }
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Specialty ─────────────────────────────────────────
                    _FormCard(
                      title: 'Specialty / Métier',
                      child: (!_catVeg && !_catAnimal)
                          ? const Text(
                              'Select a production category above to see specialties.',
                              style: TextStyle(fontSize: 13, color: _kMuted),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_catVeg) ...[
                                  _SpecGroup(
                                    label: 'Vegetale',
                                    items: _vegSpecialties,
                                    selected: _specialties,
                                    onToggle: (s) => setState(() =>
                                        _specialties.contains(s)
                                            ? _specialties.remove(s)
                                            : _specialties.add(s)),
                                  ),
                                  if (_catAnimal) const SizedBox(height: 16),
                                ],
                                if (_catAnimal)
                                  _SpecGroup(
                                    label: 'Animale',
                                    items: _animalSpecialties,
                                    selected: _specialties,
                                    onToggle: (s) => setState(() =>
                                        _specialties.contains(s)
                                            ? _specialties.remove(s)
                                            : _specialties.add(s)),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 16),

                    // ── Limite de crédit ──────────────────────────────────
                    _FormCard(
                      title: 'Crédit',
                      child: _Field(
                        label: 'Limite de Crédit (FCFA) *',
                        ctrl: _limitCtrl,
                        hint: '50000',
                        keyboard: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requis';
                          if (double.tryParse(v) == null) return 'Nombre invalide';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Footer buttons ────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _kMuted,
                            side: const BorderSide(color: _kBorder),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            disabledBackgroundColor:
                                _kGreen.withValues(alpha: 0.6),
                          ),
                          icon: loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check, size: 16),
                          label: Text(
                            loading ? 'Saving...' : 'Add Farmer',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
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
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Requis' : null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Page header
// ─────────────────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _PageHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: _kBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back, size: 16, color: _kTitle),
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
                    color: _kTitle)),
            SizedBox(height: 2),
            Text('Fill in the details to register a new farmer',
                style: TextStyle(fontSize: 13, color: _kMuted)),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form card
// ─────────────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _FormCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _kTitle,
                  letterSpacing: -0.1)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Two-column responsive row
// ─────────────────────────────────────────────────────────────────────────────

class _Row2 extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _Row2({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      if (c.maxWidth < 480) {
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

// ─────────────────────────────────────────────────────────────────────────────
// Read-only display field (greyed out, auto-generated values)
// ─────────────────────────────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: _kLabel)),
            const SizedBox(width: 5),
            const Icon(Icons.lock_outline, size: 12, color: _kMuted),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kBorder),
          ),
          child: Text(value,
              style: const TextStyle(fontSize: 13, color: _kMuted)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Text field
// ─────────────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String? hint;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final int? maxLines;

  const _Field({
    required this.label,
    required this.ctrl,
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
                fontSize: 12, fontWeight: FontWeight.w600, color: _kLabel)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          maxLines: maxLines ?? 1,
          style: const TextStyle(fontSize: 13, color: _kTitle),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _kMuted, fontSize: 13),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kGreen, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: validator,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Production category card
// ─────────────────────────────────────────────────────────────────────────────

class _CatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _CatCard({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _kGreenBg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _kGreen : _kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 26)),
                if (selected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: _kGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 12),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? _kGreen : _kTitle,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(fontSize: 11, color: _kMuted)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Specialty group (label + chips)
// ─────────────────────────────────────────────────────────────────────────────

class _SpecGroup extends StatelessWidget {
  final String label;
  final List<String> items;
  final Set<String> selected;
  final void Function(String) onToggle;

  const _SpecGroup({
    required this.label,
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: _kMuted)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((s) {
            final on = selected.contains(s);
            return GestureDetector(
              onTap: () => onToggle(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: on ? _kGreenBg : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: on ? _kGreen : _kBorder,
                    width: on ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  s,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                    color: on ? _kGreen : _kLabel,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
