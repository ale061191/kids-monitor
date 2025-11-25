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
  getDeviceInfo;

  String get value {
    switch (this) {
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

  static CommandType fromString(String value) {
    switch (value) {
      case 'start_video':
        return CommandType.startVideo;
      case 'stop_video':
        return CommandType.stopVideo;
      case 'switch_camera':
        return CommandType.switchCamera;
      case 'start_audio':
        return CommandType.startAudio;
      case 'stop_audio':
        return CommandType.stopAudio;
      case 'take_snapshot':
        return CommandType.takeSnapshot;
      case 'start_recording':
        return CommandType.startRecording;
      case 'stop_recording':
        return CommandType.stopRecording;
      case 'get_location':
        return CommandType.getLocation;
      case 'get_device_info':
        return CommandType.getDeviceInfo;
      default:
        throw ArgumentError('Unknown command type: $value');
    }
  }
}

enum CommandStatus {
  pending,
  sent,
  executed,
  failed;

  String get value {
    switch (this) {
      case CommandStatus.pending:
        return 'pending';
      case CommandStatus.sent:
        return 'sent';
      case CommandStatus.executed:
        return 'executed';
      case CommandStatus.failed:
        return 'failed';
    }
  }

  static CommandStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return CommandStatus.pending;
      case 'sent':
        return CommandStatus.sent;
      case 'executed':
        return CommandStatus.executed;
      case 'failed':
        return CommandStatus.failed;
      default:
        return CommandStatus.pending;
    }
  }
}

class CommandModel {
  final String id;
  final String deviceId;
  final String parentUserId;
  final CommandType commandType;
  final Map<String, dynamic>? parameters;
  final CommandStatus status;
  final Map<String, dynamic>? response;
  final DateTime createdAt;
  final DateTime? executedAt;
  final DateTime expiresAt;

  CommandModel({
    required this.id,
    required this.deviceId,
    required this.parentUserId,
    required this.commandType,
    this.parameters,
    required this.status,
    this.response,
    required this.createdAt,
    this.executedAt,
    required this.expiresAt,
  });

  factory CommandModel.fromJson(Map<String, dynamic> json) {
    return CommandModel(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      parentUserId: json['parent_user_id'] as String,
      commandType: CommandType.fromString(json['command_type'] as String),
      parameters: json['parameters'] as Map<String, dynamic>?,
      status: CommandStatus.fromString(json['status'] as String),
      response: json['response'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      executedAt: json['executed_at'] != null
          ? DateTime.parse(json['executed_at'] as String)
          : null,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'parent_user_id': parentUserId,
      'command_type': commandType.value,
      'parameters': parameters,
      'status': status.value,
      'response': response,
      'created_at': createdAt.toIso8601String(),
      'executed_at': executedAt?.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  CommandModel copyWith({
    String? id,
    String? deviceId,
    String? parentUserId,
    CommandType? commandType,
    Map<String, dynamic>? parameters,
    CommandStatus? status,
    Map<String, dynamic>? response,
    DateTime? createdAt,
    DateTime? executedAt,
    DateTime? expiresAt,
  }) {
    return CommandModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      parentUserId: parentUserId ?? this.parentUserId,
      commandType: commandType ?? this.commandType,
      parameters: parameters ?? this.parameters,
      status: status ?? this.status,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
      executedAt: executedAt ?? this.executedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == CommandStatus.pending;
  bool get isExecuted => status == CommandStatus.executed;
  bool get isFailed => status == CommandStatus.failed;
}

