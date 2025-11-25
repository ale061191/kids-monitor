class LocationModel {
  final String id;
  final String deviceId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final String? address;
  final DateTime recordedAt;

  LocationModel({
    required this.id,
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    this.address,
    required this.recordedAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: json['accuracy'] != null 
          ? (json['accuracy'] as num).toDouble() 
          : null,
      altitude: json['altitude'] != null 
          ? (json['altitude'] as num).toDouble() 
          : null,
      speed: json['speed'] != null 
          ? (json['speed'] as num).toDouble() 
          : null,
      heading: json['heading'] != null 
          ? (json['heading'] as num).toDouble() 
          : null,
      address: json['address'] as String?,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'address': address,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  LocationModel copyWith({
    String? id,
    String? deviceId,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
    DateTime? recordedAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      address: address ?? this.address,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  String toString() {
    return 'LocationModel(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
  }
}

