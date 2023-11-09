import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/homescreen/settings_page.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';

class EditProfile extends StatefulWidget {
  final String myProfile;

  const EditProfile({super.key, required this.myProfile});
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        color: AppColors.backgroundColorDefault,
        alignment: Alignment.center,
        child: Column(children: <Widget>[
          AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 25,
                color: AppColors.primaryColorOrange,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.myProfile,
              style: GoogleFonts.poppins(
                  fontSize: 25, color: AppColors.textColorPrimary),
            ),
          ),
          verticalSpaceLarge,
          Align(
            child: Container(
              width: 50 * 2,
              height: 50 * 2,
              child: ClipOval(
                child: Image.asset(
                  'assets/hotel_1.png',
                  width: 30 * 2,
                  height: 30 * 2,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          verticalSpaceMedium,
          ProfileTextfield(
              label: 'Name',
              hintText: 'User',
              initialValue: 'User',
              onChanged: (value) {}),
          verticalSpaceRegular,
          ProfileTextfield(
              label: 'Email Address',
              hintText: 'adi@mail.com',
              initialValue: 'User',
              onChanged: (value) {}),
          verticalSpaceRegular,
          ProfileTextfield(
              label: 'Phone Number',
              hintText: '98989888',
              initialValue: 'User',
              onChanged: (value) {}),
          verticalSpaceRegular,
          ProfileTextfield(
              label: 'Address',
              hintText: 'Times Square',
              initialValue: 'User',
              onChanged: (value) {}),
          verticalSpaceRegular,
          Text(
              'This location will enable new section in home for nearby properties',
              style: GoogleFonts.poppins(
                  color: AppColors.textColorPrimary, fontSize: 15)),
          verticalSpaceRegular,
          Container(
              width: MediaQuery.of(context).size.width - 40,
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange),
                  ),
                  onPressed: () {
                    //Update Profile
                  },
                  child: Text(
                    "Update Profile",
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ))
        ]),
      ),
    );
  }
}

class ProfileTextfield extends StatefulWidget {
  final String label;
  final String hintText;
  final String initialValue;
  final Function(String) onChanged;
  ProfileTextfield({
    required this.label,
    required this.hintText,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<ProfileTextfield> createState() => _ProfileTextfieldState();
}

class _ProfileTextfieldState extends State<ProfileTextfield> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                color: AppColors.textColorPrimary,
                fontSize: 15),
          ),
          Material(
            child: TextField(
              enabled: null,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                hintStyle:
                    GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
                hintText: widget.hintText,
              ),
              // initialValue: widget.initialValue,
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// class ProfileTextField extends StatefulWidget {
//   final String label;
//   final String hintText;
//   final String initialValue;
//   final Function(String) onChanged;

//   ProfileTextField({
//     required this.label,
//     required this.hintText,
//     required this.initialValue,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           TextField(
//             decoration: InputDecoration(
//               hintText: hintText,
//             ),
//             initialValue: initialValue,
//             onChanged: onChanged,
//           ),
//         ],
//       ),
//     );
//   }
// }
