import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/signin/signin.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/ui_widgets/profile/profile.dart';
import 'package:kadu_booking_app/ui_widgets/settings_list/settings_list.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';

class SettingsPage extends StatelessWidget {
  final String tab;

  const SettingsPage({super.key, required this.tab});

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
            verticalSpaceLarge,
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
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        // Navigate to the login screen if sign-out is successful
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInScreen()),
                        );
                      } catch (e) {
                        // If there's an error during sign-out, show a SnackBar with the error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error signing out: $e"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
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
                ))
          ],
        ),
      )),
    );
  }
}
