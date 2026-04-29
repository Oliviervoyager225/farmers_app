import 'package:flutter/material.dart';
import '../commons/data/models/user.dart';
import '../core/services/auth_service.dart';
import '../core/local/local_storage.dart';
import '../core/network/api_exception.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

// TODO: supprimer ce flag quand le backend est prêt
const bool _kDemoMode = true;
const String _kDemoEmail = 'admin@farmbridge.com';
const String _kDemoPassword = 'demo1234';
final User _kDemoUser = const User(
  id: 1,
  name: 'Admin Demo',
  email: _kDemoEmail,
  role: 'admin',
);

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _error;
  bool _loading = false;

  AuthProvider(this._authService);

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> init() async {
    if (_kDemoMode) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    final token = await LocalStorage.getToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      _user = await _authService.getMe();
      _status = AuthStatus.authenticated;
    } catch (_) {
      await LocalStorage.clearAll();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (_kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (email == _kDemoEmail && password == _kDemoPassword) {
        _user = _kDemoUser;
        _status = AuthStatus.authenticated;
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Email ou mot de passe incorrect (mode démo)';
        _loading = false;
        notifyListeners();
        return false;
      }
    }

    try {
      _user = await _authService.login(email, password);
      _status = AuthStatus.authenticated;
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (_kDemoMode) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
