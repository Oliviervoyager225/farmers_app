import 'package:flutter/material.dart';
import '../commons/data/models/transaction.dart';
import '../core/services/transaction_service.dart';
import '../core/network/api_exception.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service;

  TransactionProvider(this._service);

  List<Transaction> _transactions = [];
  int _total = 0;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loading = false;
  String? _error;
  int? _filterFarmerId;

  List<Transaction> get transactions => _transactions;
  int get total => _total;
  bool get hasMore => _currentPage < _lastPage;
  bool get loading => _loading;
  String? get error => _error;
  int? get filterFarmerId => _filterFarmerId;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  Future<void> loadPage({int page = 1, int perPage = 20, int? farmerId}) async {
    _filterFarmerId = farmerId;
    _setLoading(true);
    try {
      final result = await _service.getPaged(
        page: page,
        perPage: perPage,
        farmerId: farmerId,
      );
      if (page == 1) {
        _transactions = result.items;
      } else {
        _transactions = [..._transactions, ...result.items];
      }
      _total = result.total;
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || _loading) return;
    await loadPage(page: _currentPage + 1, farmerId: _filterFarmerId);
  }

  Future<void> reload() async {
    await loadPage(farmerId: _filterFarmerId);
  }
}
