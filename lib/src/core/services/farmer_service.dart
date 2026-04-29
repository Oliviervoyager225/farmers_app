import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../constants/api_endpoints.dart';
import '../../commons/data/models/models.dart';

class FarmerService {
  final ApiClient _client;

  FarmerService(this._client);

  Future<List<Farmer>> getAll() async {
    try {
      final response = await _client.get(ApiEndpoints.farmers);
      final list = response.data['data'] as List;
      return list.map((e) => Farmer.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Farmer> getById(int id) async {
    try {
      final response = await _client.get(ApiEndpoints.farmerById(id));
      return Farmer.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Farmer>> search(String query) async {
    try {
      final response = await _client.get(
        ApiEndpoints.farmers,
        params: {'search': query},
      );
      final list = response.data['data'] as List;
      return list.map((e) => Farmer.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Farmer> create(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(ApiEndpoints.farmers, data: data);
      return Farmer.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Farmer> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _client.put(ApiEndpoints.farmerById(id), data: data);
      return Farmer.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<FarmerDebtSummary> getDebtSummary(int farmerId) async {
    try {
      final response = await _client.get(ApiEndpoints.farmerDebts(farmerId));
      return FarmerDebtSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
