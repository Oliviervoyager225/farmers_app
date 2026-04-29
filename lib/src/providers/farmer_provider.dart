import 'package:flutter/material.dart';
import '../commons/data/models/farmer.dart';
import '../core/services/farmer_service.dart';
import '../core/network/api_exception.dart';

class FarmerProvider extends ChangeNotifier {
  final FarmerService _service;

  FarmerProvider(this._service);

  List<Farmer> _farmers = [];
  Farmer? _selected;
  FarmerDebtSummary? _debtSummary;
  bool _loading = false;
  String? _error;

  List<Farmer> get farmers => _farmers;
  Farmer? get selected => _selected;
  FarmerDebtSummary? get debtSummary => _debtSummary;
  bool get loading => _loading;
  String? get error => _error;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  Future<void> loadAll() async {
    _setLoading(true);
    try {
      _farmers = await _service.getAll();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> search(String query) async {
    _setLoading(true);
    try {
      _farmers = await _service.search(query);
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createFarmer(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final farmer = await _service.create(data);
      _farmers = [farmer, ..._farmers];
      _error = null;
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    }
  }

  Future<void> selectFarmer(int id) async {
    _setLoading(true);
    try {
      _selected = await _service.getById(id);
      _debtSummary = await _service.getDebtSummary(id);
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  void clearSelection() {
    _selected = null;
    _debtSummary = null;
    notifyListeners();
  }
}
