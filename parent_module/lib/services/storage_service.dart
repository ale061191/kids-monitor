import 'package:shared_preferences/shared_preferences.dart';

import 'service_locator.dart';

class StorageService {
  final SharedPreferences _prefs = getIt<SharedPreferences>();

  // Save string value
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  // Get string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Save int value
  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  // Get int value
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Save bool value
  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  // Get bool value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Remove value
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Clear all values
  Future<void> clear() async {
    await _prefs.clear();
  }
}

