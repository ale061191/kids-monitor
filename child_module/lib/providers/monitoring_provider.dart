import 'package:flutter/foundation.dart';

import '../models/command_model.dart';
import '../services/service_locator.dart';
import '../services/command_service.dart';
import '../services/camera_service.dart';
import '../services/audio_service.dart';
import '../services/location_service.dart';
import '../services/webrtc_service.dart';

class MonitoringProvider with ChangeNotifier {
  final CommandService _commandService = getIt<CommandService>();
  final CameraService _cameraService = getIt<CameraService>();
  final AudioService _audioService = getIt<AudioService>();
  final LocationService _locationService = getIt<LocationService>();
  final WebRTCService _webrtcService = getIt<WebRTCService>();

  bool _isListening = false;
  bool _isCameraActive = false;
  bool _isAudioActive = false;
  bool _isLocationTracking = false;
  bool _isRecording = false;
  List<CommandModel> _recentCommands = [];
  String? _error;

  bool get isListening => _isListening;
  bool get isCameraActive => _isCameraActive;
  bool get isAudioActive => _isAudioActive;
  bool get isLocationTracking => _isLocationTracking;
  bool get isRecording => _isRecording;
  List<CommandModel> get recentCommands => _recentCommands;
  String? get error => _error;

  // Start monitoring
  Future<void> startMonitoring() async {
    try {
      await _commandService.startListening();
      _isListening = true;

      // Listen to command stream
      _commandService.commandStream?.listen((command) {
        _recentCommands.insert(0, command);
        if (_recentCommands.length > 20) {
          _recentCommands.removeLast();
        }
        _updateMonitoringStatus();
        notifyListeners();
      });

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Stop monitoring
  Future<void> stopMonitoring() async {
    try {
      await _commandService.stopListening();
      _isListening = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update monitoring status based on services
  void _updateMonitoringStatus() {
    _isCameraActive = _cameraService.isInitialized;
    _isAudioActive = _audioService.isRecording;
    _isLocationTracking = _locationService.isTracking;
    _isRecording = _audioService.isRecording;
  }

  // Get monitoring status
  Map<String, dynamic> getMonitoringStatus() {
    return {
      'listening': _isListening,
      'camera_active': _isCameraActive,
      'audio_active': _isAudioActive,
      'location_tracking': _isLocationTracking,
      'recording': _isRecording,
      'recent_commands_count': _recentCommands.length,
    };
  }

  // Clear recent commands
  void clearRecentCommands() {
    _recentCommands.clear();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _commandService.dispose();
    super.dispose();
  }
}

