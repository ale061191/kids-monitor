import 'package:flutter/foundation.dart';

import '../services/service_locator.dart';
import '../services/command_service.dart';

class MonitoringProvider with ChangeNotifier {
  final CommandService _commandService = getIt<CommandService>();

  String? _activeDeviceId;
  bool _isMonitoring = false;
  bool _isLoading = false;
  String? _error;

  String? get activeDeviceId => _activeDeviceId;
  bool get isMonitoring => _isMonitoring;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set active device
  void setActiveDevice(String? deviceId) {
    _activeDeviceId = deviceId;
    notifyListeners();
  }

  // Start monitoring
  void startMonitoring() {
    _isMonitoring = true;
    notifyListeners();
  }

  // Stop monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    notifyListeners();
  }

  // Send command
  Future<String> sendCommand({
    required CommandType commandType,
    Map<String, dynamic>? parameters,
  }) async {
    if (_activeDeviceId == null) {
      throw Exception('No active device');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final commandId = await _commandService.sendCommand(
        deviceId: _activeDeviceId!,
        commandType: commandType,
        parameters: parameters,
      );
      return commandId;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

