import 'package:uuid/uuid.dart';

import 'service_locator.dart';
import 'supabase_service.dart';

class GeofenceService {
  final SupabaseService _supabaseService = getIt<SupabaseService>();

  // Get geofences for device
  Future<List<Map<String, dynamic>>> getGeofences(String deviceId) async {
    try {
      return await _supabaseService.select(
        'geofences',
        filter: 'device_id=eq.$deviceId',
      );
    } catch (e) {
      throw Exception('Failed to get geofences: $e');
    }
  }

  // Create geofence
  Future<Map<String, dynamic>> createGeofence({
    required String deviceId,
    required String name,
    required double latitude,
    required double longitude,
    required double radius,
    bool notifyOnEnter = true,
    bool notifyOnExit = true,
  }) async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final geofenceData = {
        'id': const Uuid().v4(),
        'device_id': deviceId,
        'parent_user_id': userId,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'is_active': true,
        'notify_on_enter': notifyOnEnter,
        'notify_on_exit': notifyOnExit,
      };

      return await _supabaseService.insert('geofences', geofenceData);
    } catch (e) {
      throw Exception('Failed to create geofence: $e');
    }
  }

  // Update geofence
  Future<void> updateGeofence(
    String geofenceId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _supabaseService.update('geofences', geofenceId, updates);
    } catch (e) {
      throw Exception('Failed to update geofence: $e');
    }
  }

  // Delete geofence
  Future<void> deleteGeofence(String geofenceId) async {
    try {
      await _supabaseService.delete('geofences', geofenceId);
    } catch (e) {
      throw Exception('Failed to delete geofence: $e');
    }
  }

  // Get geofence events
  Future<List<Map<String, dynamic>>> getGeofenceEvents(
    String deviceId, {
    int limit = 50,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('geofence_events')
          .select('''
            *,
            geofences:geofence_id (name)
          ''')
          .eq('device_id', deviceId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get geofence events: $e');
    }
  }
}

