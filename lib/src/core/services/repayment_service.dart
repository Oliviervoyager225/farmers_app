import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../constants/api_endpoints.dart';
import '../../commons/data/models/models.dart';

class RepaymentService {
  final ApiClient _client;

  RepaymentService(this._client);

  /// Enregistre un remboursement en kg de produit agricole.
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
          await _client.get(ApiEndpoints.repaymentsByFarmer(farmerId));
      final list = response.data['data'] as List;
      return list
          .map((e) => Repayment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
