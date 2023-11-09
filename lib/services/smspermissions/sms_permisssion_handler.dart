import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsPermissionService {
  Future<bool> checkSmsPermission() async {
    PermissionStatus status = await Permission.sms.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> requestSmsPermission() async {
    PermissionStatus status = await Permission.sms.request();
    return status == PermissionStatus.granted;
  }
}

class SmsPermissionHandler {
  final SmsPermissionService _smsPermissionService = SmsPermissionService();

  Future<void> checkSmsPermissionOnInit(BuildContext context) async {
    bool hasSmsPermission = await _smsPermissionService.checkSmsPermission();
    if (!hasSmsPermission) {
      // Display a dialog to request SMS permission
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('SMS Permission'),
            content: Text(
                'This app needs access to your SMS. Would you like to grant permission?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Deny'),
              ),
              TextButton(
                onPressed: () async {
                  // Request SMS permission
                  bool granted =
                      await _smsPermissionService.requestSmsPermission();
                  if (granted) {
                    Navigator.of(context).pop(); // Close the dialog
                    // Perform actions that require SMS permission
                    print("SMS permission granted!");
                  } else {
                    // Handle the case where permission is still not granted
                    print("SMS permission denied!");
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
