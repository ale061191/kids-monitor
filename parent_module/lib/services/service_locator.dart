import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'supabase_service.dart';
import 'device_service.dart';
import 'command_service.dart';
import 'webrtc_service.dart';
import 'media_service.dart';
import 'location_service.dart';
import 'geofence_service.dart';
import 'storage_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Core Services
  getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());
  getIt.registerLazySingleton<StorageService>(() => StorageService());

  // Device Services
  getIt.registerLazySingleton<DeviceService>(() => DeviceService());
  getIt.registerLazySingleton<CommandService>(() => CommandService());

  // Media Services
  getIt.registerLazySingleton<WebRTCService>(() => WebRTCService());
  getIt.registerLazySingleton<MediaService>(() => MediaService());

  // Location Services
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  getIt.registerLazySingleton<GeofenceService>(() => GeofenceService());
}

