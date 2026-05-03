import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../network/paged_result.dart';
import '../constants/api_endpoints.dart';
import '../../commons/data/models/models.dart';

class RepaymentService {
  final ApiClient _client;

  RepaymentService(this._client);

  Future<Repayment> create(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(ApiEndpoints.repayments, data: data);
      return Repayment.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Repayment>> getByFarmer(int farmerId) async {
    try {
      final response =
          await _client.get(ApiEndpoints.farmerRepayments(farmerId));
      final list = response.data['data'] as List;
      return list
          .map((e) => Repayment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Repayment>> getAll({int? farmerId}) async {
    try {
      final params = <String, dynamic>{'per_page': 100};
      if (farmerId != null) params['farmer_id'] = farmerId;
      final response =
          await _client.get(ApiEndpoints.repayments, params: params);
      final list = response.data['data'] as List;
      return list
          .map((e) => Repayment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PagedResult<Repayment>> getPaged({
    int page = 1,
    int perPage = 15,
    int? farmerId,
  }) async {
    try {
      final params = <String, dynamic>{'per_page': perPage, 'page': page};
      if (farmerId != null) params['farmer_id'] = farmerId;

      final response =
          await _client.get(ApiEndpoints.repayments, params: params);
      final data = response.data;
      final list = (data['data'] as List)
          .map((e) => Repayment.fromJson(e as Map<String, dynamic>))
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

  Future<Repayment> getById(int id) async {
    try {
      final response = await _client.get(ApiEndpoints.repaymentById(id));
      return Repayment.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
