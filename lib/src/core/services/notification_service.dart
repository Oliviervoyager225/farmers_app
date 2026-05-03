import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../constants/api_endpoints.dart';
import '../../commons/data/models/app_notification.dart';

class NotificationService {
  final ApiClient _client;

  NotificationService(this._client);

  Future<List<AppNotification>> getAll() async {
    try {
      final response = await _client.get(ApiEndpoints.notifications);
      final list = response.data['data'] as List;
      return list
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _client.get(ApiEndpoints.notificationsUnreadCount);
      return (response.data['data']['count'] as int?) ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> markAsRead(String key) async {
    try {
      await _client.put(ApiEndpoints.notificationMarkRead(key));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _client.put(ApiEndpoints.notificationsReadAll);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
