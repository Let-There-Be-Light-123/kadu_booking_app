import 'package:permission_handler/permission_handler.dart';

class PermissionChecker {
  Future<void> checkAndPrintPermissions() async {
    Map<Permission, PermissionStatus> permissionStatusMap = {};

    for (Permission permission in Permission.values) {
      PermissionStatus status = await permission.status;
      permissionStatusMap[permission] = status;
    }

    print("Permission Status:");
    permissionStatusMap.forEach((permission, status) {
      print('$permission: $status');
    });
  }
}
