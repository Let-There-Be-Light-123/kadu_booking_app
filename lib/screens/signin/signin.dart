import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
// import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:kadu_booking_app/providers/login_controller_provider.dart';
import 'package:kadu_booking_app/screens/custombtn/custombtn.dart';
import 'package:kadu_booking_app/screens/home/home.dart';
import 'package:kadu_booking_app/screens/homescreen/main_screen.dart';
import 'package:kadu_booking_app/screens/otp/otp.dart';
import 'package:kadu_booking_app/screens/signup/signup.dart';
import 'package:kadu_booking_app/screens/verification/under_verification.dart';
import 'package:kadu_booking_app/services/camerapermission/camera_permission_handler.dart';
import 'package:kadu_booking_app/services/handle_login.dart';
import 'package:kadu_booking_app/services/phonepermissions/phone_permission_handler.dart';
import 'package:kadu_booking_app/services/resetpassword/reset_password.dart';
import 'package:kadu_booking_app/services/sharedpreferences/remember_me_manager.dart';
import 'package:kadu_booking_app/services/smspermissions/sms_permisssion_handler.dart';
import 'package:kadu_booking_app/services/users.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
// import 'package:rive/rive.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isObsecure = true;
  bool rememberMe = false;
  final PhonePermissionHandler _phonePermissionHandler =
      PhonePermissionHandler();
  final SmsPermissionHandler _smsPermissionHandler = SmsPermissionHandler();

  // Add RememberMeManager instance
  final RememberMeManager _rememberMeManager = RememberMeManager();

  final AuthServices _authServices = AuthServices();

  // ... (existing code)

  void _resetPassword() async {
    try {
      await _authServices.resetPassword(emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset email sent. Check your inbox."),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  validateEmail(value) {
    if (value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  validatePassWord(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter valid Password';
    }
    if (value.length < 8) {
      return 'Minimum 8 characters are required';
    }
    return null;
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  // validateForm(TextEditingController controller) {
  //   if (controller.text == null || controller.text == "") {
  //     return "Please Enter Some Text";
  //   }
  // }

  final _formKey = GlobalKey<FormState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Add phone configuration on android manifest
    // _phonePermissionHandler.checkPhonePermissionOnInit(context);
    _smsPermissionHandler.checkSmsPermissionOnInit(context);

    // Load Remember Me data on init
    _loadRememberMe();
  }

  void _loadRememberMe() async {
    Map<String, dynamic> rememberMeData =
        await RememberMeManager.loadRememberMe();

    setState(() {
      rememberMe = rememberMeData['rememberMe'];
      emailController.text = rememberMeData['email'];
      passwordController.text = rememberMeData['password'];
    });
  }

  void _saveRememberMe() async {
    await RememberMeManager.saveRememberMe(
        rememberMe!, emailController.text, passwordController.text);
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColorDefault,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                verticalSpaceLarge,
                Column(
                  children: <Widget>[
                    Positioned(
                      top: 10,
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          color: AppColors.textColorPrimary,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "By Signing in you are agreeing to our",
                      style:
                          GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Terms and Privacy Policay',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: AppColors.textColorPrimary),
                      ),
                    ),
                  ],
                ),
                Padding(padding: const EdgeInsets.all(8.0)),
                SizedBox(height: height * .05),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: width * .9,
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              hintText: "Email/ Username",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter valid social security number';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        SizedBox(height: height * .02),
                        Container(
                            width: width * .9,
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                hintText: "Password",
                                suffixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter valid social security number';
                                } else {
                                  return null;
                                }
                              },
                            )),
                        SizedBox(height: height * .01),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value!;
                                        print(value);
                                      });
                                    },
                                  ),
                                  const Text(
                                    "Remember me",
                                    style: TextStyle(
                                        color: AppColors.textColorPrimary,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: _resetPassword,
                                child: const Text(
                                  "Forgotten password?",
                                  style: TextStyle(
                                      color: AppColors.textColorPrimary,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: height * .01),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    width: 320,
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height: 45,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          RegisteredUser? currentUser = await handleLogin(
                              emailController.text, passwordController.text);

                          if (currentUser != null) {
                            if (rememberMe) {
                              // Save login information if Remember Me is checked
                              await RememberMeManager.saveRememberMe(
                                rememberMe,
                                emailController.text,
                                passwordController.text,
                              );
                            }
                          }

                          if (currentUser!.is_verified) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => MainScreen()),
                            );
                          } else {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => VerificationScreen()),
                            );
                          }
                        }
                      },
                      color: AppColors.primaryColorOrange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                verticalSpaceRegular,
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  child: CustomBtn(
                    width: width * .9,
                    text: "Create Account",
                    btnColor: AppColors.color,
                    btnTextColor: Colors.black,
                  ),
                ),
                verticalSpaceRegular,
                Container(
                    height: 250,
                    width: width,
                    child:
                        Image.asset('assets/login_image.png', fit: BoxFit.fill))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
