import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kadu_booking_app/screens/otp/otp.dart';
import 'package:kadu_booking_app/screens/signin/signin.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: MaterialButton(
        minWidth: double.infinity,
        height: 45,
        onPressed: () {
          FirebaseAuth.instance.signOut().then((value) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SignInScreen()));
          });
        },
        child: Text(
          'Logout',
          style: TextStyle(color: const Color.fromARGB(255, 213, 197, 197)),
        ),
      ),
    );
  }
}
