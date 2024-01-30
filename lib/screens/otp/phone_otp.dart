import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/screens/verification/under_verification.dart';
import 'package:kadu_booking_app/services/phone_signup_handler.dart';
import 'package:kadu_booking_app/theme/color.dart';

class PhoneOtp extends StatefulWidget {
  String verificationId;
  String phoneNo;

  PhoneOtp({Key? key, required this.verificationId, required this.phoneNo})
      : super(key: key);

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<PhoneOtp> {
  List<String> otpDigits = List.filled(6, ''); // List to store OTP digits

  String otpTemp = '';
  late final TextEditingController _otpController;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // final PhoneSignupHandler _phoneSignUpHandler = PhoneSignupHandler();

  // void handlePhoneSignup(String otp, String verificationId) {
  //   print("The verification Is id $verificationId");
  //   _phoneSignUpHandler.completePhoneSignup(otp, verificationId);
  // }

  Future<String?> completePhoneSignup(
      String smsCode, String verificationId) async {
    print("complete phone signup");
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await _auth.signInWithCredential(credential);
      return null; // Return null to indicate successful signup
    } catch (e) {
      print("Error completing phone signup: $e");
      return "Error completing phone signup: $e";
    }
  }

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundColorDefault,
      body: SafeArea(
        child: _buildOtpScreen(),
      ),
    );
  }

  Widget _buildOtpScreen() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                size: 32,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(height: 18),
          SizedBox(height: 24),
          Text(
            'Verification',
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary),
          ),
          SizedBox(height: 20),
          Text(
            "Enter otp received on phone",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          _buildOTPInputFields('Verify Phone Otp'),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOTPInputFields(buttonMessage) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _textFieldOTP(first: true, last: false, index: 0),
              _textFieldOTP(first: false, last: false, index: 1),
              _textFieldOTP(first: false, last: false, index: 2),
              _textFieldOTP(first: false, last: false, index: 3),
              _textFieldOTP(first: false, last: false, index: 4),
              _textFieldOTP(first: false, last: true, index: 5),
            ],
          ),
          SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  print(widget.verificationId);
                  print("The phone number is");
                  print(widget.phoneNo);

                  PhoneAuthCredential credential =
                      await PhoneAuthProvider.credential(
                          verificationId: widget.verificationId,
                          smsCode: '686868');
                  FirebaseAuth.instance
                      .signInWithPhoneNumber(widget.phoneNo)
                      .then((value) => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => VerificationScreen()),
                          ));
                } catch (e) {
                  print(e);
                }

                String otp = '686868';

                // // Check if the OTP is valid
                // if (otp.length == 6) {
                //   // Call the function to handle phone signup
                //   print("Continue Login");
                //   completePhoneSignup(otp, widget.verificationId);
                // } else {
                //   // Show an error message for invalid OTP length

                //   print("Invalid OTP length  $otp");
                // }
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(
                    AppColors.primaryColorOrange),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(14.0),
                child: Text(
                  buttonMessage,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Didn't you receive any code?",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            "Resend New Code",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _textFieldOTP(
      {bool first = false, bool last = false, required int index}) {
    void _updateOtpController() {
      String otp = otpDigits.join();
      _otpController.text = otp;
    }

    return Container(
      height: 50,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: TextField(
          autofocus: true,
          onChanged: (value) {
            if (value.length == 1 && !last) {
              // FocusScope.of(context).nextFocus();
              otpDigits[index] = value;
              _updateOtpController();
            }
            if (value.isEmpty && !first) {
              FocusScope.of(context).previousFocus();
            }
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            counter: Offstage(),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 2, color: AppColors.textColorPrimary),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 2, color: AppColors.primaryColorOrange),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }
}
