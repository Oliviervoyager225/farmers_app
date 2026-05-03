import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../network/paged_result.dart';
import '../constants/api_endpoints.dart';
import '../../commons/data/models/user.dart';

class UserService {
  final ApiClient _client;

  UserService(this._client);

  Future<PagedResult<User>> getPaged({int page = 1, int perPage = 15}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.users,
        params: {'per_page': perPage, 'page': page},
      );
      final data = response.data;
      final list = (data['data'] as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = data['meta'] as Map<String, dynamic>? ?? {};
      return PagedResult(
        items: list,
        total: (meta['total'] as int?) ?? list.length,
        currentPage: (meta['current_page'] as int?) ?? page,
        lastPage: (meta['last_page'] as int?) ?? 1,
        perPage: (meta['per_page'] as int?) ?? perPage,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<User> getById(int id) async {
    try {
      final response = await _client.get(ApiEndpoints.userById(id));
      return User.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<User> create(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(ApiEndpoints.users, data: data);
      return User.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<User> update(int id, Map<String, dynamic> data) async {
    try {
      final response =
          await _client.put(ApiEndpoints.userById(id), data: data);
      return User.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _client.delete(ApiEndpoints.userById(id));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
