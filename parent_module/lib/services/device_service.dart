import '../models/device_link_model.dart';
import 'service_locator.dart';
import 'supabase_service.dart';

class DeviceService {
  final SupabaseService _supabaseService = getIt<SupabaseService>();

  // Get linked devices
  Future<List<DeviceLinkModel>> getLinkedDevices() async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabaseService.client
          .from('device_links')
          .select('''
            *,
            devices:device_id (
              device_name,
              device_model,
              os_version,
              is_online,
              last_seen
            )
          ''')
          .eq('parent_user_id', userId)
          .eq('is_active', true);

      return (response as List).map((json) {
        // Flatten the nested device data
        final deviceData = json['devices'] as Map<String, dynamic>?;
        final flatJson = Map<String, dynamic>.from(json);
        
        if (deviceData != null) {
          flatJson['device_name'] = deviceData['device_name'];
          flatJson['device_model'] = deviceData['device_model'];
          flatJson['os_version'] = deviceData['os_version'];
          flatJson['is_online'] = deviceData['is_online'];
          flatJson['last_seen'] = deviceData['last_seen'];
        }
        
        return DeviceLinkModel.fromJson(flatJson);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get linked devices: $e');
    }
  }

  // Link device by code
  Future<DeviceLinkModel> linkDeviceByCode(String deviceCode) async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Find device by code
      final devices = await _supabaseService.select(
        'devices',
        filter: 'device_code=eq.$deviceCode',
        limit: 1,
      );

      if (devices.isEmpty) {
        throw Exception('Device not found');
      }

      final device = devices.first;

      // Check if already linked
      final existingLinks = await _supabaseService.select(
        'device_links',
        filter: 'device_id=eq.${device['id']}',
      );

      if (existingLinks.any((link) => 
          link['parent_user_id'] == userId && 
          link['is_active'] == true)) {
        throw Exception('Device already linked');
      }

      // Create link
      final linkData = {
        'parent_user_id': userId,
        'device_id': device['id'],
        'is_active': true,
      };

      final link = await _supabaseService.insert('device_links', linkData);

      // Log activity
      await _supabaseService.logActivity(
        userId: userId,
        deviceId: device['id'],
        activityType: 'device_linked',
        description: 'Device linked successfully',
      );

      return DeviceLinkModel.fromJson({
        ...link,
        'device_name': device['device_name'],
        'device_model': device['device_model'],
        'os_version': device['os_version'],
        'is_online': device['is_online'],
        'last_seen': device['last_seen'],
      });
    } catch (e) {
      throw Exception('Failed to link device: $e');
    }
  }

  // Unlink device
  Future<void> unlinkDevice(String linkId) async {
    try {
      await _supabaseService.update(
        'device_links',
        linkId,
        {'is_active': false},
      );

      // Log activity
      final userId = _supabaseService.currentUser?.id;
      if (userId != null) {
        await _supabaseService.logActivity(
          userId: userId,
          activityType: 'device_unlinked',
          description: 'Device unlinked',
        );
      }
    } catch (e) {
      throw Exception('Failed to unlink device: $e');
    }
  }

  // Update device nickname
  Future<void> updateDeviceNickname(String linkId, String nickname) async {
    try {
      await _supabaseService.update(
        'device_links',
        linkId,
        {'nickname': nickname},
      );
    } catch (e) {
      throw Exception('Failed to update nickname: $e');
    }
  }
}

