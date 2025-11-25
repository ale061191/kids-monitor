import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/device_model.dart';
import 'service_locator.dart';
import 'supabase_service.dart';

class DeviceService {
  final SupabaseService _supabaseService = getIt<SupabaseService>();
  final SharedPreferences _prefs = getIt<SharedPreferences>();
  
  static const String _deviceIdKey = 'device_id';
  static const String _deviceCodeKey = 'device_code';
  static const String _deviceRegisteredKey = 'device_registered';

  DeviceModel? _currentDevice;

  Future<void> initialize() async {
    // Load device info if already registered
    if (isDeviceRegistered()) {
      await loadDeviceInfo();
    }
  }

  // Check if device is registered
  bool isDeviceRegistered() {
    return _prefs.getBool(_deviceRegisteredKey) ?? false;
  }

  // Get or create device ID
  Future<String> getDeviceId() async {
    String? deviceId = _prefs.getString(_deviceIdKey);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await _prefs.setString(_deviceIdKey, deviceId);
    }
    return deviceId;
  }

  // Get device code
  String? getDeviceCode() {
    return _prefs.getString(_deviceCodeKey);
  }

  // Get device info
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'device_model': '${androidInfo.manufacturer} ${androidInfo.model}',
        'os_version': 'Android ${androidInfo.version.release}',
        'app_version': packageInfo.version,
        'platform': 'android',
        'sdk_version': androidInfo.version.sdkInt,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'device_model': '${iosInfo.name} ${iosInfo.model}',
        'os_version': 'iOS ${iosInfo.systemVersion}',
        'app_version': packageInfo.version,
        'platform': 'ios',
      };
    }

    return {
      'device_model': 'Unknown',
      'os_version': 'Unknown',
      'app_version': packageInfo.version,
      'platform': 'unknown',
    };
  }

  // Register device
  Future<DeviceModel> registerDevice({
    required String deviceName,
    required String userId,
  }) async {
    try {
      final deviceId = await getDeviceId();
      final deviceInfo = await getDeviceInfo();

      // Generate device code using Supabase function
      final response = await _supabaseService.client
          .rpc('generate_device_code')
          .select();
      
      final deviceCode = response as String;

      // Create device in database
      final deviceData = {
        'device_name': deviceName,
        'device_code': deviceCode,
        'device_id': deviceId,
        'child_user_id': userId,
        'device_model': deviceInfo['device_model'],
        'os_version': deviceInfo['os_version'],
        'app_version': deviceInfo['app_version'],
        'is_online': true,
        'last_seen': DateTime.now().toIso8601String(),
      };

      final result = await _supabaseService.insert('devices', deviceData);
      
      // Save device info locally
      await _prefs.setString(_deviceCodeKey, deviceCode);
      await _prefs.setBool(_deviceRegisteredKey, true);

      _currentDevice = DeviceModel.fromJson(result);

      // Log activity
      await _supabaseService.logActivity(
        userId: userId,
        deviceId: _currentDevice!.id,
        activityType: 'device_registered',
        description: 'Device registered successfully',
        metadata: deviceInfo,
      );

      return _currentDevice!;
    } catch (e) {
      throw Exception('Failed to register device: $e');
    }
  }

  // Load device info from database
  Future<void> loadDeviceInfo() async {
    try {
      final deviceId = await getDeviceId();
      final results = await _supabaseService.select(
        'devices',
        filter: 'device_id=eq.$deviceId',
        limit: 1,
      );

      if (results.isNotEmpty) {
        _currentDevice = DeviceModel.fromJson(results.first);
      }
    } catch (e) {
      throw Exception('Failed to load device info: $e');
    }
  }

  // Update device status
  Future<void> updateDeviceStatus({
    required bool isOnline,
  }) async {
    if (_currentDevice == null) return;

    try {
      await _supabaseService.update(
        'devices',
        _currentDevice!.id,
        {
          'is_online': isOnline,
          'last_seen': DateTime.now().toIso8601String(),
        },
      );

      _currentDevice = _currentDevice!.copyWith(
        isOnline: isOnline,
        lastSeen: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to update device status: $e');
    }
  }

  // Update device info
  Future<void> updateDeviceInfo() async {
    if (_currentDevice == null) return;

    try {
      final deviceInfo = await getDeviceInfo();
      
      await _supabaseService.update(
        'devices',
        _currentDevice!.id,
        {
          'device_model': deviceInfo['device_model'],
          'os_version': deviceInfo['os_version'],
          'app_version': deviceInfo['app_version'],
        },
      );

      _currentDevice = _currentDevice!.copyWith(
        deviceModel: deviceInfo['device_model'],
        osVersion: deviceInfo['os_version'],
        appVersion: deviceInfo['app_version'],
      );
    } catch (e) {
      throw Exception('Failed to update device info: $e');
    }
  }

  // Get current device
  DeviceModel? get currentDevice => _currentDevice;

  // Unregister device
  Future<void> unregisterDevice() async {
    if (_currentDevice == null) return;

    try {
      await _supabaseService.delete('devices', _currentDevice!.id);
      
      await _prefs.remove(_deviceCodeKey);
      await _prefs.setBool(_deviceRegisteredKey, false);
      
      _currentDevice = null;
    } catch (e) {
      throw Exception('Failed to unregister device: $e');
    }
  }

  // Check if device is linked to a parent
  Future<bool> isDeviceLinked() async {
    if (_currentDevice == null) return false;

    try {
      final results = await _supabaseService.select(
        'device_links',
        filter: 'device_id=eq.${_currentDevice!.id}',
      );

      return results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

