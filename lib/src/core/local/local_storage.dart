import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LocalStorage {
  LocalStorage._();

  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  // ─── Secure (token) ─────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) =>
      _secure.write(key: AppConstants.keyToken, value: token);

  static Future<String?> getToken() =>
      _secure.read(key: AppConstants.keyToken);

  static Future<void> deleteToken() =>
      _secure.delete(key: AppConstants.keyToken);

  // ─── Shared Preferences ─────────────────────────────────────────────────────
  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  static Future<void> saveString(String key, String value) async =>
      (await _prefs).setString(key, value);

  static Future<String?> getString(String key) async =>
      (await _prefs).getString(key);

  static Future<void> remove(String key) async =>
      (await _prefs).remove(key);

  static Future<void> clearAll() async {
    await _secure.deleteAll();
    (await _prefs).clear();
  }
}
