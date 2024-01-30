import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class MediaPermissionService {
  Future<bool> checkMediaPermission() async {
    PermissionStatus status = await Permission.mediaLibrary.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> requestMediaPermission() async {
    PermissionStatus status = await Permission.mediaLibrary.request();
    return status == PermissionStatus.granted;
  }
}

class MediaPermissionHandler {
  final MediaPermissionService _mediaPermissionService =
      MediaPermissionService();

  Future<void> checkMediaPermissionOnInit(BuildContext context) async {
    bool hasMediaPermission =
        await _mediaPermissionService.checkMediaPermission();
    if (!hasMediaPermission) {
      // Display a dialog to request media permission
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Media Permission'),
            content: const Text(
                'This app needs access to your media. Would you like to grant permission?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Deny'),
              ),
              TextButton(
                onPressed: () async {
                  // Request media permission
                  bool granted =
                      await _mediaPermissionService.requestMediaPermission();
                  if (granted) {
                    Navigator.of(context).pop(); // Close the dialog
                    // Perform actions that require media permission
                    if (kDebugMode) {
                      print("Media permission granted!");
                    }
                  } else {
                    // Handle the case where permission is still not granted
                    if (kDebugMode) {
                      print("Media permission denied!");
                    }
                  }
                },
                child: const Text('Allow'),
              ),
            ],
          );
        },
      );
    }
  }
}
