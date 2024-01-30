// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kadu_booking_app/api/api_repository.dart';
import 'package:kadu_booking_app/models/file_model.dart';
import 'package:kadu_booking_app/models/property_model.dart';
import 'package:kadu_booking_app/providers/userdetailsprovider.dart';
import 'package:kadu_booking_app/screens/homescreen/main_screen.dart';
import 'package:kadu_booking_app/screens/signup/signup_with_phone.dart';
import 'package:kadu_booking_app/screens/verification/under_verification.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class SignInVerify extends StatefulWidget {
  final String? email;
  final int? otp;
  final int? mobileNumber;
  final int socialSecurityNumber;
  final bool isHomeless;
  final String fullName;
  final String password;
  const SignInVerify(
      {Key? key,
      this.email,
      this.otp,
      this.mobileNumber,
      required this.socialSecurityNumber,
      required this.isHomeless,
      required this.fullName,
      required this.password})
      : super(key: key);

  @override
  State<SignInVerify> createState() => _MyVerifyState();
}

class _MyVerifyState extends State<SignInVerify> {
  SignUpFormData signUpData = SignUpFormData();
  var smscodeController = TextEditingController();

  Future<void> verifyMailOtp(String email, int otpCode) async {
    debugPrint('The otp ${widget.otp} & the otp entered ${otpCode}');
    if (otpCode == widget.otp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verification successful'),
          backgroundColor: Colors.green,
        ),
      );
      registerUser(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Email verification failed. Incorrect OTP. Try Filling the OTP again'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> verifyPhoneNumber(int mobileNumber, int otpPin) async {
    String finalMobile = '1$mobileNumber';
    int intFinalMobile = int.tryParse(finalMobile) ?? 0;

    final Uri uri = Uri.parse(
        'https://control.msg91.com/api/v5/otp/verify?otp=$otpPin&mobile=$intFinalMobile');

    try {
      final HttpClient client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      HttpClientRequest request = await client.postUrl(uri);
      request.headers.set('content-type', 'application/json');
      request.headers.set('authkey', '411573AYVkbfHl6575e175P1');
      request.add(utf8.encode(json.encode({"key": "value"})));

      HttpClientResponse response = await request.close();

      final String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final Map<String, dynamic> parsedData = jsonDecode(responseBody);

        if (parsedData.containsKey('message') &&
            parsedData.containsKey('type') &&
            parsedData['type'] == 'success') {
          debugPrint('Verification successful: $parsedData');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone verification successful'),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone verification successful'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          registerUser(context);
        } else if (parsedData.containsKey('message') &&
            parsedData.containsKey('type') &&
            parsedData['type'] == 'error') {
          String errorMessage = parsedData['message'] ?? 'Unknown error';
          debugPrint('Error during verification: $errorMessage');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error during verification: $errorMessage'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone verification failed'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during phone verification: $error'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> retryOtp(int mobileNumber) async {
    await retry(mobileNumber);
    smscodeController.clear();
  }

  void registerUser(BuildContext context) async {
    debugPrint("Entering the register user function in otp verify screen");
    Map<String, dynamic> userData;

    if (widget.email != null) {
      userData = {
        'identifier': widget.email,
        'social_security': widget.socialSecurityNumber,
        'name': widget.fullName,
        'password': widget.password,
        'is_homeless': widget.isHomeless
      };
    } else if (widget.mobileNumber != null) {
      userData = {
        'identifier': widget.mobileNumber,
        'social_security': widget.socialSecurityNumber,
        'name': SignUpFormData().fullName,
        'password': widget.password,
        'is_homeless': widget.isHomeless
      };
    } else {
      debugPrint('Error: Neither email nor mobile number is present.');
      return;
    }

    try {
      var response = await Network().signUp(userData);
      if (kDebugMode) {
        print("The response in registeruser is ${response}");
      }
      if (response['message'] == "User registered successfully") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Congratulations, your signup is successful'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        _handleSignIn(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error, your signup was not successful'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during signup: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleSignIn(BuildContext context) async {
    var network = Network();
    Map<String, dynamic> loginData;

    if (widget.email != null) {
      loginData = {
        'identifier': widget.email,
        'password': widget.password,
      };
    } else if (widget.mobileNumber != null) {
      loginData = {
        'identifier': widget.mobileNumber,
        'password': widget.password,
      };
    } else {
      debugPrint('Error: Neither email nor mobile number is present.');
      return;
    }

    var response = await network.authData(loginData, 'login');

    if (response.statusCode == 200) {
      var userDetailsResponse = await network.getData('userDetails');

      if (userDetailsResponse.statusCode == 200) {
        var userDetailsJson = jsonDecode(userDetailsResponse.body);

        var userDetailsProvider = context.read<UserDetailsProvider>();
        List<FileModel>? files = userDetailsProvider.files; // Correct syntax
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
          // ignore: use_build_context_synchronously
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
    }
  }

  Future<void> retry(int mobileNumber) async {
    String finalMobile = '1$mobileNumber'; // Add '1' before the mobile number
    int intFinalMobile =
        int.tryParse(finalMobile) ?? 0; // Convert back to an integer
    final String url =
        'https://control.msg91.com/api/v5/otp/retry?retrytype=text&mobile=$intFinalMobile';
    final Map<String, String> headers = {
      'accept': 'application/json',
      'authkey': '411573AYVkbfHl6575e175P1',
    };

    final Uri uri = Uri.parse(url);

    try {
      final HttpClient client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      final HttpClientRequest request = await client.getUrl(uri);

      headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      final HttpClientResponse response = await request.close();

      if (response.statusCode == 200) {
        final String responseData =
            await response.transform(utf8.decoder).join();
        final Map<String, dynamic> parsedData = jsonDecode(responseData);

        // Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Retry successful'),
          ),
        );
      } else {
        // Show error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Retry failed. Status code: ${response.statusCode}'),
          ),
        );

        final String errorResponse =
            await response.transform(utf8.decoder).join();
        print('Response: $errorResponse');
      }
    } catch (error) {
      // Show error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error during retry'),
        ),
      );

      print('Error during retry: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var smscode;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "We need to register your phone without getting started!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Pinput(
                controller: smscodeController,
                length: 4,
                showCursor: true,
                onChanged: (value) {
                  smscode = value;
                },
                onCompleted: (pin) => print(pin),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColorOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    debugPrint("The sms code is");
                    debugPrint(smscode);

                    if (smscode != null && smscode.isNotEmpty) {
                      try {
                        int parsedSmsCode = int.parse(smscode);
                        if (widget.email != null) {
                          verifyMailOtp(widget.email!, parsedSmsCode);
                        } else if (widget.mobileNumber != null) {
                          int mobileNumber = widget.mobileNumber!;
                          verifyPhoneNumber(mobileNumber, parsedSmsCode);
                        } else {
                          debugPrint(
                              'Error: Neither email nor mobile number is present.');
                        }
                      } catch (e) {
                        debugPrint('Error converting smscode to int: $e');
                      }
                    } else {
                      debugPrint('SMS code is null or empty');
                    }
                  },
                  child: Text(
                    widget.email != null
                        ? "Verify Email"
                        : "Verify Phone Number",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        int number = widget.mobileNumber!;
                        retryOtp(number);
                      },
                      child: const Text(
                        "Send Otp again?",
                        style: TextStyle(color: Colors.black),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
