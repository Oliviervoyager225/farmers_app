import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../constants/api_endpoints.dart';
import '../../commons/data/models/models.dart';

class ProductService {
  final ApiClient _client;

  ProductService(this._client);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _client.get(ApiEndpoints.categories);
      final list = response.data['data'] as List;
      return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Product>> getProducts({int? categoryId}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.products,
        params: categoryId != null ? {'category_id': categoryId} : null,
      );
      final list = response.data['data'] as List;
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      final response = await _client.get(ApiEndpoints.productById(id));
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
