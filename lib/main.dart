// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kadu_booking_app/blocs/settings/settings_bloc.dart';
import 'package:kadu_booking_app/screens/editprofile/edit_profile.dart';
// import 'package:kadu_booking_app/blocs/settings/settings_page.dart';
import 'package:kadu_booking_app/screens/homescreen/custom_carousel.dart';
import 'package:kadu_booking_app/screens/homescreen/main_screen.dart';
import 'package:kadu_booking_app/screens/homescreen/settings_page.dart';
import 'package:kadu_booking_app/screens/otp/otp.dart';
import 'package:kadu_booking_app/screens/propertydetails/property_detail_page.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kadu_booking_app/screens/signin/signin.dart';
import 'package:kadu_booking_app/screens/signup/signup.dart';
import 'package:kadu_booking_app/screens/splash/splash.dart';
import 'package:kadu_booking_app/screens/verification/under_verification.dart';
import 'package:kadu_booking_app/ui_widgets/settings_list/settings_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HotelBookingApp());
}

class HotelBookingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
      routes: {
        '/profile': (context) => Otp(),
        '/contactUs': (context) => Otp(),
        '/logout': (context) => Otp(),
        '/shareApp': (context) => Otp(),
        '/rateUs': (context) => Otp(),
      },
    );
  }
}
