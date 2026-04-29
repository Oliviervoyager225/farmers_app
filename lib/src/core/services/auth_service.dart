import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../constants/api_endpoints.dart';
import '../local/local_storage.dart';
import '../../commons/data/models/user.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<User> login(String email, String password) async {
    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      await LocalStorage.saveToken(token);
      await LocalStorage.saveString(
        'user_data',
        user.toJsonString(),
      );
      return user;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } catch (_) {
      // même si le serveur échoue, on nettoie localement
    } finally {
      await LocalStorage.clearAll();
    }
  }

  Future<User?> getMe() async {
    try {
      final response = await _client.get(ApiEndpoints.me);
      return User.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
