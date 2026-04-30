import 'package:flutter/material.dart';

/// Breakpoints (same as collecte_de_donnees_v1, adapted for farmers_app)
///  mobile      : ≤ 767 px
///  tablet      : 768 – 1024 px
///  desktop     : 1025 – 1399 px
///  largeDesktop: ≥ 1400 px

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  final Widget? largeDesktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.largeDesktop,
  });

  // ── static helpers ────────────────────────────────────────────────────────

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= 767;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 768 && w <= 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 1024;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1400;

  /// Horizontal page padding that scales with screen size
  static EdgeInsets pagePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1400) return const EdgeInsets.symmetric(horizontal: 80);
    if (w >= 1025) return const EdgeInsets.symmetric(horizontal: 40);
    if (w >= 768)  return const EdgeInsets.symmetric(horizontal: 24);
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  /// Number of grid columns for a card grid
  static int gridCols(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 4}) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1025) return desktop;
    if (w >= 768)  return tablet;
    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1400 && largeDesktop != null) return largeDesktop!;
    if (w >= 1025) return desktop;
    if (w >= 768 && tablet != null) return tablet!;
    return mobile;
  }
}

/// Thin wrapper that reads MediaQuery once and exposes handy getters.
/// Call [SizeConfig.init] at the top of any [build] that needs it.
class SizeConfig {
  SizeConfig._();

  static double screenWidth  = 0;
  static double screenHeight = 0;

  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    screenWidth  = mq.size.width;
    screenHeight = mq.size.height;
  }

  static double blockH(double pct) => screenHeight * pct / 100;
  static double blockW(double pct) => screenWidth  * pct / 100;
}
