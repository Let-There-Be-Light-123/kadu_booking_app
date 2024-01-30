import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/signin/signin.dart';
import 'package:kadu_booking_app/screens/signup/sign_up.dart';
import 'package:kadu_booking_app/screens/signup/signup_with_phone.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpOptions extends StatefulWidget {
  const SignUpOptions({super.key});

  @override
  State<SignUpOptions> createState() => _SignUpOptionsState();
}

class _SignUpOptionsState extends State<SignUpOptions> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColorDefault,
      child: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          verticalSpaceRegular,
          Align(
            alignment: Alignment.topLeft,
            child: Material(
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                  size: 25,
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignInScreen()));
                },
              ),
            ),
          ),
          verticalSpaceSmall,
          verticalSpaceLarge,
          Text(
            'Choose Signup Options',
            style: GoogleFonts.poppins(
                fontSize: 30,
                color: AppColors.textColorPrimary,
                decoration: TextDecoration.none),
          ),
          verticalSpaceMedium,
          Container(
            // width: MediaQuery.of(context).size.width + 40,
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/signup-options.png'),
          ),
          verticalSpaceLarge,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              width: 320,
              child: MaterialButton(
                minWidth: double.infinity,
                height: 45,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignUpWithPhone()));
                },
                color: AppColors.primaryColorOrange,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "Signup with phone",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          verticalSpaceRegular,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              width: 320,
              child: MaterialButton(
                minWidth: double.infinity,
                height: 45,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()));
                },
                color: AppColors.primaryColorOrange,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "Signup with Email and Password",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          verticalSpaceMedium,
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                launch('https://k-adu.com/');
              },
              child: Text.rich(
                TextSpan(
                  text:
                      'By Signing up you are agreeing to our terms and conditions.',
                  style: GoogleFonts.poppins(
                    color: AppColors.textColorPrimary,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
          verticalSpaceMassive,
        ],
      )),
    );
  }
}
