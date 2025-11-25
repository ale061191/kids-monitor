import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/command_model.dart';
import 'service_locator.dart';
import 'supabase_service.dart';
import 'device_service.dart';
import 'camera_service.dart';
import 'audio_service.dart';
import 'location_service.dart';
import 'webrtc_service.dart';
import 'notification_service.dart';

class CommandService {
  final SupabaseService _supabaseService = getIt<SupabaseService>();
  final DeviceService _deviceService = getIt<DeviceService>();
  final CameraService _cameraService = getIt<CameraService>();
  final AudioService _audioService = getIt<AudioService>();
  final LocationService _locationService = getIt<LocationService>();
  final WebRTCService _webrtcService = getIt<WebRTCService>();
  final NotificationService _notificationService = getIt<NotificationService>();

  RealtimeChannel? _commandChannel;
  StreamController<CommandModel>? _commandStreamController;

  // Start listening for commands
  Future<void> startListening() async {
    final device = _deviceService.currentDevice;
    if (device == null) {
      throw Exception('Device not registered');
    }

    _commandStreamController = StreamController<CommandModel>.broadcast();

    _commandChannel = _supabaseService.subscribeToCommands(
      deviceId: device.id,
      onCommand: (data) {
        final command = CommandModel.fromJson(data);
        _commandStreamController?.add(command);
        _executeCommand(command);
      },
    );
  }

  // Stop listening for commands
  Future<void> stopListening() async {
    await _commandChannel?.unsubscribe();
    _commandChannel = null;
    await _commandStreamController?.close();
    _commandStreamController = null;
  }

  // Execute command
  Future<void> _executeCommand(CommandModel command) async {
    try {
      // Check if command is expired
      if (command.isExpired) {
        await _updateCommandStatus(
          command.id,
          CommandStatus.failed,
          {'error': 'Command expired'},
        );
        return;
      }

      // Update status to sent
      await _updateCommandStatus(command.id, CommandStatus.sent, null);

      // Show notification if enabled
      if (_notificationService.areNotificationsEnabled()) {
        await _showCommandNotification(command.commandType);
      }

      // Execute based on command type
      Map<String, dynamic>? response;

      switch (command.commandType) {
        case CommandType.startVideo:
          response = await _handleStartVideo(command);
          break;
        case CommandType.stopVideo:
          response = await _handleStopVideo(command);
          break;
        case CommandType.switchCamera:
          response = await _handleSwitchCamera(command);
          break;
        case CommandType.startAudio:
          response = await _handleStartAudio(command);
          break;
        case CommandType.stopAudio:
          response = await _handleStopAudio(command);
          break;
        case CommandType.takeSnapshot:
          response = await _handleTakeSnapshot(command);
          break;
        case CommandType.startRecording:
          response = await _handleStartRecording(command);
          break;
        case CommandType.stopRecording:
          response = await _handleStopRecording(command);
          break;
        case CommandType.getLocation:
          response = await _handleGetLocation(command);
          break;
        case CommandType.getDeviceInfo:
          response = await _handleGetDeviceInfo(command);
          break;
      }

      // Update status to executed
      await _updateCommandStatus(
        command.id,
        CommandStatus.executed,
        response,
      );
    } catch (e) {
      // Update status to failed
      await _updateCommandStatus(
        command.id,
        CommandStatus.failed,
        {'error': e.toString()},
      );
    }
  }

  // Command handlers
  Future<Map<String, dynamic>> _handleStartVideo(CommandModel command) async {
    final sessionId = command.parameters?['session_id'] as String?;
    await _webrtcService.startVideoStream(
      audio: command.parameters?['audio'] as bool? ?? false,
      sessionId: sessionId,
    );
    return {'success': true, 'message': 'Video streaming started'};
  }

  Future<Map<String, dynamic>> _handleStopVideo(CommandModel command) async {
    await _webrtcService.stopStreaming();
    return {'success': true, 'message': 'Video streaming stopped'};
  }

  Future<Map<String, dynamic>> _handleSwitchCamera(CommandModel command) async {
    await _cameraService.switchCamera();
    return {
      'success': true,
      'message': 'Camera switched',
      'current_camera': _cameraService.currentLensDirection.toString(),
    };
  }

  Future<Map<String, dynamic>> _handleStartAudio(CommandModel command) async {
    final sessionId = command.parameters?['session_id'] as String?;
    await _webrtcService.startAudioStream(sessionId: sessionId);
    return {'success': true, 'message': 'Audio streaming started'};
  }

  Future<Map<String, dynamic>> _handleStopAudio(CommandModel command) async {
    await _webrtcService.stopStreaming();
    return {'success': true, 'message': 'Audio streaming stopped'};
  }

  Future<Map<String, dynamic>> _handleTakeSnapshot(CommandModel command) async {
    final device = _deviceService.currentDevice;
    if (device == null) {
      throw Exception('Device not registered');
    }

    // Initialize camera if not already
    if (!_cameraService.isInitialized) {
      await _cameraService.initialize();
    }

    // Take snapshot
    final imageBytes = await _cameraService.takeSnapshotBytes();

    // Upload to Supabase Storage
    final fileName = 'snapshot_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '${device.id}/$fileName';
    
    final publicUrl = await _supabaseService.uploadFile(
      bucket: 'snapshots',
      path: filePath,
      fileBytes: imageBytes,
      contentType: 'image/jpeg',
    );

    // Save to media_files table
    await _supabaseService.insert('media_files', {
      'device_id': device.id,
      'parent_user_id': command.parentUserId,
      'file_type': 'snapshot',
      'file_path': filePath,
      'file_size': imageBytes.length,
      'metadata': {
        'camera': _cameraService.currentLensDirection.toString(),
      },
    });

    return {
      'success': true,
      'message': 'Snapshot taken',
      'file_url': publicUrl,
      'file_path': filePath,
    };
  }

  Future<Map<String, dynamic>> _handleStartRecording(CommandModel command) async {
    final type = command.parameters?['type'] as String? ?? 'audio';
    
    if (type == 'audio') {
      await _audioService.startRecording();
      return {'success': true, 'message': 'Audio recording started'};
    } else {
      // Video recording would be handled differently
      return {'success': false, 'message': 'Video recording not implemented'};
    }
  }

  Future<Map<String, dynamic>> _handleStopRecording(CommandModel command) async {
    final device = _deviceService.currentDevice;
    if (device == null) {
      throw Exception('Device not registered');
    }

    final file = await _audioService.stopRecording();
    if (file == null) {
      throw Exception('No recording to stop');
    }

    // Upload to Supabase Storage
    final fileBytes = await file.readAsBytes();
    final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.aac';
    final filePath = '${device.id}/$fileName';
    
    final publicUrl = await _supabaseService.uploadFile(
      bucket: 'audio-recordings',
      path: filePath,
      fileBytes: fileBytes,
      contentType: 'audio/aac',
    );

    // Save to media_files table
    await _supabaseService.insert('media_files', {
      'device_id': device.id,
      'parent_user_id': command.parentUserId,
      'file_type': 'audio_recording',
      'file_path': filePath,
      'file_size': fileBytes.length,
    });

    // Delete temporary file
    await file.delete();

    return {
      'success': true,
      'message': 'Recording stopped and uploaded',
      'file_url': publicUrl,
      'file_path': filePath,
    };
  }

  Future<Map<String, dynamic>> _handleGetLocation(CommandModel command) async {
    final location = await _locationService.getAndSaveLocation();
    
    if (location == null) {
      throw Exception('Failed to get location');
    }

    return {
      'success': true,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracy': location.accuracy,
        'altitude': location.altitude,
        'speed': location.speed,
        'heading': location.heading,
        'address': location.address,
        'timestamp': location.recordedAt.toIso8601String(),
      },
    };
  }

  Future<Map<String, dynamic>> _handleGetDeviceInfo(CommandModel command) async {
    final deviceInfo = await _deviceService.getDeviceInfo();
    final cameraInfo = _cameraService.getCameraInfo();
    final audioInfo = _audioService.getAudioInfo();
    final locationInfo = _locationService.getLocationInfo();

    return {
      'success': true,
      'device_info': deviceInfo,
      'camera_info': cameraInfo,
      'audio_info': audioInfo,
      'location_info': locationInfo,
    };
  }

  // Update command status
  Future<void> _updateCommandStatus(
    String commandId,
    CommandStatus status,
    Map<String, dynamic>? response,
  ) async {
    final updateData = {
      'status': status.value,
      'response': response,
    };

    if (status == CommandStatus.executed || status == CommandStatus.failed) {
      updateData['executed_at'] = DateTime.now().toIso8601String();
    }

    await _supabaseService.update('commands', commandId, updateData);
  }

  // Show command notification
  Future<void> _showCommandNotification(CommandType commandType) async {
    String type = '';
    
    switch (commandType) {
      case CommandType.startVideo:
        type = 'camera';
        break;
      case CommandType.startAudio:
        type = 'audio';
        break;
      case CommandType.getLocation:
        type = 'location';
        break;
      case CommandType.takeSnapshot:
        type = 'snapshot';
        break;
      case CommandType.startRecording:
        type = 'recording';
        break;
      default:
        return;
    }

    await _notificationService.showMonitoringNotification(type: type);
  }

  // Get command stream
  Stream<CommandModel>? get commandStream => _commandStreamController?.stream;

  // Dispose
  Future<void> dispose() async {
    await stopListening();
  }
}

