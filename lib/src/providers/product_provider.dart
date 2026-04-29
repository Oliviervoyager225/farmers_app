import 'package:flutter/material.dart';
import '../commons/data/models/category.dart';
import '../commons/data/models/product.dart';
import '../core/services/product_service.dart';
import '../core/network/api_exception.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service;

  ProductProvider(this._service);

  List<Category> _categories = [];
  List<Product> _products = [];
  int? _selectedCategoryId;
  bool _loading = false;
  String? _error;

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  int? get selectedCategoryId => _selectedCategoryId;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _loading = true;
    notifyListeners();
    try {
      _categories = await _service.getCategories();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({int? categoryId}) async {
    _selectedCategoryId = categoryId;
    _loading = true;
    notifyListeners();
    try {
      _products = await _service.getProducts(categoryId: categoryId);
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
