import 'package:uuid/uuid.dart';

import 'service_locator.dart';
import 'supabase_service.dart';

enum CommandType {
  startVideo,
  stopVideo,
  switchCamera,
  startAudio,
  stopAudio,
  takeSnapshot,
  startRecording,
  stopRecording,
  getLocation,
  getDeviceInfo,
}

class CommandService {
  final SupabaseService _supabaseService = getIt<SupabaseService>();

  // Send command to device
  Future<String> sendCommand({
    required String deviceId,
    required CommandType commandType,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final commandData = {
        'id': const Uuid().v4(),
        'device_id': deviceId,
        'parent_user_id': userId,
        'command_type': _commandTypeToString(commandType),
        'parameters': parameters,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now()
            .add(const Duration(minutes: 5))
            .toIso8601String(),
      };

      final result = await _supabaseService.insert('commands', commandData);

      // Log activity
      await _supabaseService.logActivity(
        userId: userId,
        deviceId: deviceId,
        activityType: 'command_sent',
        description: 'Command sent: ${_commandTypeToString(commandType)}',
        metadata: parameters,
      );

      return result['id'] as String;
    } catch (e) {
      throw Exception('Failed to send command: $e');
    }
  }

  // Get command status
  Future<Map<String, dynamic>> getCommandStatus(String commandId) async {
    try {
      final results = await _supabaseService.select(
        'commands',
        filter: 'id=eq.$commandId',
        limit: 1,
      );

      if (results.isEmpty) {
        throw Exception('Command not found');
      }

      return results.first;
    } catch (e) {
      throw Exception('Failed to get command status: $e');
    }
  }

  // Wait for command completion
  Future<Map<String, dynamic>> waitForCommandCompletion(
    String commandId, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      final command = await getCommandStatus(commandId);
      final status = command['status'] as String;

      if (status == 'executed' || status == 'failed') {
        return command;
      }

      await Future.delayed(const Duration(seconds: 1));
    }

    throw Exception('Command timeout');
  }

  // Helper methods
  String _commandTypeToString(CommandType type) {
    switch (type) {
      case CommandType.startVideo:
        return 'start_video';
      case CommandType.stopVideo:
        return 'stop_video';
      case CommandType.switchCamera:
        return 'switch_camera';
      case CommandType.startAudio:
        return 'start_audio';
      case CommandType.stopAudio:
        return 'stop_audio';
      case CommandType.takeSnapshot:
        return 'take_snapshot';
      case CommandType.startRecording:
        return 'start_recording';
      case CommandType.stopRecording:
        return 'stop_recording';
      case CommandType.getLocation:
        return 'get_location';
      case CommandType.getDeviceInfo:
        return 'get_device_info';
    }
  }
}

