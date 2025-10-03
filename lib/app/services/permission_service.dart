import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final GetStorage _storage = GetStorage();

  // Check if this is the first time the app is opened
  bool get isFirstTime {
    return _storage.read('permissionsRequested') != true;
  }

  // Mark that permissions have been requested
  void markPermissionsRequested() {
    _storage.write('permissionsRequested', true);
  }

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting camera permission: $e');
      return false;
    }
  }

  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  // Check camera permission status
  Future<bool> isCameraPermissionGranted() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking camera permission: $e');
      return false;
    }
  }

  // Check notification permission status
  Future<bool> isNotificationPermissionGranted() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking notification permission: $e');
      return false;
    }
  }

  // Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting microphone permission: $e');
      return false;
    }
  }

  // Check microphone permission status
  Future<bool> isMicrophonePermissionGranted() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking microphone permission: $e');
      return false;
    }
  }

  // Request all required permissions
  Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    // Request camera permission
    results['camera'] = await requestCameraPermission();

    // Request microphone permission
    results['microphone'] = await requestMicrophonePermission();

    // Request notification permission
    results['notification'] = await requestNotificationPermission();

    // Mark that permissions have been requested
    markPermissionsRequested();

    return results;
  }

  // Check if all required permissions are granted
  Future<bool> areAllPermissionsGranted() async {
    final cameraGranted = await isCameraPermissionGranted();
    final microphoneGranted = await isMicrophonePermissionGranted();
    final notificationGranted = await isNotificationPermissionGranted();

    return cameraGranted && microphoneGranted && notificationGranted;
  }

  // Show permission explanation dialog
  void showPermissionExplanation(String permissionName) {
    Get.dialog(
      AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
          'This app needs $permissionName permission to function properly. '
          'Please grant the permission in the next dialog.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }
}
