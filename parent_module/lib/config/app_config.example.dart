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

  // App Info
  static const String appName = 'SafeKids Control';
  static const String appVersion = '1.0.0';

  // Refresh intervals
  static const int deviceStatusRefreshSeconds = 30;
  static const int locationRefreshSeconds = 60;

  // Command timeout
  static const int commandTimeoutSeconds = 30;

  // Media
  static const int maxSnapshotsToShow = 50;
  static const int maxRecordingsToShow = 50;

  // Maps
  static const double defaultMapZoom = 15.0;
  static const double geofenceMinRadius = 50.0; // meters
  static const double geofenceMaxRadius = 5000.0; // meters
}

