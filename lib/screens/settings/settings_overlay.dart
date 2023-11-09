import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/homescreen/settings_page.dart';
import 'package:kadu_booking_app/theme/color.dart';

class SettingsOverlay extends StatefulWidget {
  final String settingsTitle;
  const SettingsOverlay({super.key, required this.settingsTitle});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: AppColors.backgroundColorDefault,
          child: Column(children: <Widget>[
            AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 25,
                  color: AppColors.primaryColorOrange,
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(tab: 'settings')),
                  );
                },
              ),
              title: Text(
                widget.settingsTitle,
                style: GoogleFonts.poppins(
                    fontSize: 25, color: AppColors.textColorPrimary),
              ),
            )
          ]),
        ));
  }
}
