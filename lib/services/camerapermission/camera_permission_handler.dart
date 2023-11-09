import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPermissionHandler {
  static final CameraPermissionHandler _instance =
      CameraPermissionHandler._internal();

  factory CameraPermissionHandler() {
    return _instance;
  }

  CameraPermissionHandler._internal();

  Future<bool> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    return status.isGranted;
  }
}

class CameraPermissionService {
  final CameraPermissionHandler _cameraPermissionHandler =
      CameraPermissionHandler();

  Future<bool> checkCameraPermissionOnLoad(BuildContext context) async {
    bool hasCameraPermission =
        await _cameraPermissionHandler.checkCameraPermission();
    if (!hasCameraPermission) {
      // Use a Builder widget to obtain a context that is a descendant of the Scaffold
      print("Check Camera Permission");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Camera Permission'),
            content: Text(
                'This app needs access to your camera. Would you like to grant permission?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(false); // Close the dialog and return false
                },
                child: Text('Deny'),
              ),
              TextButton(
                onPressed: () async {
                  // Request camera permission
                  bool granted =
                      await _cameraPermissionHandler.requestCameraPermission();
                  Navigator.of(context).pop(
                      granted); // Close the dialog and return the permission status
                },
                child: Text('Allow'),
              ),
            ],
          );
        },
      );
    }
    return hasCameraPermission;
  }
}
