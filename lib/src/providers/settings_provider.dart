import 'package:flutter/material.dart';
import '../commons/data/models/app_settings.dart';
import '../core/services/settings_service.dart';
import '../core/network/api_exception.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service;

  SettingsProvider(this._service);

  AppSettings? _settings;
  bool _loading = false;
  String? _error;

  AppSettings? get settings => _settings;
  bool get loading => _loading;
  String? get error => _error;

  double get kgRate => _settings?.kgToCfaRate ?? 1000;
  double get interestRate => _settings?.defaultInterestRate ?? 0.30;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _settings = await _service.getSettings();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
