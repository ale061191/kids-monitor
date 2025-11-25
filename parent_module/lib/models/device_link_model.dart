class DeviceLinkModel {
  final String id;
  final String parentUserId;
  final String deviceId;
  final String? nickname;
  final bool isActive;
  final DateTime linkedAt;
  
  // Device info (from join)
  final String? deviceName;
  final String? deviceModel;
  final String? osVersion;
  final bool? isOnline;
  final DateTime? lastSeen;

  DeviceLinkModel({
    required this.id,
    required this.parentUserId,
    required this.deviceId,
    this.nickname,
    required this.isActive,
    required this.linkedAt,
    this.deviceName,
    this.deviceModel,
    this.osVersion,
    this.isOnline,
    this.lastSeen,
  });

  factory DeviceLinkModel.fromJson(Map<String, dynamic> json) {
    return DeviceLinkModel(
      id: json['id'] as String,
      parentUserId: json['parent_user_id'] as String,
      deviceId: json['device_id'] as String,
      nickname: json['nickname'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      linkedAt: DateTime.parse(json['linked_at'] as String),
      deviceName: json['device_name'] as String?,
      deviceModel: json['device_model'] as String?,
      osVersion: json['os_version'] as String?,
      isOnline: json['is_online'] as bool?,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_user_id': parentUserId,
      'device_id': deviceId,
      'nickname': nickname,
      'is_active': isActive,
      'linked_at': linkedAt.toIso8601String(),
    };
  }

  String get displayName => nickname ?? deviceName ?? 'Dispositivo desconocido';
  
  String get statusText => isOnline == true ? 'En línea' : 'Fuera de línea';
}

