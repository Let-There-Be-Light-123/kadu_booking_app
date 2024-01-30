import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/signin/signin.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(250, 250, 250, 250),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => SignInScreen()),
                      );
                    },
                    child: Icon(
                      Icons.arrow_back,
                      size: 32,
                      color: Colors.black54,
                    ),
                  ),
                ),
                verticalSpaceMassive,
                Image.asset(
                  'assets/verification_screen_image.png',
                  // height: 300,
                  width: MediaQuery.of(context).size.width,
                ),
                verticalSpaceLarge,
                Text(
                  textAlign: TextAlign.center,
                  'Thank You for Registering With Us.',
                  style: GoogleFonts.poppins(
                      fontSize: 30, color: AppColors.primaryColorOrange),
                ),
                verticalSpaceRegular,
                Text(
                  textAlign: TextAlign.center,
                  'We have received your application. Our Verification Staff will Contact You Soon.',
                  style: GoogleFonts.poppins(
                      fontSize: 20, color: AppColors.textColorPrimary),
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
                                builder: (context) => SignInScreen()));
                      },
                      color: AppColors.primaryColorOrange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Go Back To Login",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                verticalSpaceMassive
              ],
            ),
          ),
        ));
  }
}
