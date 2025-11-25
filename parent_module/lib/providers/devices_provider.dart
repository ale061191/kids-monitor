import 'package:flutter/foundation.dart';

import '../models/device_link_model.dart';
import '../services/service_locator.dart';
import '../services/device_service.dart';

class DevicesProvider with ChangeNotifier {
  final DeviceService _deviceService = getIt<DeviceService>();

  List<DeviceLinkModel> _devices = [];
  bool _isLoading = false;
  String? _error;

  List<DeviceLinkModel> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load devices
  Future<void> loadDevices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _devices = await _deviceService.getLinkedDevices();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Link device
  Future<void> linkDevice(String deviceCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final device = await _deviceService.linkDeviceByCode(deviceCode);
      _devices.add(device);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Unlink device
  Future<void> unlinkDevice(String linkId) async {
    try {
      await _deviceService.unlinkDevice(linkId);
      _devices.removeWhere((device) => device.id == linkId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Update device nickname
  Future<void> updateDeviceNickname(String linkId, String nickname) async {
    try {
      await _deviceService.updateDeviceNickname(linkId, nickname);
      final index = _devices.indexWhere((device) => device.id == linkId);
      if (index != -1) {
        // Reload devices to get updated data
        await loadDevices();
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

