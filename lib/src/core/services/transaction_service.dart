import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../constants/api_endpoints.dart';
import '../../commons/data/models/models.dart';

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
}
