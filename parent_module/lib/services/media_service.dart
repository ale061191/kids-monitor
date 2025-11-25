import 'service_locator.dart';
import 'supabase_service.dart';

class MediaService {
  final SupabaseService _supabaseService = getIt<SupabaseService>();

  // Get snapshots for device
  Future<List<Map<String, dynamic>>> getSnapshots(String deviceId) async {
    try {
      return await _supabaseService.select(
        'media_files',
        filter: 'device_id=eq.$deviceId',
        orderBy: 'created_at',
      );
    } catch (e) {
      throw Exception('Failed to get snapshots: $e');
    }
  }

  // Get recordings for device
  Future<List<Map<String, dynamic>>> getRecordings(String deviceId) async {
    try {
      return await _supabaseService.select(
        'media_files',
        filter: 'device_id=eq.$deviceId',
        orderBy: 'created_at',
      );
    } catch (e) {
      throw Exception('Failed to get recordings: $e');
    }
  }

  // Delete media file
  Future<void> deleteMediaFile(String fileId, String filePath) async {
    try {
      await _supabaseService.delete('media_files', fileId);
      
      // Determine bucket based on file path
      String bucket = 'snapshots';
      if (filePath.contains('recording')) {
        bucket = 'audio-recordings';
      }
      
      await _supabaseService.deleteFile(bucket, filePath);
    } catch (e) {
      throw Exception('Failed to delete media file: $e');
    }
  }
}

