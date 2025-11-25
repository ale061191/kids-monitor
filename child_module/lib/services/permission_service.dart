import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Check if all required permissions are granted
  Future<bool> hasAllPermissions() async {
    final permissions = await _getPermissionStatuses();
    return permissions.values.every((status) => status.isGranted);
  }

  // Get status of all required permissions
  Future<Map<Permission, PermissionStatus>> _getPermissionStatuses() async {
    return await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
      Permission.locationAlways,
      Permission.notification,
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.systemAlertWindow,
    ].request();
  }

  // Request all required permissions
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    return await _getPermissionStatuses();
  }

  // Individual permission checks
  Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  Future<bool> hasLocationAlwaysPermission() async {
    return await Permission.locationAlways.isGranted;
  }

  Future<bool> hasNotificationPermission() async {
    return await Permission.notification.isGranted;
  }

  Future<bool> hasStoragePermission() async {
    return await Permission.storage.isGranted;
  }

  Future<bool> hasSystemAlertWindowPermission() async {
    return await Permission.systemAlertWindow.isGranted;
  }

  // Individual permission requests
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  Future<PermissionStatus> requestMicrophonePermission() async {
    return await Permission.microphone.request();
  }

  Future<PermissionStatus> requestLocationPermission() async {
    return await Permission.location.request();
  }

  Future<PermissionStatus> requestLocationAlwaysPermission() async {
    return await Permission.locationAlways.request();
  }

  Future<PermissionStatus> requestNotificationPermission() async {
    return await Permission.notification.request();
  }

  Future<PermissionStatus> requestStoragePermission() async {
    return await Permission.storage.request();
  }

  Future<PermissionStatus> requestSystemAlertWindowPermission() async {
    return await Permission.systemAlertWindow.request();
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  // Get permission status details
  Future<Map<String, dynamic>> getPermissionDetails() async {
    final camera = await Permission.camera.status;
    final microphone = await Permission.microphone.status;
    final location = await Permission.location.status;
    final locationAlways = await Permission.locationAlways.status;
    final notification = await Permission.notification.status;
    final storage = await Permission.storage.status;
    final systemAlertWindow = await Permission.systemAlertWindow.status;

    return {
      'camera': {
        'granted': camera.isGranted,
        'denied': camera.isDenied,
        'permanentlyDenied': camera.isPermanentlyDenied,
        'restricted': camera.isRestricted,
      },
      'microphone': {
        'granted': microphone.isGranted,
        'denied': microphone.isDenied,
        'permanentlyDenied': microphone.isPermanentlyDenied,
        'restricted': microphone.isRestricted,
      },
      'location': {
        'granted': location.isGranted,
        'denied': location.isDenied,
        'permanentlyDenied': location.isPermanentlyDenied,
        'restricted': location.isRestricted,
      },
      'locationAlways': {
        'granted': locationAlways.isGranted,
        'denied': locationAlways.isDenied,
        'permanentlyDenied': locationAlways.isPermanentlyDenied,
        'restricted': locationAlways.isRestricted,
      },
      'notification': {
        'granted': notification.isGranted,
        'denied': notification.isDenied,
        'permanentlyDenied': notification.isPermanentlyDenied,
        'restricted': notification.isRestricted,
      },
      'storage': {
        'granted': storage.isGranted,
        'denied': storage.isDenied,
        'permanentlyDenied': storage.isPermanentlyDenied,
        'restricted': storage.isRestricted,
      },
      'systemAlertWindow': {
        'granted': systemAlertWindow.isGranted,
        'denied': systemAlertWindow.isDenied,
        'permanentlyDenied': systemAlertWindow.isPermanentlyDenied,
        'restricted': systemAlertWindow.isRestricted,
      },
    };
  }

  // Check if any permission is permanently denied
  Future<bool> hasAnyPermanentlyDenied() async {
    final permissions = await _getPermissionStatuses();
    return permissions.values.any((status) => status.isPermanentlyDenied);
  }

  // Get list of denied permissions
  Future<List<Permission>> getDeniedPermissions() async {
    final permissions = await _getPermissionStatuses();
    return permissions.entries
        .where((entry) => !entry.value.isGranted)
        .map((entry) => entry.key)
        .toList();
  }

  // Get human-readable permission names
  String getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Cámara';
      case Permission.microphone:
        return 'Micrófono';
      case Permission.location:
        return 'Ubicación';
      case Permission.locationAlways:
        return 'Ubicación siempre';
      case Permission.notification:
        return 'Notificaciones';
      case Permission.storage:
        return 'Almacenamiento';
      case Permission.systemAlertWindow:
        return 'Ventana superpuesta';
      default:
        return permission.toString();
    }
  }

  // Get permission descriptions
  String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Necesario para videovigilancia remota';
      case Permission.microphone:
        return 'Necesario para audio ambiente remoto';
      case Permission.location:
        return 'Necesario para seguimiento de ubicación';
      case Permission.locationAlways:
        return 'Necesario para seguimiento continuo de ubicación';
      case Permission.notification:
        return 'Necesario para alertas y notificaciones';
      case Permission.storage:
        return 'Necesario para guardar capturas y grabaciones';
      case Permission.systemAlertWindow:
        return 'Necesario para funcionar en segundo plano';
      default:
        return 'Permiso necesario para el funcionamiento de la aplicación';
    }
  }
}

