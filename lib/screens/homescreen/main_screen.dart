// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kadu_booking_app/screens/homescreen/bookings_page.dart';
import 'package:kadu_booking_app/screens/homescreen/favorites.dart';
import 'package:kadu_booking_app/screens/homescreen/home_page.dart';
import 'package:kadu_booking_app/screens/homescreen/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:kadu_booking_app/screens/homescreen/nav_model.dart';
import 'package:kadu_booking_app/screens/homescreen/searchpage.dart';
import 'package:kadu_booking_app/screens/homescreen/settings_page.dart';
import 'package:kadu_booking_app/screens/signin/signin.dart';
import 'package:kadu_booking_app/services/checkpermissions.dart';
import 'package:kadu_booking_app/services/locationservice/location_permission.dart';
import 'package:kadu_booking_app/services/mediahandler/media_handler.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final homeNavKey = GlobalKey<NavigatorState>();
  final searchNavKey = GlobalKey<NavigatorState>();
  final notificationNavKey = GlobalKey<NavigatorState>();
  final profileNavKey = GlobalKey<NavigatorState>();
  final LocationPermissionService _locationPermissionService =
      LocationPermissionService();
  final MediaPermissionHandler _mediaPermissionHandler =
      MediaPermissionHandler();
  PermissionChecker _permissionChecker = PermissionChecker();

  int selectedTab = 0;
  List<NavModel> items = [];

  @override
  void initState() {
    super.initState();
    // _checkPermissionsOnInit();
    // clearAllPermissions();
    checkLocationPermission();
    _checkMediaPermissionOnInit();

    items = [
      NavModel(
        page: const HomePage(tab: 'home'),
        navKey: homeNavKey,
      ),
      NavModel(
        page: const BookingsPage(tab: 'bookings'),
        navKey: searchNavKey,
      ),
      NavModel(
        page: const FavouritesPage(tab: 'favourite'),
        navKey: notificationNavKey,
      ),
      NavModel(
        page: const SettingsPage(tab: 'settings'),
        navKey: profileNavKey,
      ),
    ];
  }

  Future<void> _checkPermissionsOnInit() async {
    await _permissionChecker.checkAndPrintPermissions();
  }

  Future<void> _checkMediaPermissionOnInit() async {
    await _mediaPermissionHandler.checkMediaPermissionOnInit(context);
  }

  Future<void> clearAllPermissions() async {
    for (Permission permission in Permission.values) {
      print("clearing permissions");
      await permission.request().then((status) async {
        if (status.isGranted) {
          await permission.request();
        }
      });
    }
  }

  Future<void> checkLocationPermission() async {
    bool hasLocationPermission =
        await _locationPermissionService.checkLocationPermission();
    if (!hasLocationPermission) {
      // Display a dialog to request location permission
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Permission'),
            content: const Text(
                'This app needs access to your location. Would you like to grant permission?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Deny'),
              ),
              TextButton(
                onPressed: () async {
                  // Request location permission
                  bool granted = await _locationPermissionService
                      .requestLocationPermission();
                  if (granted) {
                    Navigator.of(context).pop(); // Close the dialog
                    // Perform actions that require location permission
                    print("Location permission granted!");
                  } else {
                    // Handle the case where permission is still not granted
                    print("Location permission denied!");
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (items[selectedTab].navKey.currentState?.canPop() ?? false) {
          items[selectedTab].navKey.currentState?.pop();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: selectedTab,
          children: items
              .map((page) => Navigator(
                    key: page.navKey,
                    onGenerateInitialRoutes: (navigator, initialRoute) {
                      return [
                        MaterialPageRoute(builder: (context) => page.page)
                      ];
                    },
                  ))
              .toList(),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: HexagonalFab(),
        bottomNavigationBar: NavBar(
          pageIndex: selectedTab,
          onTap: (index) {
            if (index == selectedTab) {
              items[index]
                  .navKey
                  .currentState
                  ?.popUntil((route) => route.isFirst);
            } else {
              setState(() {
                selectedTab = index;
              });
            }
          },
        ),
      ),
    );
  }
}

class HexagonalFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
        angle: 90 * 3.14159265359 / 180,
        child: ClipPath(
          clipper: HexagonalClipper(),
          child: FloatingActionButton(
            backgroundColor: Colors.orange,
            elevation: 0,
            onPressed: () {
              // Handle the button press here
              debugPrint("Add Button pressed");
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ));
  }
}

class HexagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = size.width / 2;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Calculate the points for the hexagon
    for (int i = 0; i < 6; i++) {
      final angle = 2.0 * i * 3.14159265359 / 6;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class VerticalHexagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = size.height / 2;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Calculate the points for the vertical hexagon
    for (int i = 0; i < 6; i++) {
      final angle = 2.0 * i * 3.14159265359 / 6;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
