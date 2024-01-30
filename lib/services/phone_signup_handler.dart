import 'package:firebase_auth/firebase_auth.dart';

class PhoneSignupHandler {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';

  Future<String?> initiatePhoneSignup(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: $e");
        },
        codeSent: (String newVerificationId, int? resendToken) {
          // Handle code sent
          // (You can use a state management solution for this purpose)
          verificationId = newVerificationId;

          print("Code sent. Verification ID: $verificationId");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
          print(
              "Code auto retrieval timeout. Verification ID: $verificationId");
        },
      );

      return null; // Return null to indicate successful initiation
    } catch (e) {
      print("Error initiating phone signup: $e");
      return "Error initiating phone signup: $e";
    }
  }

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
}
