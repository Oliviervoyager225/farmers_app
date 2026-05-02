import 'dart:math' show pi;
import 'package:flutter/material.dart';
import '../../../commons/utils/responsive.dart';
import '../../../theme/app_theme.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int? _selectedStateIndex;

  static const _states = [
    _StateData('Dakar', 12500, 'Élevé', ['Mil', 'Riz', 'Arachide'], '420 FCFA/kg', 8200),
    _StateData('Abidjan', 9800, 'Moyen', ['Igname', 'Café', 'Cacao'], '380 FCFA/kg', 6500),
    _StateData('Bamako', 15200, 'Élevé', ['Mil', 'Coton', 'Fonio'], '280 FCFA/kg', 9800),
    _StateData('Ouagadougou', 7400, 'Moyen', ['Sésame', 'Niébé', 'Mangue'], '550 FCFA/kg', 4200),
    _StateData('Lomé', 6200, 'Faible', ['Manioc', 'Banane', 'Maïs'], '350 FCFA/kg', 3900),
    _StateData('Cotonou', 8100, 'Élevé', ['Riz', 'Tomate', 'Oignon'], '310 FCFA/kg', 5400),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: Responsive.pagePadding(context).copyWith(top: 24, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Analyse du Marché',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.foreground),
            ),
            const SizedBox(height: 4),
            const Text(
              'Intelligence marché en temps réel',
              style: TextStyle(fontSize: 13, color: AppTheme.mutedFg),
            ),
            const SizedBox(height: 24),
            // Stat cards
            const _AnalyticsStatCards(),
            const SizedBox(height: 24),
            // State distribution + detail panel
            LayoutBuilder(builder: (context, constraints) {
              final hasDetail = _selectedStateIndex != null;
              if (constraints.maxWidth < 900 || !hasDetail) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StateDistribution(
                      selectedIndex: _selectedStateIndex,
                      onSelect: (i) =>
                          setState(() => _selectedStateIndex = i == _selectedStateIndex ? null : i),
                      states: _states,
                    ),
                    if (hasDetail) ...[
                      const SizedBox(height: 16),
                      _StateDetailPanel(
                        data: _states[_selectedStateIndex!],
                        onClose: () =>
                            setState(() => _selectedStateIndex = null),
                      ),
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _StateDistribution(
                      selectedIndex: _selectedStateIndex,
                      onSelect: (i) =>
                          setState(() => _selectedStateIndex = i == _selectedStateIndex ? null : i),
                      states: _states,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _StateDetailPanel(
                      data: _states[_selectedStateIndex!],
                      onClose: () =>
                          setState(() => _selectedStateIndex = null),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            // Charts row
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return const Column(
                  children: [
                    _PieChartCard(),
                    SizedBox(height: 16),
                    _OrderTrendsCard(),
                  ],
                );
              }
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _PieChartCard()),
                  SizedBox(width: 16),
                  Expanded(child: _OrderTrendsCard()),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS STAT CARDS
// ─────────────────────────────────────────────────────────────────────────────

class _AnalyticsStatCards extends StatelessWidget {
  const _AnalyticsStatCards();

  static const _items = [
    (Icons.people_outline, 'Active Farmers', '70,500', '+12%', AppTheme.primaryGreen),
    (Icons.grass_outlined, 'Total Crops', '1,28,000', '+8%', Color(0xFF1565C0)),
    (Icons.sell_outlined, 'Prix Moyen', '410 FCFA/kg', '+5%', Color(0xFF6A1B9A)),
    (Icons.receipt_long_outlined, 'Total Orders', '30.5K', '+18%', AppTheme.accentOrange),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth < 600 ? 2 : 4;
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
        children: [
          for (final item in _items)
            _AStatCard(
              icon: item.$1,
              label: item.$2,
              value: item.$3,
              growth: item.$4,
              color: item.$5,
            ),
        ],
      );
    });
  }
}

class _AStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String growth;
  final Color color;
  const _AStatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.growth,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedFg,
                      fontWeight: FontWeight.w500)),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          Row(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(growth,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE DISTRIBUTION GRID
// ─────────────────────────────────────────────────────────────────────────────

class _StateData {
  final String name;
  final int activeFarmers;
  final String supplyLevel;
  final List<String> topCrops;
  final String avgPrice;
  final int totalOrders;
  const _StateData(this.name, this.activeFarmers, this.supplyLevel,
      this.topCrops, this.avgPrice, this.totalOrders);
}

class _StateDistribution extends StatelessWidget {
  final int? selectedIndex;
  final void Function(int) onSelect;
  final List<_StateData> states;
  const _StateDistribution(
      {required this.selectedIndex,
      required this.onSelect,
      required this.states});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('State Distribution',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.foreground)),
          const SizedBox(height: 4),
          const Text('Click on a state to view details',
              style: TextStyle(fontSize: 12, color: AppTheme.mutedFg)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              for (var i = 0; i < states.length; i++)
                _StateCard(
                  data: states[i],
                  selected: selectedIndex == i,
                  onTap: () => onSelect(i),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final _StateData data;
  final bool selected;
  final VoidCallback onTap;
  const _StateCard(
      {required this.data, required this.selected, required this.onTap});

  Color get _supplyColor {
    switch (data.supplyLevel) {
      case 'High':
        return AppTheme.primaryGreen;
      case 'Medium':
        return AppTheme.accentOrange;
      default:
        return AppTheme.creditRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryGreen.withOpacity(0.06)
              : AppTheme.muted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppTheme.primaryGreen
                : Colors.transparent,
            width: selected ? 1.5 : 0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data.name,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppTheme.primaryGreen
                        : AppTheme.foreground),
                overflow: TextOverflow.ellipsis),
            Text('${(data.activeFarmers / 1000).toStringAsFixed(1)}K farmers',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.mutedFg)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _supplyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(data.supplyLevel,
                  style: TextStyle(
                      fontSize: 10,
                      color: _supplyColor,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateDetailPanel extends StatelessWidget {
  final _StateData data;
  final VoidCallback onClose;
  const _StateDetailPanel({required this.data, required this.onClose});

  Color get _supplyColor {
    switch (data.supplyLevel) {
      case 'High':
        return AppTheme.primaryGreen;
      case 'Medium':
        return AppTheme.accentOrange;
      default:
        return AppTheme.creditRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data.name,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground)),
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child:
                      Icon(Icons.close, size: 16, color: AppTheme.mutedFg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(
              label: 'Active Farmers',
              value: '${data.activeFarmers.toString()}'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Supply Level',
                  style:
                      TextStyle(fontSize: 13, color: AppTheme.mutedFg)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _supplyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(data.supplyLevel,
                    style: TextStyle(
                        fontSize: 11,
                        color: _supplyColor,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DetailRow(label: 'Avg Price', value: data.avgPrice),
          const SizedBox(height: 10),
          _DetailRow(
              label: 'Total Orders',
              value: data.totalOrders.toString()),
          const SizedBox(height: 14),
          const Text('Top Crops',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mutedFg)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final crop in data.topCrops)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(crop,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w500)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppTheme.mutedFg)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.foreground)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PIE CHART – Crop Category Distribution
// ─────────────────────────────────────────────────────────────────────────────

class _PieChartCard extends StatelessWidget {
  const _PieChartCard();

  static const _segments = [
    (0.40, AppTheme.primaryGreen, 'Grains', '40%'),
    (0.35, Color(0xFF1565C0), 'Vegetables', '35%'),
    (0.15, AppTheme.accentOrange, 'Fruits', '15%'),
    (0.10, Color(0xFF6A1B9A), 'Spices', '10%'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Crop Distribution',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.foreground)),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: _PieChartPainter(
                  segments: _segments
                      .map((s) => _PieSegment(s.$1, s.$2))
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final s in _segments)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration:
                          BoxDecoration(color: s.$2, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text('${s.$3} ${s.$4}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.mutedFg)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PieSegment {
  final double fraction;
  final Color color;
  const _PieSegment(this.fraction, this.color);
}

class _PieChartPainter extends CustomPainter {
  final List<_PieSegment> segments;
  _PieChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    double startAngle = -pi / 2;

    for (final seg in segments) {
      final sweepAngle = seg.fraction * 2 * pi;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      // Gap
      final gapPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        gapPaint,
      );
      startAngle += sweepAngle;
    }
    // Center hole
    canvas.drawCircle(
        center, radius * 0.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER TRENDS LINE CHART
// ─────────────────────────────────────────────────────────────────────────────

class _OrderTrendsCard extends StatelessWidget {
  const _OrderTrendsCard();

  static const _data = [4200.0, 5800.0, 4900.0, 7200.0, 6500.0, 8800.0];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Order Trends',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.foreground)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _TrendsLinePainter(data: _data, labels: _months),
              size: const Size(double.infinity, 200),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendsLinePainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  _TrendsLinePainter({required this.data, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const bottomPad = 24.0;
    const leftPad = 48.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;
    final minVal = data.reduce((a, b) => a < b ? a : b) * 0.85;
    final maxVal = data.reduce((a, b) => a > b ? a : b) * 1.08;
    final range = maxVal - minVal;

    double xOf(int i) => leftPad + i * chartW / (data.length - 1);
    double yOf(double v) => chartH * (1 - (v - minVal) / range);

    // Grid
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;
    for (var r = 0; r <= 4; r++) {
      final y = chartH * r / 4;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
      final val = (maxVal - range * r / 4) / 1000;
      final tp = TextPainter(
        text: TextSpan(
          text: '${val.toStringAsFixed(1)}k',
          style: const TextStyle(fontSize: 9, color: AppTheme.mutedFg),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 6));
    }

    // Fill
    final fillPath = Path()..moveTo(xOf(0), chartH);
    for (var i = 0; i < data.length; i++) {
      fillPath.lineTo(xOf(i), yOf(data[i]));
    }
    fillPath
      ..lineTo(xOf(data.length - 1), chartH)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = const Color(0xFF1565C0).withOpacity(0.08),
    );

    // Line
    final linePath = Path();
    for (var i = 0; i < data.length; i++) {
      if (i == 0) {
        linePath.moveTo(xOf(i), yOf(data[i]));
      } else {
        linePath.lineTo(xOf(i), yOf(data[i]));
      }
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF1565C0)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Dots + month labels
    for (var i = 0; i < data.length; i++) {
      canvas.drawCircle(
        Offset(xOf(i), yOf(data[i])),
        4,
        Paint()
          ..color = const Color(0xFF1565C0)
          ..style = PaintingStyle.fill,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 10, color: AppTheme.mutedFg),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(xOf(i) - tp.width / 2, size.height - bottomPad + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
