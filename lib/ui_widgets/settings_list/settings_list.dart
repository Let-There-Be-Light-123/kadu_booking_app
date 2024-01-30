// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/settings/settings_overlay.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/utility/notifications_data.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class ClickableWidgetList extends StatefulWidget {
  @override
  State<ClickableWidgetList> createState() => _ClickableWidgetListState();
}

class _ClickableWidgetListState extends State<ClickableWidgetList> {
  int notificationCount = 0;

  final List<WidgetItem> items = [
    WidgetItem(
        title: 'Notifications',
        iconName: Icons.notifications_active,
        iconColor: AppColors.primaryColorOrange),
    WidgetItem(
        title: 'Articles', iconName: Icons.article, iconColor: Colors.green),
    WidgetItem(
        title: 'Share This App',
        iconName: Icons.share,
        iconColor: AppColors.primaryColorOrange),
    WidgetItem(
        title: 'Rate Us',
        iconName: Icons.star_rounded,
        iconColor: AppColors.primaryColorOrange),
    WidgetItem(
        phoneNumber: '+1234567890',
        emailAddress: 'contact@example.com',
        address: '123 Main St, City, Country',
        title: 'Contact US',
        iconName: Icons.perm_phone_msg,
        iconColor: AppColors.primaryColorOrange),
    WidgetItem(
        title: 'About Us',
        iconName: Icons.info,
        iconColor: AppColors.primaryColorOrange),
    WidgetItem(
        title: 'Terms & Conditions',
        iconName: Icons.article,
        iconColor: AppColors.primaryColorOrange),
    WidgetItem(
        title: 'Privacy Policy',
        iconName: Icons.shield,
        iconColor: AppColors.primaryColorOrange),
  ];

  @override
  Widget build(BuildContext context) {
    void _launchAboutUsUrl() async {
      const aboutUsUrl = 'https://k-adu.com/kadu1000/#';
      if (await canLaunch(aboutUsUrl)) {
        await launch(aboutUsUrl);
      } else {
        throw 'Could not launch $aboutUsUrl';
      }
    }

    void _launchPhoneDialer(String? phoneNumber) async {
      if (phoneNumber == null || phoneNumber.isEmpty) {
        debugPrint('Phone number is not available.');
        return;
      }
      try {
        await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      } catch (e) {
        debugPrint('Could not launch phone dialer app: $e');
      }
    }

    void _launchEmailApp(String? emailAddress) async {
      try {
        await OpenMailApp.openMailApp();
      } catch (e) {
        debugPrint('$e');
      }
    }

    void _launchMapApp(String? address) async {}

    void _showContactDetailsBottomSheet(BuildContext context, WidgetItem item) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Call Us'),
                subtitle:
                    Text(item.phoneNumber ?? 'Phone number not available'),
                onTap: () {
                  _launchPhoneDialer(item.phoneNumber);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.mail),
                title: Text('Email Us'),
                subtitle: Text(item.emailAddress ?? 'Email not available'),
                onTap: () {
                  _launchEmailApp(item.emailAddress);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('Visit Us'),
                subtitle: Text(item.address ?? 'Address not available'),
                onTap: () {
                  _launchMapApp(item.address);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    double screenHeight = 450;
    return Container(
      height: screenHeight,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Material(
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(
            color: Colors.grey,
            height: 0,
          ),
          itemBuilder: (context, index) {
            return ClickableWidgetItem(
              item: items[index],
              onTap: () {
                switch (items[index].title) {
                  case 'Notifications':
                    if (items[index].title == "Notifications") {
                      debugPrint(
                          'Number of notifications ${NotificationData().getNotificationCount()}');
                      items[index].badgeCount =
                          NotificationData().getNotificationCount();
                    }
                    setState(() {
                      items[index].badgeCount =
                          NotificationData().getNotificationCount();
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsOverlay(
                                settingsTitle: items[index].title)));
                    break;
                  case 'Articles':
                    _launchAboutUsUrl();
                    break;
                  case 'Share This App':
                    String shareContent = 'Check out this amazing app!';
                    Share.share(shareContent);
                    break;
                  case 'Rate Us':
                    break;
                  case 'Contact US':
                    _showContactDetailsBottomSheet(context, items[index]);
                    break;
                  case 'About Us':
                    _launchAboutUsUrl();
                    break;
                  case 'Terms & Conditions':
                    _launchAboutUsUrl();
                    break;
                  case 'Privacy Policy':
                    _launchAboutUsUrl();
                    break;
                  default:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsOverlay(
                                settingsTitle: items[index].title)));
                    break;
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class WidgetItem {
  final String title;
  final IconData iconName;
  final Color iconColor;
  final String? phoneNumber;
  final String? emailAddress;
  final String? address;
  int? badgeCount; // Add this property

  WidgetItem({
    required this.title,
    required this.iconName,
    required this.iconColor,
    this.phoneNumber = '9573546845',
    this.emailAddress = '',
    this.address = '',
    this.badgeCount = 0, // Initialize the badge count to 0
  });
}

class ClickableWidgetItem extends StatefulWidget {
  final WidgetItem item;
  final VoidCallback onTap;

  ClickableWidgetItem({required this.item, required this.onTap});

  @override
  _ClickableWidgetItemState createState() => _ClickableWidgetItemState();
}

class _ClickableWidgetItemState extends State<ClickableWidgetItem> {
  late NotificationData _notificationData;
  late int _badgeCount;

  @override
  void initState() {
    super.initState();
    _notificationData = NotificationData();
    _badgeCount = _notificationData.getNotificationCount();
    _notificationData.notificationCountNotifier
        .addListener(_onNotificationCountChange);
  }

  @override
  void dispose() {
    _notificationData.notificationCountNotifier
        .removeListener(_onNotificationCountChange);
    super.dispose();
  }

  void _onNotificationCountChange() {
    setState(() {
      _badgeCount = _notificationData.getNotificationCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListTile(
          tileColor: Colors.white,
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: AppColors.googleButtonColor,
                borderRadius: BorderRadius.circular(5)),
            child: Icon(
              widget.item.iconName,
              color: widget.item.iconColor,
            ),
          ),
          title: Text(
            widget.item.title,
            style: GoogleFonts.poppins(color: AppColors.textColorPrimary),
          ),
          trailing: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(Icons.navigate_next_rounded),
          ),
          onTap: () {
            widget.onTap();
          },
        ),
        if (widget.item.title == 'Notifications' && widget.item.badgeCount! > 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle, // Make the container circular
              ),
              child: Center(
                // Center the badge text
                child: Text(
                  widget.item.badgeCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
