import 'service_locator.dart';
import 'supabase_service.dart';

class LocationService {
  final SupabaseService _supabaseService = getIt<SupabaseService>();

  // Get location history for device
  Future<List<Map<String, dynamic>>> getLocationHistory(
    String deviceId, {
    int limit = 100,
  }) async {
    try {
      return await _supabaseService.select(
        'location_history',
        filter: 'device_id=eq.$deviceId',
        orderBy: 'recorded_at',
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to get location history: $e');
    }
  }

  // Get latest location for device
  Future<Map<String, dynamic>?> getLatestLocation(String deviceId) async {
    try {
      final results = await _supabaseService.select(
        'location_history',
        filter: 'device_id=eq.$deviceId',
        orderBy: 'recorded_at',
        limit: 1,
      );

      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      throw Exception('Failed to get latest location: $e');
    }
  }
}

