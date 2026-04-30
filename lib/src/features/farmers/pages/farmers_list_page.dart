import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/farmer_provider.dart';
import '../../../commons/data/models/farmer.dart';
import '../../../commons/widgets/widgets.dart';
import '../../../commons/utils/currency_utils.dart';
import '../../../commons/utils/responsive.dart';
import '../../../theme/app_theme.dart';

class FarmersListPage extends StatefulWidget {
  const FarmersListPage({super.key});

  @override
  State<FarmersListPage> createState() => _FarmersListPageState();
}

class _FarmersListPageState extends State<FarmersListPage> {
  final _searchCtrl = TextEditingController();
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmerProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmerProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Farmers',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.foreground)),
                      SizedBox(height: 2),
                      Text('Browse and manage registered farmers',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.mutedFg)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Add Farmer',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  onPressed: () => context.go('/farmers/new'),
                ),
              ],
            ),
          ),
          // Filter row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 16, color: AppTheme.mutedFg),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: 'Search by name, ID or phone...',
                              hintStyle: const TextStyle(
                                  color: AppTheme.mutedFg, fontSize: 13),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                              filled: false,
                            ),
                            style: const TextStyle(fontSize: 13),
                            onChanged: (v) {
                              if (v.isEmpty) {
                                provider.loadAll();
                              } else if (v.length >= 2) {
                                provider.search(v);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'All',
                  active: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: '🌱 Vegetable',
                  active: _filter == 'veg',
                  onTap: () => setState(() => _filter = 'veg'),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: '🐄 Animal',
                  active: _filter == 'animal',
                  onTap: () => setState(() => _filter = 'animal'),
                ),
                const SizedBox(width: 12),
                Text(
                  '${provider.farmers.length} farmers',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.mutedFg),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderColor),
          // Grid
          Expanded(
            child: provider.loading
                ? const ListShimmer()
                : provider.error != null
                    ? ErrorView(
                        message: provider.error!,
                        onRetry: () => provider.loadAll(),
                      )
                    : provider.farmers.isEmpty
                        ? const EmptyView(
                            message: 'Aucun agriculteur trouvé',
                            icon: Icons.people_outline,
                          )
                        : _FarmerGrid(farmers: provider.farmers),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active
                ? AppTheme.primaryGreen
                : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                active ? FontWeight.w600 : FontWeight.w400,
            color:
                active ? AppTheme.primaryGreen : AppTheme.mutedFg,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FARMER GRID
// ─────────────────────────────────────────────────────────────────────────────

class _FarmerGrid extends StatelessWidget {
  final List<Farmer> farmers;
  const _FarmerGrid({required this.farmers});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Responsive.pagePadding(context).copyWith(top: 16, bottom: 16),
      child: LayoutBuilder(builder: (context, constraints) {
        final cols = constraints.maxWidth < 400
            ? 1
            : constraints.maxWidth < 700
                ? 2
                : constraints.maxWidth < 1100
                    ? 3
                    : 4;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.82,
          ),
          itemCount: farmers.length,
          itemBuilder: (_, i) => _FarmerCard(
            farmer: farmers[i],
            colorIndex: i % _avatarColors.length,
          ),
        );
      }),
    );
  }
}

const _avatarColors = [
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFE53935),
  Color(0xFF8E24AA),
  Color(0xFFFF6F00),
  Color(0xFF00897B),
];

// ─────────────────────────────────────────────────────────────────────────────
// FARMER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _FarmerCard extends StatelessWidget {
  final Farmer farmer;
  final int colorIndex;
  const _FarmerCard(
      {required this.farmer, required this.colorIndex});

  Color get _avatarColor => _avatarColors[colorIndex];

  String get _initials {
    final parts = farmer.fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return farmer.fullName.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showFarmerModal(context, farmer, _avatarColor, _initials),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, const Color(0xFFF0F7F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.12),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top row: share icon
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.share_outlined,
                      size: 16, color: AppTheme.mutedFg),
                ),
              ),
            ),
            // Avatar with online dot
            Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _avatarColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Name
            Text(
              farmer.fullName,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.foreground),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              farmer.identifier,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.mutedFg),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Specialty tags
            Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                _SpecialtyTag('🌾 Agriculteur'),
                _SpecialtyTag('🌿 Bio'),
              ],
            ),
            const Spacer(),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatMini(label: 'Rating', value: '4.8'),
                Container(
                    width: 1, height: 28, color: AppTheme.borderColor),
                _StatMini(
                  label: 'Credit',
                  value: CurrencyUtils.format(farmer.creditLimit),
                ),
                Container(
                    width: 1, height: 28, color: AppTheme.borderColor),
                _StatMini(
                  label: 'Debt',
                  value: farmer.currentDebt > 0
                      ? CurrencyUtils.format(farmer.currentDebt)
                      : '—',
                  valueColor: farmer.currentDebt > 0
                      ? AppTheme.creditRed
                      : AppTheme.primaryGreen,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        context.go('/farmers/${farmer.id}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(
                          color: AppTheme.primaryGreen),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('View Profile',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bookmark_border,
                        size: 16, color: AppTheme.mutedFg),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFarmerModal(BuildContext context, Farmer farmer,
      Color avatarColor, String initials) {
    showDialog(
      context: context,
      builder: (_) => _FarmerModal(
        farmer: farmer,
        avatarColor: avatarColor,
        initials: initials,
      ),
    );
  }
}

class _SpecialtyTag extends StatelessWidget {
  final String label;
  const _SpecialtyTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatMini(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppTheme.foreground),
        ),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppTheme.mutedFg)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FARMER DETAIL MODAL
// ─────────────────────────────────────────────────────────────────────────────

class _FarmerModal extends StatelessWidget {
  final Farmer farmer;
  final Color avatarColor;
  final String initials;
  const _FarmerModal({
    required this.farmer,
    required this.avatarColor,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: avatarColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(farmer.fullName,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.foreground)),
                          Text(farmer.identifier,
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.mutedFg)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: const [
                              _SpecialtyTag('🌾 Agriculteur'),
                              _SpecialtyTag('📍 India'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppTheme.mutedFg,
                    ),
                  ],
                ),
              ),
              // 4-stat row
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 24),
                decoration: const BoxDecoration(
                  color: AppTheme.muted,
                  border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ModalStat(label: 'Credit Limit',
                        value: CurrencyUtils.format(farmer.creditLimit)),
                    _ModalStat(
                      label: 'Current Debt',
                      value: CurrencyUtils.format(farmer.currentDebt),
                      valueColor: farmer.currentDebt > 0
                          ? AppTheme.creditRed
                          : AppTheme.primaryGreen,
                    ),
                    _ModalStat(label: 'Phone', value: farmer.phone),
                    _ModalStat(label: 'Rating', value: '4.8 ★'),
                  ],
                ),
              ),
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.mutedFg,
                        side: const BorderSide(
                            color: AppTheme.borderColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.person_outlined, size: 16),
                      label: const Text('View Full Profile'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/farmers/${farmer.id}');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _ModalStat(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppTheme.foreground)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.mutedFg)),
      ],
    );
  }
}

