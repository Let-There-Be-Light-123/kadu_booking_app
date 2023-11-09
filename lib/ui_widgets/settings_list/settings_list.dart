import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/settings/settings_overlay.dart';
import 'package:kadu_booking_app/theme/color.dart';

class ClickableWidgetList extends StatelessWidget {
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
    double screenHeight = 450;
    return Container(
      height: screenHeight,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Material(
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey,
            height: 0,
          ),
          itemBuilder: (context, index) {
            return ClickableWidgetItem(
              item: items[index],
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) =>
                          SettingsOverlay(settingsTitle: items[index].title)),
                );
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

  WidgetItem(
      {required this.title, required this.iconName, required this.iconColor});
}

class ClickableWidgetItem extends StatelessWidget {
  final WidgetItem item;
  final VoidCallback onTap;

  ClickableWidgetItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      leading: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
            color: AppColors.googleButtonColor,
            borderRadius: BorderRadius.circular(5)),
        child: Icon(
          item.iconName,
          color: item.iconColor,
        ),
      ),
      title: Text(item.title,
          style: GoogleFonts.poppins(color: AppColors.textColorPrimary)),
      trailing: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
            color: Colors.white60, borderRadius: BorderRadius.circular(5)),
        child: Icon(Icons.navigate_next_rounded),
      ),
      onTap: onTap,
    );
  }
}
