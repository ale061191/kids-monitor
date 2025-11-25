import 'package:uuid/uuid.dart';

class DeviceModel {
  final String id;
  final String deviceName;
  final String deviceCode;
  final String deviceId;
  final String? childUserId;
  final String? deviceModel;
  final String? osVersion;
  final String? appVersion;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceModel({
    required this.id,
    required this.deviceName,
    required this.deviceCode,
    required this.deviceId,
    this.childUserId,
    this.deviceModel,
    this.osVersion,
    this.appVersion,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      deviceName: json['device_name'] as String,
      deviceCode: json['device_code'] as String,
      deviceId: json['device_id'] as String,
      childUserId: json['child_user_id'] as String?,
      deviceModel: json['device_model'] as String?,
      osVersion: json['os_version'] as String?,
      appVersion: json['app_version'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_name': deviceName,
      'device_code': deviceCode,
      'device_id': deviceId,
      'child_user_id': childUserId,
      'device_model': deviceModel,
      'os_version': osVersion,
      'app_version': appVersion,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DeviceModel copyWith({
    String? id,
    String? deviceName,
    String? deviceCode,
    String? deviceId,
    String? childUserId,
    String? deviceModel,
    String? osVersion,
    String? appVersion,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      deviceCode: deviceCode ?? this.deviceCode,
      deviceId: deviceId ?? this.deviceId,
      childUserId: childUserId ?? this.childUserId,
      deviceModel: deviceModel ?? this.deviceModel,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String generateDeviceId() {
    return const Uuid().v4();
  }
}

