import 'package:flutter/material.dart';

class Permission {
  final String name;
  const Permission._(this.name);

  static const storage = Permission._('storage');
  static const camera = Permission._('camera');
  static const location = Permission._('location');
  static const notification = Permission._('notification');

  Future<PermissionStatus> request() async {
    return PermissionStatus.denied;
  }

  Future<PermissionStatus> get status async {
    return PermissionStatus.denied;
  }
}

enum PermissionStatus {
  granted,
  denied,
  restricted,
  permanentlyDenied,
  limited,
}

extension PermissionStatusExtension on PermissionStatus {
  bool get isGranted => this == PermissionStatus.granted;
}

extension PermissionListExtensions on List<Permission> {
  Future<Map<Permission, PermissionStatus>> request() async {
    final statuses = <Permission, PermissionStatus>{};
    for (final permission in this) {
      statuses[permission] = await permission.request();
    }
    return statuses;
  }
}

Future<bool> openAppSettings() async => false;

class PermissionUtils {
  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
  
  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  // Request location permission
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }
  
  // Request notification permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
  
  // Check multiple permissions
  static Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }
  
  // Check if all permissions are granted
  static Future<bool> areAllPermissionsGranted(List<Permission> permissions) async {
    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }
  
  // Show permission denied dialog
  static Future<void> showPermissionDeniedDialog(
    BuildContext context,
    String permissionName,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Denied'),
        content: Text(
          'Please enable $permissionName permission in settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}