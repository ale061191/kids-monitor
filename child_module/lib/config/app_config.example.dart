/// Application configuration TEMPLATE
/// 
/// Copy this file to app_config.dart and fill in your values.
class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL_HERE',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY_HERE',
  );

  // WebRTC Configuration
  static const Map<String, dynamic> iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ],
  };

  // Video Configuration
  static const Map<String, dynamic> videoConstraints = {
    'mandatory': {
      'minWidth': '640',
      'minHeight': '480',
      'minFrameRate': '15',
    },
    'facingMode': 'user',
    'optional': [],
  };

  // Audio Configuration
  static const Map<String, dynamic> audioConstraints = {
    'mandatory': {
      'echoCancellation': true,
      'noiseSuppression': true,
      'autoGainControl': true,
    },
    'optional': [],
  };

  // Location Configuration
  static const int locationUpdateIntervalSeconds = 300; // 5 minutes
  static const double locationAccuracyMeters = 10.0;

  // Background Service Configuration
  static const int backgroundServiceIntervalSeconds = 30;

  // Notification Configuration
  static const String notificationChannelId = 'safekids_monitoring';
  static const String notificationChannelName = 'SafeKids Monitoring';
  static const String notificationChannelDescription = 
      'Notifications for monitoring activities';

  // App Info
  static const String appName = 'SafeKids Monitor';
  static const String appVersion = '1.0.0';

  // Security
  static const int commandTokenExpirationMinutes = 5;
  static const int maxFailedAuthAttempts = 3;

  // Privacy & Ethics
  static const bool showMonitoringNotificationsByDefault = true;
  static const bool requireConsentOnFirstRun = true;
  static const String privacyPolicyUrl = 'https://yourapp.com/privacy';
  static const String termsOfServiceUrl = 'https://yourapp.com/terms';
}

