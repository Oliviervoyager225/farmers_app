import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../constants/api_endpoints.dart';
import '../../commons/data/models/app_settings.dart';

class SettingsService {
  final ApiClient _client;

  SettingsService(this._client);

  Future<AppSettings> getSettings() async {
    try {
      final response = await _client.get(ApiEndpoints.settings);
      return AppSettings.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AppSettings> updateSettings(Map<String, dynamic> data) async {
    try {
      final response = await _client.put(ApiEndpoints.settings, data: data);
      return AppSettings.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
