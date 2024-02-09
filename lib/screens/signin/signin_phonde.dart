import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class SignInWithPhone extends StatefulWidget {
  const SignInWithPhone({Key? key}) : super(key: key);
  static String verify = '';

  @override
  State<SignInWithPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<SignInWithPhone> {
  TextEditingController countryController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController(); // New

  final GlobalKey<FormState> _phoneSignupKey = GlobalKey<FormState>();

  @override
  void initState() {
    countryController.text = "+1";
    super.initState();
  }

  void _handleSignIn(BuildContext context) async {
    var network = Network();
    var loginData = {
      'identifier': phoneController.text,
      'password': passwordController.text,
    };
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
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful'),
            duration: Duration(seconds: 2),
          ),
        );
        await network.getAndSendFCMTokenToServer();

        if (userDetails.isVerified) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VerificationScreen()),
          );
        }
      } else {
        // show toast or handle the case where fetching user details is not successful
        print('Failed to fetch user details');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed! Please check your credentials.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Stack(
          children: [
            Column(children: [
              Form(
                key: _phoneSignupKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    verticalSpaceRegular,
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.grey,
                          size: 25,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    verticalSpaceRegular,
                    Text(
                      "Phone Login",
                      style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary),
                    ),
                    verticalSpaceRegular,
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TermsAndPolicy()));
                      },
                      child: Text(
                        "Please read the terms and privacy policy",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: AppColors.textColorSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    verticalSpaceMassive,
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: countryController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const Text(
                            "|",
                            style: TextStyle(fontSize: 33, color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: phoneController,
                              maxLength: 12,
                              inputFormatters: [
                                MaskedTextInputFormatter(
                                  mask: 'xxx-xxx-xxxx',
                                  separator: '-',
                                )
                              ],
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                hintText: "Phone",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpaceRegular,
                    Material(
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true, // Password field
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                      ),
                    ),
                    verticalSpaceRegular,
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColorOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          if (_phoneSignupKey.currentState!.validate()) {
                            String concatenatedNumber =
                                '${countryController.text}${phoneController.text}';
                            int phoneNumber = 0;
                            _handleSignIn(context);
                            try {
                              phoneNumber = int.parse(concatenatedNumber);
                            } catch (e) {
                              print('Error converting to int: $e');
                            }
                          }
                        },
                        child: const Text("Login"),
                      ),
                    ),
                    verticalSpaceMedium,
                  ],
                ),
              ),
            ]),
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset('assets/poeple_resized.png'),
            ),
          ],
        ),
      ),
    );
  }
}
