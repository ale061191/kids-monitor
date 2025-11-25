import 'package:flutter/foundation.dart';

import '../models/device_model.dart';
import '../services/service_locator.dart';
import '../services/device_service.dart';
import '../services/supabase_service.dart';

class DeviceProvider with ChangeNotifier {
  final DeviceService _deviceService = getIt<DeviceService>();
  final SupabaseService _supabaseService = getIt<SupabaseService>();

  DeviceModel? _device;
  bool _isLoading = false;
  String? _error;
  bool _isLinked = false;

  DeviceModel? get device => _device;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isRegistered => _deviceService.isDeviceRegistered();
  bool get isLinked => _isLinked;

  // Initialize
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_deviceService.isDeviceRegistered()) {
        await _deviceService.loadDeviceInfo();
        _device = _deviceService.currentDevice;
        await checkIfLinked();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register device
  Future<void> registerDevice({
    required String deviceName,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _device = await _deviceService.registerDevice(
        deviceName: deviceName,
        userId: userId,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update device status
  Future<void> updateDeviceStatus({required bool isOnline}) async {
    try {
      await _deviceService.updateDeviceStatus(isOnline: isOnline);
      _device = _deviceService.currentDevice;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Update device info
  Future<void> updateDeviceInfo() async {
    try {
      await _deviceService.updateDeviceInfo();
      _device = _deviceService.currentDevice;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Check if device is linked
  Future<void> checkIfLinked() async {
    try {
      _isLinked = await _deviceService.isDeviceLinked();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Unregister device
  Future<void> unregisterDevice() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _deviceService.unregisterDevice();
      _device = null;
      _isLinked = false;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get device code
  String? getDeviceCode() {
    return _deviceService.getDeviceCode();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

