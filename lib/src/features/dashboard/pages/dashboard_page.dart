import 'package:flutter/material.dart';
import '../../../commons/utils/responsive.dart';
import '../../../theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: padding.copyWith(top: 24, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Dashboard',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.foreground),
            ),
            const SizedBox(height: 4),
            const Text(
              'Overview of your farming operations',
              style: TextStyle(fontSize: 13, color: AppTheme.mutedFg),
            ),
            const SizedBox(height: 24),
            // Stat cards
            const _StatCards(),
            const SizedBox(height: 24),
            // Middle row: chart + insights + premium card
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return const Column(
                  children: [
                    _EarningsChart(),
                    SizedBox(height: 16),
                    _InsightsColumn(),
                  ],
                );
              }
              return const IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _EarningsChart()),
                    SizedBox(width: 16),
                    Expanded(flex: 2, child: _InsightsColumn()),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            // Crops table
            const _CropsTable(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARDS ROW
// ─────────────────────────────────────────────────────────────────────────────

class _StatCards extends StatelessWidget {
  const _StatCards();

  static const _items = [
    (Icons.grass_outlined, 'Total Crops', '24', '+2 this month', AppTheme.primaryGreen),
    (Icons.receipt_long_outlined, 'Active Orders', '142', '+18 today', Color(0xFF1565C0)),
    (Icons.sell_outlined, 'Revenus Totaux', '3 200 000 FCFA', '+12% croissance', Color(0xFF6A1B9A)),
    (Icons.star_outline, 'Performance', 'Excellent', 'Score: 96/100', AppTheme.accentOrange),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth < 400
          ? 1
          : constraints.maxWidth < 700
              ? 2
              : 4;
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
        children: [
          for (final item in _items)
            _StatCard(
              icon: item.$1,
              label: item.$2,
              value: item.$3,
              sub: item.$4,
              color: item.$5,
            ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.mutedFg)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EARNINGS LINE CHART
// ─────────────────────────────────────────────────────────────────────────────

class _EarningsChart extends StatelessWidget {
  const _EarningsChart();

  // Monthly earnings in thousands (Jan-Jun)
  static const _data = [42.0, 58.0, 45.0, 72.0, 65.0, 88.0];
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Earnings Overview',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('2025',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _LineChartPainter(
                data: _data,
                labels: _months,
                lineColor: AppTheme.primaryGreen,
                fillColor: AppTheme.primaryGreen.withOpacity(0.08),
              ),
              size: const Size(double.infinity, 180),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color lineColor;
  final Color fillColor;

  _LineChartPainter({
    required this.data,
    required this.labels,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const bottomPad = 24.0;
    const leftPad = 40.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    final minVal = data.reduce((a, b) => a < b ? a : b) * 0.8;
    final maxVal = data.reduce((a, b) => a > b ? a : b) * 1.1;
    final range = maxVal - minVal;

    double xOf(int i) => leftPad + i * chartW / (data.length - 1);
    double yOf(double v) => chartH * (1 - (v - minVal) / range);

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;
    for (var r = 0; r <= 4; r++) {
      final y = chartH * r / 4;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
      final val = maxVal - range * r / 4;
      final tp = TextPainter(
        text: TextSpan(
          text: '${val.toInt()}k',
          style: const TextStyle(
              fontSize: 9, color: AppTheme.mutedFg),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 6));
    }

    // Fill path
    final fillPath = Path();
    fillPath.moveTo(xOf(0), chartH);
    for (var i = 0; i < data.length; i++) {
      fillPath.lineTo(xOf(i), yOf(data[i]));
    }
    fillPath.lineTo(xOf(data.length - 1), chartH);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final linePath = Path();
    for (var i = 0; i < data.length; i++) {
      if (i == 0) {
        linePath.moveTo(xOf(i), yOf(data[i]));
      } else {
        linePath.lineTo(xOf(i), yOf(data[i]));
      }
    }
    canvas.drawPath(linePath, linePaint);

    // Dots + labels
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    for (var i = 0; i < data.length; i++) {
      canvas.drawCircle(Offset(xOf(i), yOf(data[i])), 4, dotPaint);
      canvas.drawCircle(
          Offset(xOf(i), yOf(data[i])),
          6,
          Paint()
            ..color = lineColor.withOpacity(0.2)
            ..style = PaintingStyle.fill);
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 10, color: AppTheme.mutedFg),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas, Offset(xOf(i) - tp.width / 2, size.height - bottomPad + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK INSIGHTS + PREMIUM CARD
// ─────────────────────────────────────────────────────────────────────────────

class _InsightsColumn extends StatelessWidget {
  const _InsightsColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
              const Text('Quick Insights',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground)),
              const SizedBox(height: 16),
              _InsightRow(label: 'Ce Mois', value: '88 000 FCFA'),
              const SizedBox(height: 12),
              _InsightRow(label: 'Mois Dernier', value: '65 000 FCFA'),
              const SizedBox(height: 12),
              _InsightRow(
                label: 'Growth',
                value: '+35.4%',
                valueColor: AppTheme.primaryGreen,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Premium card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.workspace_premium,
                  color: Colors.white70, size: 28),
              const SizedBox(height: 12),
              const Text('Upgrade to Premium',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text(
                'Get advanced analytics and priority support.',
                style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryGreen,
                  minimumSize: const Size(double.infinity, 36),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Text('Upgrade Now',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InsightRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppTheme.mutedFg)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppTheme.foreground)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CROPS TABLE
// ─────────────────────────────────────────────────────────────────────────────

class _CropsTable extends StatelessWidget {
  const _CropsTable();

  static const _crops = [
    ('Blé', 'Céréales', '500 kg', '250 FCFA/kg', 'Actif', 'En Stock'),
    ('Tomates', 'Légumes', '200 kg', '300 FCFA/kg', 'Actif', 'Stock Faible'),
    ('Mangue', 'Fruits', '150 kg', '450 FCFA/kg', 'En Attente', 'En Stock'),
    ('Riz Basmati', 'Céréales', '800 kg', '550 FCFA/kg', 'Actif', 'En Stock'),
    ('Oignon', 'Légumes', '400 kg', '150 FCFA/kg', 'Inactif', 'Rupture'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Crops',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.foreground)),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Crop',
                      style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 44,
              headingTextStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mutedFg),
              dataTextStyle:
                  const TextStyle(fontSize: 13, color: AppTheme.foreground),
              columns: const [
                DataColumn(label: Text('Crop Name')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                for (final c in _crops)
                  DataRow(cells: [
                    DataCell(Text(c.$1,
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(_CategoryChip(c.$2)),
                    DataCell(Text(c.$3)),
                    DataCell(Text(c.$4,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGreen))),
                    DataCell(_StatusBadge(c.$5)),
                    DataCell(_StockBadge(c.$6)),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          onPressed: () {},
                          tooltip: 'Edit',
                          color: AppTheme.mutedFg,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16),
                          onPressed: () {},
                          tooltip: 'Delete',
                          color: AppTheme.creditRed,
                        ),
                      ],
                    )),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.muted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 11, color: AppTheme.mutedFg)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    switch (status) {
      case 'Active':
        color = const Color(0xFF1B5E20);
        bg = const Color(0xFFE8F5E9);
        break;
      case 'Pending':
        color = const Color(0xFFF57C00);
        bg = const Color(0xFFFFF3E0);
        break;
      default:
        color = AppTheme.mutedFg;
        bg = AppTheme.muted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final String stock;
  const _StockBadge(this.stock);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (stock) {
      case 'In Stock':
        color = AppTheme.primaryGreen;
        break;
      case 'Low Stock':
        color = AppTheme.accentOrange;
        break;
      default:
        color = AppTheme.creditRed;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(stock,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
