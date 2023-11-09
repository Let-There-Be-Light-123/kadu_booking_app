import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordService {
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );
    } catch (e) {
      throw Exception("Password reset failed: $e");
    }
  }
}

class AuthServices {
  final ResetPasswordService resetPasswordService = ResetPasswordService();

  Future<void> resetPassword(String email) async {
    await resetPasswordService.resetPassword(email);
  }
}
