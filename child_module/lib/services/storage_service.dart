import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'service_locator.dart';

class StorageService {
  final SharedPreferences _prefs = getIt<SharedPreferences>();

  // Get app documents directory
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Get app temporary directory
  Future<Directory> getTemporaryDirectory() async {
    return await getTemporaryDirectory();
  }

  // Get app support directory
  Future<Directory> getSupportDirectory() async {
    return await getApplicationSupportDirectory();
  }

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

  // Save double value
  Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  // Get double value
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // Save string list
  Future<void> saveStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  // Get string list
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // Remove value
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Clear all values
  Future<void> clear() async {
    await _prefs.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  // Save file
  Future<File> saveFile(String fileName, List<int> bytes) async {
    final directory = await getDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.writeAsBytes(bytes);
  }

  // Read file
  Future<List<int>> readFile(String fileName) async {
    final directory = await getDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.readAsBytes();
  }

  // Delete file
  Future<void> deleteFile(String fileName) async {
    final directory = await getDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Check if file exists
  Future<bool> fileExists(String fileName) async {
    final directory = await getDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.exists();
  }

  // Get file size
  Future<int> getFileSize(String fileName) async {
    final directory = await getDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  // List files in directory
  Future<List<FileSystemEntity>> listFiles() async {
    final directory = await getDocumentsDirectory();
    return directory.listSync();
  }

  // Clear temporary directory
  Future<void> clearTemporaryDirectory() async {
    final directory = await getTemporaryDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
      await directory.create();
    }
  }

  // Get storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    final documentsDir = await getDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();
    final supportDir = await getSupportDirectory();

    return {
      'documents_path': documentsDir.path,
      'temporary_path': tempDir.path,
      'support_path': supportDir.path,
    };
  }
}

