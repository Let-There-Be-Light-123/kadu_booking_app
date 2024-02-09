// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/api/api_repository.dart';
import 'package:kadu_booking_app/models/file_model.dart';
import 'package:kadu_booking_app/models/property_model.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/homescreen/main_screen.dart';
import 'package:kadu_booking_app/screens/signin/signin_verify.dart';
import 'package:kadu_booking_app/screens/terms_and_privacy_policy.dart/terms_and_privacy_policy.dart';
import 'package:kadu_booking_app/screens/verification/under_verification.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/mask_formatter.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  bool isHomeless = true; // Initial state

  TextEditingController emailController = TextEditingController();
  TextEditingController socialSecurityController = TextEditingController();
  TextEditingController passWordController = TextEditingController();
  TextEditingController confirmpassWordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  void _toggleStatus() {
    setState(() {
      isHomeless = !isHomeless;
    });
  }

  Future<void> sendVerificationEmail() async {
    int otp = Random().nextInt(9000) + 1000;
    String otpString = otp.toString();
    final String apiUrl = '${dotenv.env['API_URL']}/api/send-otp-mail';
    final int intSocialSecurity =
        int.tryParse(socialSecurityController.text) ?? 0;
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          'email': emailController.text,
          'token': otpString,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint('Verification OTP sent successfully');
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignInVerify(
              socialSecurityNumber: intSocialSecurity,
              isHomeless: isHomeless,
              fullName: nameController.text,
              password: passWordController.text,
              email: emailController.text,
              otp: otp,
            ),
          ),
        );
      } else {
        debugPrint('Error sending verification OTP: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error: $error');
    }
  }

  registerUser() async {
    debugPrint("Entering the register user function");
    Map<String, dynamic> userData = {
      'social_security': socialSecurityController.text,
      'identifier': emailController.text,
      'name': nameController.text,
      'password': passWordController.text,
      'is_homeless': isHomeless
    };

    try {
      var response = await Network().signUp(userData);
      debugPrint("The response in registeruser is ${response}");
      if (response['message'] == "User registered successfully") {
        Fluttertoast.showToast(
            msg: "Congratulations, your signup is Successful");
        // ignore: use_build_context_synchronously
        _handleSignIn(context);
      } else {
        Fluttertoast.showToast(msg: "Error, your signup was not successful");
      }
    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void _handleSignIn(BuildContext context) async {
    var network = Network();
    var loginData = {
      'identifier': emailController.text,
      'password': passWordController.text,
    };
    debugPrint("Got password");
    var response = await network.authData(loginData, 'login');

    if (response.statusCode == 200) {
      var userDetailsResponse = await network.getData('userDetails');

      if (userDetailsResponse.statusCode == 200) {
        var userDetailsJson = jsonDecode(userDetailsResponse.body);

        var userDetailsProvider = context.read<UserDetailsProvider>();
        List<FileModel>? files = userDetailsProvider.files;

        if (userDetailsJson['files'] != null) {
          files = (userDetailsJson['files'] as List)
              .map((fileItem) => FileModel.fromJson(fileItem))
              .toList();
        }

        var userDetails = UserDetails(
          socialSecurity: userDetailsJson['user']['social_security'],
          name: userDetailsJson['user']['name'],
          email: userDetailsJson['user']['email'],
          phone: userDetailsJson['user']['phone'],
          roleId: userDetailsJson['user']['role_id'],
          isVerified:
              userDetailsJson['user']['is_verified'] == 1 ? true : false,
          isActive: userDetailsJson['user']['is_active'] == 1 ? true : false,
          emailVerifiedAt: userDetailsJson['user']['email_verified_at'],
          address: userDetailsJson['user']['address'],
          createdAt: userDetailsJson['user']['created_at'],
          updatedAt: userDetailsJson['user']['updated_at'],
          files: files,
        );

        userDetailsProvider.setUserDetails(userDetails);
        await network.getAndSendFCMTokenToServer();

        if (userDetails.isVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VerificationScreen()),
          );
        }
      } else {
        print('Failed to fetch user details');
      }
    } else {
      print('Login failed!');
      // Handle the case where login is not successful
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Stack(
          children: <Widget>[
            Material(
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
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
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset('assets/poeple_resized.png'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Form(
                key: _signUpFormKey,
                child: Column(
                  children: [
                    verticalSpaceLarge,
                    Container(
                      child: Text(
                        "Register",
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          color: AppColors.textColorPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Text(
                      "By Signing in you are agreeing to our",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.grey,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsAndPolicy(),
                          ),
                        );
                      },
                      child: Text(
                        'Terms and Privacy Policay',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: AppColors.textColorPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    verticalSpaceRegular,
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              _toggleStatus();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isHomeless
                                  ? AppColors.primaryColorOrange
                                  : Colors.white,
                            ),
                            child: Text(
                              'Homeless',
                              style: GoogleFonts.poppins(
                                color: isHomeless
                                    ? Colors.white
                                    : AppColors.primaryColorOrange,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _toggleStatus();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !isHomeless
                                  ? AppColors.primaryColorOrange
                                  : Colors.white,
                            ),
                            child: Text(
                              'Unemployed',
                              style: GoogleFonts.poppins(
                                color: !isHomeless
                                    ? Colors.white
                                    : AppColors.primaryColorOrange,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    verticalSpaceRegular,
                    TextFormField(
                      maxLength: 11,
                      inputFormatters: [
                        MaskedTextInputFormatter(
                          mask: 'xxx-xx-xxxx',
                          separator: '-',
                        )
                      ],
                      keyboardType: TextInputType.number,
                      controller: socialSecurityController,
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'Social Security Number',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Social Security Number';
                        }
                        return null;
                      },
                    ),
                    verticalSpaceRegular,
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Full Name';
                        }
                        return null;
                      },
                    ),
                    verticalSpaceRegular,
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Email Address';
                        } else if (!RegExp(
                                r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                            .hasMatch(value)) {
                          return 'Please enter a valid Email Address';
                        }
                        return null;
                      },
                    ),
                    verticalSpaceRegular,
                    TextFormField(
                      controller: passWordController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Password',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                    ),
                    verticalSpaceRegular,
                    TextFormField(
                      controller: confirmpassWordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        return null;
                      },
                    ),
                    verticalSpaceRegular,
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColorOrange,
                      ),
                      onPressed: () {
                        if (_signUpFormKey.currentState!.validate()) {
                          // registerUser();
                          sendVerificationEmail();
                        }
                      },
                      child: const Text('Sign Up with Email and password'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
