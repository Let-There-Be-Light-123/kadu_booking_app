import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  OtpScreen({required this.phoneNumber});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter the OTP sent to ${widget.phoneNumber}'),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'OTP'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Validate OTP and create account if valid
                _createAccount(context);
              },
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }

  void _createAccount(BuildContext context) {
    // Validate OTP (you can add more validation)
    if (_otpController.text.isNotEmpty && _otpController.text.length == 6) {
      // TODO: Implement account creation logic here

      // For now, just navigate to the home screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Show an error message or handle invalid OTP
      print('Invalid OTP');
    }
  }
}
