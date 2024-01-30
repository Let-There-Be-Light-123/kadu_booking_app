import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/ui_widgets/profile/profile.dart';
import 'package:kadu_booking_app/ui_widgets/settings_list/settings_list.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback logoutCallBack;
  final String tab;

  SettingsPage({super.key, required this.tab, required this.logoutCallBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
          child: Padding(
        padding: EdgeInsets.only(
          top: 20,
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              title: Text(
                'My Profile',
                style: GoogleFonts.poppins(
                    fontSize: 25, color: AppColors.textColorPrimary),
              ),
            ),
            verticalSpaceRegular,
            ProfileWidget(),
            verticalSpaceRegular,
            ClickableWidgetList(),
            verticalSpaceRegular,
            Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.orange),
                    ),
                    onPressed: logoutCallBack,
                    icon: Icon(
                      Icons.power_settings_new,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Logout",
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )),
            verticalSpaceLarge
          ],
        ),
      )),
    );
  }
}
