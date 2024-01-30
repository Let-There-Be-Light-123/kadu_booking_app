// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kadu_booking_app/api/api_repository.dart';
import 'package:kadu_booking_app/api/property_service.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/homescreen/bookings_page.dart';
import 'package:kadu_booking_app/screens/homescreen/favorites.dart';
import 'package:kadu_booking_app/screens/homescreen/home_page.dart';
import 'package:kadu_booking_app/screens/homescreen/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:kadu_booking_app/screens/homescreen/nav_model.dart';
import 'package:kadu_booking_app/screens/homescreen/settings_page.dart';
import 'package:kadu_booking_app/screens/signin/signin.dart';
import 'package:kadu_booking_app/services/checkpermissions.dart';
import 'package:kadu_booking_app/services/filepermission/file_permission_service.dart';
import 'package:kadu_booking_app/services/locationservice/location_permission.dart';
import 'package:kadu_booking_app/services/mediahandler/media_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
  late UserDetailsProvider userDetailsProvider;
  late UserDetails userDetails;
  late List<Property> favProperties;

  final LocationPermissionService _locationPermissionService =
      LocationPermissionService();
  final MediaPermissionHandler _mediaPermissionHandler =
      MediaPermissionHandler();
  PermissionChecker _permissionChecker = PermissionChecker();
  final FilesPermissionHandler filesPermissionHandler =
      FilesPermissionHandler();

  int selectedTab = 0;
  List<NavModel> items = [];

  @override
  void initState() {
    if (kDebugMode) {
      debugPrint('Context on load: $context');
    }

    super.initState();
    checkLocationPermission();
    _checkMediaPermissionOnInit();
    _requestPhonePermissionsOnInit();
    userDetailsProvider =
        Provider.of<UserDetailsProvider>(context, listen: false);
    userDetails = userDetailsProvider.userDetails!;
    fetchUserFavoriteProperties();
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
        page: SettingsPage(
            tab: 'settings',
            logoutCallBack: () async {
              try {
                var network = Network();
                var response = await network.logout();
                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignInScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Error during logout. Please try again."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error signing out: $e"),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }),
        navKey: profileNavKey,
      ),
    ];
  }

  Future<void> fetchUserFavoriteProperties() async {
    final socialSecurity = userDetailsProvider.getSocialSecurity();
    final url =
        '${dotenv.env['API_URL']}/api/user/$socialSecurity/favorite-properties/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData.containsKey('favorite_properties')) {
          final List<String> favoritePropertyIds =
              jsonData['favorite_properties']
                  .map<String>(
                      (propertyData) => propertyData['property_id'].toString())
                  .toList();

          userDetailsProvider.updateFavoritePropertyIds(favoritePropertyIds);
          favProperties = await userDetailsProvider.getFavoriteProperties();
        } else {
          debugPrint('Response does not contain "favorite_properties"');
          favProperties = [];
        }
      } else {
        debugPrint(
            'Failed to fetch user favorite properties. Status code: ${response.statusCode}');
        favProperties = [];
        userDetailsProvider.updateFavoritePropertyIds([]);
      }
    } catch (e) {
      // debugPrint('Error fetching user favorite properties: $e');
      favProperties = [];
      userDetailsProvider.updateFavoritePropertyIds([]);
    }
  }

  Future<void> _checkPermissionsOnInit() async {
    await _permissionChecker.checkAndPrintPermissions();
  }

  Future<void> _checkMediaPermissionOnInit() async {
    await _mediaPermissionHandler.checkMediaPermissionOnInit(context);
  }

  Future<void> _requestPhonePermissionsOnInit() async {
    await Permission.phone.request();
  }

  Future<void> _checkFilesPermissionOnInit() async {
    await filesPermissionHandler.checkFilesPermissionOnInit(context);
  }

  Future<void> clearAllPermissions() async {
    for (Permission permission in Permission.values) {
      debugPrint("clearing permissions");
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
                    debugPrint("Location permission granted!");
                  } else {
                    debugPrint("Location permission denied!");
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
    var name = userDetails?.name ?? 'N/A';
    return WillPopScope(
      onWillPop: () {
        if (items[selectedTab].navKey.currentState?.canPop() ?? false) {
          items[selectedTab].navKey.currentState?.pop();
          return Future.value(false);
        } else {
          SystemNavigator.pop();
          return Future.value(true);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, // Add this line
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
        bottomNavigationBar: Container(
          child: NavBar(
            pageIndex: selectedTab,
            onTap: (index) async {
              if (index == selectedTab) {
                items[index]
                    .navKey
                    ?.currentState
                    ?.popUntil((route) => route.isFirst);
              } else {
                await _handleTabSelection(index);
              }
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          margin: const EdgeInsets.only(top: 80),
          child: HexagonalFab(),
        ),
      ),
    );
  }

  Future<void> _handleTabSelection(int index) async {
    setState(() {
      selectedTab = index;
    });

    if (index == 2) {
      await userDetailsProvider.getFavoriteProperties();
    }
  }
}

class HexagonalFab extends StatelessWidget {
  void _showIconSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: kBottomNavigationBarHeight +
                MediaQuery.of(context).padding.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Container(
              child: Image.asset('assets/coming-soon.gif'),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
        angle: 90 * 3.14159265359 / 180,
        child: ClipPath(
          clipper: HexagonalClipper(),
          child: FloatingActionButton(
            backgroundColor: Colors.orange,
            elevation: 1,
            onPressed: () {
              debugPrint("Add Button pressed");
              _showIconSelectionSheet(context);
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
