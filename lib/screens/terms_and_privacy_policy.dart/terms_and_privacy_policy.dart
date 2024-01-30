import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/theme/color.dart';

class TermsAndPolicy extends StatefulWidget {
  const TermsAndPolicy({super.key});

  @override
  State<TermsAndPolicy> createState() => _TermsAndPolicyState();
}

class _TermsAndPolicyState extends State<TermsAndPolicy> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColorDefault,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(top: 15),
            child: Material(
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Center(
            child: Text(
              'The terms and conditions are as follows!!',
              style: GoogleFonts.poppins(
                  color: AppColors.textColorPrimary,
                  fontSize: 15,
                  decoration: TextDecoration.none),
            ),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            textColor: AppColors.textColorSecondary,
            child: Text('Go Back'),
          )
        ],
      ),
    );
  }
}
