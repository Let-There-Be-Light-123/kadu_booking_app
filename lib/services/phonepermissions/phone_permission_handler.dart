import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PhonePermissionService {
  Future<bool> checkPhonePermission() async {
    PermissionStatus status = await Permission.phone.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> requestPhonePermission() async {
    PermissionStatus status = await Permission.phone.request();
    return status == PermissionStatus.granted;
  }
}

class PhonePermissionHandler {
  final PhonePermissionService _phonePermissionService =
      PhonePermissionService();

  Future<void> checkPhonePermissionOnInit(BuildContext context) async {
    bool hasPhonePermission =
        await _phonePermissionService.checkPhonePermission();
    if (!hasPhonePermission) {
      // Display a dialog to request phone permission
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Phone Permission'),
            content: Text(
                'This app needs access to your phone. Would you like to grant permission?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Deny'),
              ),
              TextButton(
                onPressed: () async {
                  // Request phone permission
                  bool granted =
                      await _phonePermissionService.requestPhonePermission();
                  if (granted) {
                    Navigator.of(context).pop(); // Close the dialog
                    // Perform actions that require phone permission
                    print("Phone permission granted!");
                  } else {
                    // Handle the case where permission is still not granted
                    print("Phone permission denied!");
                  }
                },
                child: Text('Allow'),
              ),
            ],
          );
        },
      );
    }
  }
}
