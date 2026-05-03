import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/app_notification.dart';
import '../../providers/notification_provider.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kGreen      = Color(0xFF16A34A);
const _kRed        = Color(0xFFDC2626);
const _kOrange     = Color(0xFFD97706);
const _kBorder     = Color(0xFFE5E7EB);
const _kBg         = Color(0xFFF9FAFB);
const _kTitle      = Color(0xFF111827);
const _kMuted      = Color(0xFF6B7280);
const _kRedBg      = Color(0xFFFEF2F2);
const _kOrangeBg   = Color(0xFFFFFBEB);
const _kGreenBg    = Color(0xFFF0FDF4);

/// Opens the notification panel as a right-side overlay.
void showNotificationPanel(BuildContext context) {
  // Trigger load first
  context.read<NotificationProvider>().load();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Notifications',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, __) => const _NotificationPanel(),
    transitionBuilder: (ctx, anim, _, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
      return SlideTransition(position: slide, child: child);
    },
  );
}

class _NotificationPanel extends StatelessWidget {
  const _NotificationPanel();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        elevation: 16,
        color: Colors.white,
        child: SizedBox(
          width: _panelWidth(context),
          height: double.infinity,
          child: Column(
            children: [
              _PanelHeader(onClose: () => Navigator.of(context).pop()),
              const Divider(height: 1, color: _kBorder),
              const Expanded(child: _NotificationList()),
            ],
          ),
        ),
      ),
    );
  }

  double _panelWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 480) return w * 0.92;
    if (w < 900) return 380;
    return 420;
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _PanelHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificationProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          // Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _kGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          // Title + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Notifications',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _kTitle)),
                    if (prov.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kRed,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '${prov.unreadCount}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${prov.notifications.length} alerte(s)',
                  style:
                      const TextStyle(fontSize: 12, color: _kMuted),
                ),
              ],
            ),
          ),
          // Mark all read
          if (prov.unreadCount > 0)
            TextButton(
              onPressed: prov.markAllAsRead,
              style: TextButton.styleFrom(
                foregroundColor: _kGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                textStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: const Text('Tout lire'),
            ),
          // Close
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: _kMuted),
            onPressed: onClose,
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}

// ── List ──────────────────────────────────────────────────────────────────────

class _NotificationList extends StatelessWidget {
  const _NotificationList();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificationProvider>();

    if (prov.loading) {
      return const Center(
          child: CircularProgressIndicator(color: _kGreen));
    }

    if (prov.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: _kBg, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline,
                  size: 36, color: _kGreen),
            ),
            const SizedBox(height: 16),
            const Text('Aucune alerte',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _kTitle)),
            const SizedBox(height: 4),
            const Text('Tous les agriculteurs sont à jour.',
                style: TextStyle(fontSize: 13, color: _kMuted)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: prov.notifications.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 20, endIndent: 20, color: _kBorder),
      itemBuilder: (ctx, i) =>
          _NotifTile(notif: prov.notifications[i]),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  const _NotifTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    final (iconData, iconColor, bgColor) = _style(notif.type);

    return InkWell(
      onTap: () => context.read<NotificationProvider>().markAsRead(notif.key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: notif.isRead ? Colors.white : bgColor.withValues(alpha: 0.45),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: notif.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: _kTitle,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: _kRed, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.body,
                    style: const TextStyle(fontSize: 12, color: _kMuted),
                  ),
                  const SizedBox(height: 6),
                  // Farmer chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Text(
                      notif.farmerName,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _kTitle),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color, Color) _style(String type) {
    return switch (type) {
      'over_limit'   => (Icons.error_outline,      _kRed,    _kRedBg),
      'near_limit'   => (Icons.warning_amber_outlined, _kOrange, _kOrangeBg),
      'overdue_debt' => (Icons.access_time_outlined,  _kRed,    _kRedBg),
      _              => (Icons.info_outline,           _kGreen,  _kGreenBg),
    };
  }
}
