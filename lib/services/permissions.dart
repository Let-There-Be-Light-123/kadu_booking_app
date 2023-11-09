import 'package:permission_handler/permission_handler.dart';

class CameraPermissionHandler {
  // Singleton pattern to have a single instance of the class
  static final CameraPermissionHandler _instance =
      CameraPermissionHandler._internal();

  factory CameraPermissionHandler() {
    return _instance;
  }

  CameraPermissionHandler._internal();

  // Method to request camera permission
  Future<bool> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    return status.isGranted;
  }

  // Method to check if camera permission is granted
  Future<bool> checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    return status.isGranted;
  }
}

class LocationPermissionHandler {
  // Singleton pattern to have a single instance of the class
  static final LocationPermissionHandler _instance =
      LocationPermissionHandler._internal();

  factory LocationPermissionHandler() {
    return _instance;
  }

  LocationPermissionHandler._internal();

  // Method to request location permission
  Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }

  // Method to check if location permission is granted
  Future<bool> checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    return status.isGranted;
  }
}
