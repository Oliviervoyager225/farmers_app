import 'package:flutter/material.dart';
import '../commons/data/models/app_notification.dart';
import '../core/services/notification_service.dart';
import '../core/network/api_exception.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  NotificationProvider(this._service);

  List<AppNotification> _notifications = [];
  bool _loading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  bool get loading => _loading;
  String? get error => _error;

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  List<AppNotification> get unread =>
      _notifications.where((n) => !n.isRead).toList();

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await _service.getAll();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String key) async {
    try {
      await _service.markAsRead(key);
      _notifications = _notifications.map((n) {
        if (n.key == key) {
          return AppNotification(
            key:        n.key,
            type:       n.type,
            farmerId:   n.farmerId,
            farmerName: n.farmerName,
            title:      n.title,
            body:       n.body,
            isRead:     true,
            createdAt:  n.createdAt,
          );
        }
        return n;
      }).toList();
      notifyListeners();
    } on ApiException {
      // silent — badge will self-correct on next load()
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      _notifications = _notifications.map((n) => AppNotification(
        key:        n.key,
        type:       n.type,
        farmerId:   n.farmerId,
        farmerName: n.farmerName,
        title:      n.title,
        body:       n.body,
        isRead:     true,
        createdAt:  n.createdAt,
      )).toList();
      notifyListeners();
    } on ApiException {
      // silent
    }
  }
}
