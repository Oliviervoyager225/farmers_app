import 'package:flutter/material.dart';
import '../commons/data/models/user.dart';
import '../core/services/user_service.dart';
import '../core/network/api_exception.dart';

class UserProvider extends ChangeNotifier {
  final UserService _service;

  UserProvider(this._service);

  List<User> _users = [];
  int _total = 0;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loading = false;
  String? _error;

  List<User> get users => _users;
  int get total => _total;
  bool get hasMore => _currentPage < _lastPage;
  bool get loading => _loading;
  String? get error => _error;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  Future<void> loadPage({int page = 1, int perPage = 20}) async {
    _setLoading(true);
    try {
      final result = await _service.getPaged(page: page, perPage: perPage);
      if (page == 1) {
        _users = result.items;
      } else {
        _users = [..._users, ...result.items];
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
    await loadPage(page: _currentPage + 1);
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final user = await _service.create(data);
      _users = [user, ..._users];
      _total++;
      _error = null;
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final updated = await _service.update(id, data);
      _users = _users.map((u) => u.id == id ? updated : u).toList();
      _error = null;
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    _setLoading(true);
    try {
      await _service.delete(id);
      _users = _users.where((u) => u.id != id).toList();
      _total--;
      _error = null;
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    }
  }
}
