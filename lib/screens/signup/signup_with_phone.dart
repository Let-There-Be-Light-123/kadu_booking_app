import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/api/api_repository.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/homescreen/main_screen.dart';
import 'package:kadu_booking_app/screens/signin/signin_verify.dart';
import 'package:kadu_booking_app/screens/verification/under_verification.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/uihelper/mask_formatter.dart';
import 'package:kadu_booking_app/uihelper/uihelper.dart';
import 'package:provider/provider.dart';

class SignUpWithPhone extends StatefulWidget {
  const SignUpWithPhone({Key? key}) : super(key: key);
  static String verify = '';

  @override
  State<SignUpWithPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<SignUpWithPhone> {
  TextEditingController countryController = TextEditingController();
  TextEditingController socialSecurityController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  var phone = "";

  TextEditingController phoneController = TextEditingController();
  bool isHomeless = true;
  final GlobalKey<FormState> _phoneSignupKey = GlobalKey<FormState>();

  void _toggleStatus() {
    setState(() {
      isHomeless = !isHomeless;
    });
  }

  Future<void> signUpWithPhone() async {
    if (_phoneSignupKey.currentState!.validate()) {
      String phoneNumber = '1' + phoneController.text;
      String socialSecurityNumber = socialSecurityController.text;
      String fullName = fullNameController.text;
      bool isHomeless = this.isHomeless;
      int intPhoneNumber = int.tryParse(phoneNumber) ?? 0;
      int mobile = int.tryParse(phoneController.text) ?? 0;

      int intSocialSecurity = int.tryParse(socialSecurityNumber) ?? 0;
      bool otpSent = await sendOtp(intPhoneNumber);

      if (otpSent) {
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignInVerify(
              mobileNumber: mobile,
              socialSecurityNumber: intSocialSecurity,
              isHomeless: isHomeless,
              fullName: fullNameController.text,
              password: passwordController.text,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send OTP. Please try again.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> sendOtp(int mobileNumber) async {
    final String url =
        'https://control.msg91.com/api/v5/otp?template_id=65760b6fd6fc0526e465d5a1&mobile=$mobileNumber';

    final Map<String, String> headers = {
      'content-type': 'application/json',
      'authkey': '411573AYVkbfHl6575e175P1',
    };
    final Map<String, String> params = {};

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    try {
      debugPrint("Send Otp Function");

      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });
      request.write(json.encode(params));

      HttpClientResponse response = await request.close();

      if (response.statusCode == 200) {
        var responseBody = await utf8.decoder.bind(response).join();
        debugPrint('Request successful');
        debugPrint('Response: ${responseBody}');
        return true;
      } else {
        var responseBody = await utf8.decoder.bind(response).join();
        debugPrint('Error: ${response.statusCode}');
        debugPrint('Response: ${responseBody}');
        return false;
      }
    } catch (error) {
      debugPrint('Error during request: $error');
      return false;
    } finally {
      httpClient.close();
    }
  }

  @override
  void initState() {
    countryController.text = "+1";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Stack(
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset('assets/poeple_resized.png'),
            ),
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
                      "Phone Verification",
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary),
                    ),
                    verticalSpaceLarge,
                    Text(
                      "We need to register your phone without getting started!",
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: AppColors.textColorSecondary),
                      textAlign: TextAlign.center,
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
                                    : Colors.white),
                            child: Text(
                              'Homeless',
                              style: GoogleFonts.poppins(
                                  color: isHomeless
                                      ? Colors.white
                                      : AppColors.primaryColorOrange),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _toggleStatus();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: !isHomeless
                                    ? AppColors.primaryColorOrange
                                    : Colors.white),
                            child: Text(
                              'Unemployed',
                              style: GoogleFonts.poppins(
                                  color: !isHomeless
                                      ? Colors.white
                                      : AppColors.primaryColorOrange),
                            ),
                          )
                        ])),
                    verticalSpaceRegular,
                    Material(
                      child: TextFormField(
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
                    ),
                    verticalSpaceRegular,
                    Material(
                      child: TextFormField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          hintText: 'Full Name',
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
                    ),
                    verticalSpaceRegular,
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
                              child: TextField(
                            maxLength: 12,
                            inputFormatters: [
                              MaskedTextInputFormatter(
                                mask: 'xxx-xxx-xxxx',
                                separator: '-',
                              )
                            ],
                            controller: phoneController,
                            onChanged: (value) => phone = value,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Phone",
                                counterText: ''),
                          ))
                        ],
                      ),
                    ),
                    verticalSpaceRegular,
                    Material(
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          // You can add more password validation rules if needed
                          return null;
                        },
                      ),
                    ),
                    verticalSpaceRegular,
                    Material(
                      child: TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Confirm Password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
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
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () async {
                            if (_phoneSignupKey.currentState!.validate()) {
                              SignUpFormData().phoneNumber =
                                  phoneController.text;
                              SignUpFormData().socialSecurityNumber =
                                  socialSecurityController.text;

                              SignUpFormData().isHomeless = isHomeless;
                              SignUpFormData().fullName =
                                  fullNameController.text;

                              signUpWithPhone();
                            }
                          },
                          child: const Text("Send the code")),
                    ),
                    verticalSpaceMedium,
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class SignUpFormData {
  String socialSecurityNumber = '';
  String fullName = '';
  String countryCode = '+1';
  String phoneNumber = '';
  String user_id = "";

  bool isHomeless = true;

  Map<String, dynamic> toMap() {
    return {
      'socialSecurityNumber': socialSecurityNumber,
      'name': fullName,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'isHomeless': isHomeless,
      'is_verified': false,
    };
  }

  static final SignUpFormData _instance = SignUpFormData._internal();

  factory SignUpFormData() {
    return _instance;
  }

  SignUpFormData._internal();
}
