import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'background_service',
    'Background Service',
    description: 'Keeps the app running in background',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'background_service',
      initialNotificationTitle: 'SafeKids Monitor',
      initialNotificationContent: 'Servicio activo',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  } catch (e) {
    // Already initialized
  }

  // Periodic tasks
  Timer.periodic(
    Duration(seconds: AppConfig.backgroundServiceIntervalSeconds),
    (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          // Update device status
          try {
            await _updateDeviceStatus();
          } catch (e) {
            print('Error updating device status: $e');
          }

          // Update notification
          service.setForegroundNotificationInfo(
            title: 'SafeKids Monitor',
            content: 'Activo - ${DateTime.now().toString().substring(11, 19)}',
          );
        }
      }
    },
  );
}

Future<void> _updateDeviceStatus() async {
  try {
    // Get device ID from storage
    // Note: In production, you'd retrieve this from shared preferences
    // For now, we'll skip the actual update to avoid errors
    
    // Update device online status
    // await Supabase.instance.client.from('devices').update({
    //   'is_online': true,
    //   'last_seen': DateTime.now().toIso8601String(),
    // }).eq('device_id', deviceId);
  } catch (e) {
    print('Failed to update device status: $e');
  }
}

