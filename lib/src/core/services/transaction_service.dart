import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../network/paged_result.dart';
import '../constants/api_endpoints.dart';
import '../../commons/data/models/models.dart';

export '../network/paged_result.dart';

class TransactionService {
  final ApiClient _client;

  TransactionService(this._client);

  Future<Transaction> create(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(ApiEndpoints.transactions, data: data);
      return Transaction.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Transaction>> getAll({int? farmerId}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.transactions,
        params: farmerId != null ? {'farmer_id': farmerId} : null,
      );
      final list = response.data['data'] as List;
      return list.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PagedResult<Transaction>> getPaged({
    int page = 1,
    int perPage = 15,
    int? farmerId,
  }) async {
    try {
      final params = <String, dynamic>{'per_page': perPage, 'page': page};
      if (farmerId != null) params['farmer_id'] = farmerId;

      final response = await _client.get(ApiEndpoints.transactions, params: params);
      final data = response.data;
      final list = (data['data'] as List)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
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

  Future<Transaction> getById(int id) async {
    try {
      final response = await _client.get(ApiEndpoints.transactionById(id));
      return Transaction.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
