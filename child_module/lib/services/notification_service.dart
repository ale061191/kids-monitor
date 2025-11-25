import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'service_locator.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  final SharedPreferences _prefs = getIt<SharedPreferences>();
  
  static const String _notificationsEnabledKey = 'notifications_enabled';
  bool _isInitialized = false;

  // Initialize notifications
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  // Create notification channel
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      description: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  // Show notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!areNotificationsEnabled()) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Show monitoring notification
  Future<void> showMonitoringNotification({
    required String type,
  }) async {
    String title = '';
    String body = '';

    switch (type) {
      case 'camera':
        title = 'Cámara activada';
        body = 'Tu cámara está siendo monitoreada remotamente';
        break;
      case 'audio':
        title = 'Micrófono activado';
        body = 'Tu micrófono está siendo monitoreado remotamente';
        break;
      case 'location':
        title = 'Ubicación compartida';
        body = 'Tu ubicación está siendo compartida';
        break;
      case 'snapshot':
        title = 'Foto tomada';
        body = 'Se ha tomado una foto remota';
        break;
      case 'recording':
        title = 'Grabación iniciada';
        body = 'Se ha iniciado una grabación remota';
        break;
      default:
        title = 'Monitoreo activo';
        body = 'El dispositivo está siendo monitoreado';
    }

    await showNotification(
      id: type.hashCode,
      title: title,
      body: body,
      payload: type,
    );
  }

  // Show persistent monitoring notification
  Future<void> showPersistentNotification({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(999, title, body, details);
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Check if notifications are enabled
  bool areNotificationsEnabled() {
    return _prefs.getBool(_notificationsEnabledKey) ?? 
           AppConfig.showMonitoringNotificationsByDefault;
  }

  // Enable notifications
  Future<void> enableNotifications() async {
    await _prefs.setBool(_notificationsEnabledKey, true);
  }

  // Disable notifications
  Future<void> disableNotifications() async {
    await _prefs.setBool(_notificationsEnabledKey, false);
    await cancelAllNotifications();
  }

  // Toggle notifications
  Future<void> toggleNotifications() async {
    final enabled = areNotificationsEnabled();
    if (enabled) {
      await disableNotifications();
    } else {
      await enableNotifications();
    }
  }
}

