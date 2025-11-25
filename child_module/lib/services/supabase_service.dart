import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  // Auth
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Realtime subscriptions
  RealtimeChannel subscribeToCommands({
    required String deviceId,
    required void Function(Map<String, dynamic>) onCommand,
  }) {
    return _client
        .channel('commands:$deviceId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'commands',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'device_id',
            value: deviceId,
          ),
          callback: (payload) {
            onCommand(payload.newRecord);
          },
        )
        .subscribe();
  }

  RealtimeChannel subscribeToWebRTCSignaling({
    required String deviceId,
    required void Function(Map<String, dynamic>) onSignal,
  }) {
    return _client
        .channel('webrtc:$deviceId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'webrtc_sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'device_id',
            value: deviceId,
          ),
          callback: (payload) {
            onSignal(payload.newRecord);
          },
        )
        .subscribe();
  }

  // Database operations
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String? filter,
    int? limit,
  }) async {
    var query = _client.from(table).select();
    
    if (filter != null) {
      // Parse and apply filter
      // Example: "device_id=eq.123"
      final parts = filter.split('=');
      if (parts.length == 2) {
        final column = parts[0];
        final valueParts = parts[1].split('.');
        if (valueParts.length == 2) {
          final operator = valueParts[0];
          final value = valueParts[1];
          
          switch (operator) {
            case 'eq':
              query = query.eq(column, value) as dynamic;
              break;
            case 'neq':
              query = query.neq(column, value) as dynamic;
              break;
            case 'gt':
              query = query.gt(column, value) as dynamic;
              break;
            case 'lt':
              query = query.lt(column, value) as dynamic;
              break;
          }
        }
      }
    }
    
    if (limit != null) {
      query = query.limit(limit) as dynamic;
    }
    
    return await query;
  }

  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.from(table).insert(data).select().single();
    return response;
  }

  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> delete(String table, String id) async {
    await _client.from(table).delete().eq('id', id);
  }

  // Storage operations
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> fileBytes,
    String? contentType,
  }) async {
    await _client.storage.from(bucket).uploadBinary(
          path,
          Uint8List.fromList(fileBytes),
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteFile(String bucket, String path) async {
    await _client.storage.from(bucket).remove([path]);
  }

  // Activity logging
  Future<void> logActivity({
    required String userId,
    String? deviceId,
    required String activityType,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    await insert('activity_log', {
      'user_id': userId,
      'device_id': deviceId,
      'activity_type': activityType,
      'description': description,
      'metadata': metadata,
    });
  }
}

