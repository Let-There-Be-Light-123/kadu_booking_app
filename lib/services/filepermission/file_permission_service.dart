import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class FilesPermissionService {
  Future<bool> checkFilesPermission() async {
    PermissionStatus readStatus = await Permission.storage.request();
    PermissionStatus writeStatus =
        await Permission.manageExternalStorage.request();

    return readStatus == PermissionStatus.granted &&
        writeStatus == PermissionStatus.granted;
  }

  Future<bool> requestFilesPermission() async {
    PermissionStatus readStatus = await Permission.storage.request();
    PermissionStatus writeStatus =
        await Permission.manageExternalStorage.request();

    return readStatus == PermissionStatus.granted &&
        writeStatus == PermissionStatus.granted;
  }
}

class FilesPermissionHandler {
  final FilesPermissionService _filesPermissionService =
      FilesPermissionService();

  Future<void> checkFilesPermissionOnInit(BuildContext context) async {
    bool hasFilesPermission =
        await _filesPermissionService.checkFilesPermission();
    if (!hasFilesPermission) {
      // Display a dialog to request files permission
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Files Permission'),
            content: const Text(
                'This app needs access to read and write files. Would you like to grant permission?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Deny'),
              ),
              TextButton(
                onPressed: () async {
                  // Request files permission
                  bool granted =
                      await _filesPermissionService.requestFilesPermission();
                  if (granted) {
                    Navigator.of(context).pop(); // Close the dialog
                    // Perform actions that require files permission
                    if (kDebugMode) {
                      print("Files permission granted!");
                    }
                  } else {
                    // Handle the case where permission is still not granted
                    if (kDebugMode) {
                      print("Files permission denied!");
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
