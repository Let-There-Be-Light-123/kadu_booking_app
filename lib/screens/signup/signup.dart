import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/custombtn/custombtn.dart';
import 'package:kadu_booking_app/screens/otp/otp.dart';
import 'package:kadu_booking_app/screens/signin/signin.dart';
import 'package:kadu_booking_app/screens/verification/under_verification.dart';
import 'package:kadu_booking_app/services/create_user.dart';
import 'package:kadu_booking_app/services/resetpassword/reset_password.dart';
import 'package:kadu_booking_app/services/sharedpreferences/remember_me_manager.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';

String livingConditions = 'Homeless';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  List<bool> selections = [false, true];
  String selectLivingCondition = '';

  final _signUpFormKey = GlobalKey<FormState>();
  bool isObsecure = true;
  bool isHomeless = false;
  bool? checked = false;
  bool rememberMe = false;

  String? password;
  TextEditingController socialController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final RememberMeManager _rememberMeManager = RememberMeManager();
  final AuthServices _authServices = AuthServices();
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a valid email address';
    }
    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a valid phone number';
    }
    if (!RegExp(r'^\+1\d{10}$').hasMatch(value)) {
      return 'Please enter a valid US phone number with country code';
    }

    return null;
  }

  String? validateSSN(String? value) {
    if (value == null || value.toString().length < 9) {
      return 'Please enter a valid social security number';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value!.isEmpty || value == null || value.length < 8) {
      return 'Please Enter valid Password';
    } else if (passwordController.text != confirmPasswordController.text) {
      return "Password isn't same!";
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> signInWithUsernameAndPassword(
        String username, String password) async {
      try {
        String email = '$username@12345adivivekdomain.com';
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        createUserInFirestore(
            livingConditions,
            socialController.text,
            phoneController.text,
            emailController.text,
            passwordController.text);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => VerificationScreen()),
        );
      } catch (e) {
        print('Error: $e');
      }
    }

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.backgroundColorDefault,
      body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
              height: height,
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(children: <Widget>[
                    verticalSpaceLarge,
                    Column(
                      children: <Widget>[
                        Positioned(
                          top: 10,
                          child: Text(
                            "Register",
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
                          style: GoogleFonts.poppins(
                              fontSize: 15, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            // redirect to terms and Conditions
                          },
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
                    verticalSpaceRegular,
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                          key: _signUpFormKey,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    left: 35, right: 35, top: 0, bottom: 10),
                                child: LivingStateSelector(),
                              ),
                              Container(
                                width: width * .9,
                                decoration: BoxDecoration(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: TextFormField(
                                      controller: socialController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 9,
                                      decoration: const InputDecoration(
                                        suffixIcon: Icon(Icons.credit_card),
                                        contentPadding: EdgeInsets.all(10.0),
                                        hintText: "Social Security Number",
                                        border: OutlineInputBorder(),
                                        hintStyle: TextStyle(
                                            color:
                                                AppColors.textColorSecondary),
                                      ),
                                      validator: validateSSN),
                                ),
                              ),
                              Container(
                                width: width * .9,
                                decoration: BoxDecoration(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: TextFormField(
                                      controller: emailController,
                                      decoration: const InputDecoration(
                                        suffixIcon: Icon(Icons.email_outlined),
                                        contentPadding: EdgeInsets.all(10.0),
                                        border: OutlineInputBorder(),
                                        hintText: "Email",
                                        hintStyle: TextStyle(
                                          color: AppColors.textColorSecondary,
                                        ),
                                      ),
                                      validator: validateEmail),
                                ),
                              ),
                              SizedBox(height: height * .02),
                              Container(
                                width: width * .9,
                                decoration: BoxDecoration(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: TextFormField(
                                      controller: phoneController,
                                      decoration: const InputDecoration(
                                        suffixIcon: Icon(Icons.local_phone),
                                        contentPadding: EdgeInsets.all(10.0),
                                        border: OutlineInputBorder(),
                                        hintText: "Phone",
                                        hintStyle: TextStyle(
                                            color: AppColors.textColorSecondary,
                                            fontSize: 15),
                                      ),
                                      validator: validatePhoneNumber),
                                ),
                              ),
                              SizedBox(height: height * .02),
                              Container(
                                width: width * .9,
                                decoration: BoxDecoration(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: TextFormField(
                                    obscureText: isObsecure,
                                    controller: passwordController,
                                    style: const TextStyle(
                                        color: AppColors.textColorPrimary,
                                        fontSize: 15),
                                    validator: validatePassword,
                                    onChanged: (value) {
                                      setState(() {
                                        password = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10.0),
                                      filled: true,
                                      fillColor: Color(0xFFF3F3F3),
                                      border: OutlineInputBorder(),
                                      hintText: "Password",
                                      hintStyle: const TextStyle(
                                          color: AppColors.textColorSecondary,
                                          fontSize: 15),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isObsecure = !isObsecure;
                                          });
                                        },
                                        icon: Icon(
                                          isObsecure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: height * .02),
                              Container(
                                width: width * .9,
                                decoration: BoxDecoration(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: TextFormField(
                                    controller: confirmPasswordController,
                                    obscureText: isObsecure,
                                    style: const TextStyle(
                                        color: AppColors.textColorPrimary,
                                        fontSize: 15),
                                    validator: validatePassword,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10.0),
                                      filled: true,
                                      fillColor: Color(0xFFF3F3F3),
                                      border: OutlineInputBorder(),
                                      hintText: "Confirm Password",
                                      hintStyle: const TextStyle(
                                          color: AppColors.textColorSecondary,
                                          fontSize: 15),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isObsecure = !isObsecure;
                                          });
                                        },
                                        icon: Icon(
                                          isObsecure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: height * .01),
                            ],
                          )),
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
                            if (_signUpFormKey.currentState!.validate()) {
                              signInWithUsernameAndPassword(
                                  socialController.text,
                                  passwordController.text);
                            }
                          },
                          color: AppColors.primaryColorOrange,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "Signup",
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
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => SignInScreen()),
                        );
                      },
                      child: CustomBtn(
                        width: width * .8,
                        text: "Already Have an Account ?",
                        btnColor: AppColors.color,
                        btnTextColor: Colors.black,
                      ),
                    )
                  ])
                ],
              ))),
    );
  }
}

Widget textFieldInput({label, obscureText, fontSize, readOnly}) {
  var icon;
  icon = obscureText ? Icons.lock_outline : Icons.mail;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
        height: 60,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10.0),
            border: OutlineInputBorder(),
            hintText: label,
            hintStyle: GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
            suffixIcon: Icon(icon),
          ),
        ),
      )
    ],
  );
}

class LivingStateSelector extends StatefulWidget {
  @override
  _LivingStateSelectorState createState() => _LivingStateSelectorState();
}

class _LivingStateSelectorState extends State<LivingStateSelector> {
  String selectLivingCondition = 'Homeless';
  //; To store the selected gender

  void selectGender(String conditions) {
    setState(() {
      selectLivingCondition = conditions;
      livingConditions = conditions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        CustomRadioButton(
          label: 'Homeless',
          selected: selectLivingCondition == 'Homeless',
          onSelect: () {
            selectGender('Homeless');
          },
        ),
        CustomRadioButton(
          label: 'Unemployed',
          selected: selectLivingCondition == 'Unemployed',
          onSelect: () {
            selectGender('Unemployed');
          },
        ),
      ],
    );
  }
}

class CustomRadioButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelect;

  CustomRadioButton({
    required this.label,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColorOrange : Colors.white,
          border: Border.all(
            color: Colors.grey,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : AppColors.textColorSecondary,
          ),
        ),
      ),
    );
  }
}
