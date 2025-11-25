import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/service_locator.dart';
import '../services/permission_service.dart';

class PermissionProvider with ChangeNotifier {
  final PermissionService _permissionService = getIt<PermissionService>();

  Map<Permission, PermissionStatus> _permissions = {};
  bool _isLoading = false;
  String? _error;

  Map<Permission, PermissionStatus> get permissions => _permissions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAllPermissions => _permissions.values.every((status) => status.isGranted);

  // Check all permissions
  Future<void> checkPermissions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _permissions = await _permissionService.requestAllPermissions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request all permissions
  Future<void> requestAllPermissions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _permissions = await _permissionService.requestAllPermissions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request individual permission
  Future<void> requestPermission(Permission permission) async {
    try {
      PermissionStatus status;
      
      switch (permission) {
        case Permission.camera:
          status = await _permissionService.requestCameraPermission();
          break;
        case Permission.microphone:
          status = await _permissionService.requestMicrophonePermission();
          break;
        case Permission.location:
          status = await _permissionService.requestLocationPermission();
          break;
        case Permission.locationAlways:
          status = await _permissionService.requestLocationAlwaysPermission();
          break;
        case Permission.notification:
          status = await _permissionService.requestNotificationPermission();
          break;
        case Permission.storage:
          status = await _permissionService.requestStoragePermission();
          break;
        case Permission.systemAlertWindow:
          status = await _permissionService.requestSystemAlertWindowPermission();
          break;
        default:
          status = await permission.request();
      }

      _permissions[permission] = status;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    try {
      await _permissionService.openAppSettings();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Get permission name
  String getPermissionName(Permission permission) {
    return _permissionService.getPermissionName(permission);
  }

  // Get permission description
  String getPermissionDescription(Permission permission) {
    return _permissionService.getPermissionDescription(permission);
  }

  // Check if any permission is permanently denied
  bool get hasAnyPermanentlyDenied {
    return _permissions.values.any((status) => status.isPermanentlyDenied);
  }

  // Get denied permissions
  List<Permission> get deniedPermissions {
    return _permissions.entries
        .where((entry) => !entry.value.isGranted)
        .map((entry) => entry.key)
        .toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

