import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/editprofile/edit_profile.dart';
import 'package:kadu_booking_app/theme/color.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => EditProfile(myProfile: ' User')),
        );
      },
      leading: Image.asset(
        'assets/hotel_1.png',
        height: 100,
        width: 100,
      ),
      title: Text(
        'User',
        style: GoogleFonts.poppins(
            color: AppColors.textColorPrimary, fontSize: 20),
      ),
      subtitle: Text('user@mail.com'),
      trailing: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
            color: Colors.white60, borderRadius: BorderRadius.circular(5)),
        child: Icon(
          Icons.navigate_next_rounded,
          color: AppColors.primaryColorOrange,
          size: 40,
        ),
      ),
    );
  }
}
