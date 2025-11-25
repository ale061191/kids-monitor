import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'supabase_service.dart';
import 'device_service.dart';
import 'permission_service.dart';
import 'camera_service.dart';
import 'audio_service.dart';
import 'location_service.dart';
import 'command_service.dart';
import 'webrtc_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Core Services
  getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // Device Services
  getIt.registerLazySingleton<DeviceService>(() => DeviceService());
  getIt.registerLazySingleton<PermissionService>(() => PermissionService());

  // Media Services
  getIt.registerLazySingleton<CameraService>(() => CameraService());
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  getIt.registerLazySingleton<LocationService>(() => LocationService());

  // Communication Services
  getIt.registerLazySingleton<WebRTCService>(() => WebRTCService());
  getIt.registerLazySingleton<CommandService>(() => CommandService());

  // Initialize services that need initialization
  await getIt<NotificationService>().initialize();
  await getIt<DeviceService>().initialize();
}

