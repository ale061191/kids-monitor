import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';

import '../models/location_model.dart';
import 'service_locator.dart';
import 'supabase_service.dart';
import 'device_service.dart';

class LocationService {
  final SupabaseService _supabaseService = getIt<SupabaseService>();
  final DeviceService _deviceService = getIt<DeviceService>();

  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;
  bool _isTracking = false;

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    final permission = await checkPermission();
    
    if (permission == LocationPermission.denied) {
      final newPermission = await requestPermission();
      if (newPermission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      return position;
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  // Start tracking location
  Future<void> startTracking({
    int distanceFilterMeters = 10,
    int intervalSeconds = 300,
  }) async {
    if (_isTracking) {
      return;
    }

    final permission = await checkPermission();
    if (permission == LocationPermission.denied || 
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission not granted');
    }

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilterMeters,
      timeLimit: Duration(seconds: intervalSeconds),
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentPosition = position;
        _saveLocationToDatabase(position);
      },
      onError: (error) {
        print('Location tracking error: $error');
      },
    );

    _isTracking = true;
  }

  // Stop tracking location
  Future<void> stopTracking() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
  }

  // Save location to database
  Future<void> _saveLocationToDatabase(Position position) async {
    final device = _deviceService.currentDevice;
    if (device == null) return;

    try {
      // Optionally get address
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          address = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        }
      } catch (e) {
        // Geocoding failed, continue without address
      }

      final locationData = {
        'id': const Uuid().v4(),
        'device_id': device.id,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'speed': position.speed,
        'heading': position.heading,
        'address': address,
        'recorded_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.insert('location_history', locationData);
    } catch (e) {
      print('Failed to save location: $e');
    }
  }

  // Get location and save immediately
  Future<LocationModel?> getAndSaveLocation() async {
    try {
      final position = await getCurrentLocation();
      await _saveLocationToDatabase(position);

      final device = _deviceService.currentDevice;
      if (device == null) return null;

      // Get address
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          address = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        }
      } catch (e) {
        // Geocoding failed
      }

      return LocationModel(
        id: const Uuid().v4(),
        deviceId: device.id,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        address: address,
        recordedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get and save location: $e');
    }
  }

  // Get distance between two positions
  double getDistanceBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Check if position is within geofence
  bool isWithinGeofence({
    required Position position,
    required double centerLatitude,
    required double centerLongitude,
    required double radiusMeters,
  }) {
    final distance = getDistanceBetween(
      startLatitude: position.latitude,
      startLongitude: position.longitude,
      endLatitude: centerLatitude,
      endLongitude: centerLongitude,
    );

    return distance <= radiusMeters;
  }

  // Get current position
  Position? get currentPosition => _currentPosition;

  // Check if tracking
  bool get isTracking => _isTracking;

  // Get location info
  Map<String, dynamic> getLocationInfo() {
    return {
      'tracking': _isTracking,
      'current_position': _currentPosition != null ? {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'accuracy': _currentPosition!.accuracy,
        'altitude': _currentPosition!.altitude,
        'speed': _currentPosition!.speed,
        'heading': _currentPosition!.heading,
        'timestamp': _currentPosition!.timestamp.toIso8601String(),
      } : null,
    };
  }

  // Dispose
  Future<void> dispose() async {
    await stopTracking();
  }
}

