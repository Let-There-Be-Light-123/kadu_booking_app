import 'package:firebase_auth/firebase_auth.dart';

class PhoneLoginHandler {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> initiatePhoneLogin(String phoneNumber) async {
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
        codeSent: (String verificationId, int? resendToken) {
          // Handle code sent
          // (You can use a state management solution for this purpose)
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
      print("Error initiating phone login: $e");
      return "Error initiating phone login: $e";
    }
  }

  Future<String?> completePhoneLogin(
      String smsCode, String verificationId) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await _auth.signInWithCredential(credential);
      return null; // Return null to indicate successful login
    } catch (e) {
      print("Error completing phone login: $e");
      return "Error completing phone login: $e";
    }
  }
}
