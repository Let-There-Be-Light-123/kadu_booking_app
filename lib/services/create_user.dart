import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> createUserInFirestore(String isHomeless, String? social_security,
    String? phone, String email, String password) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Access the user's unique ID
    String userId = userCredential.user!.uid;
    String socialLogin = '$social_security@12345adivivekdomain.com';
    // Create a document with "is verified" and "user id" fields
    await FirebaseFirestore.instance
        .collection('registered_users')
        .doc(userId)
        .set({
      'is_homeless': isHomeless,
      'email': socialLogin,
      'email_secondary': email,
      'is_verified': false, // Set to false by default
      'user_id': userId,
      'social_security': social_security,
      'phone': phone
      // Add other user-related data here
    });

    // After this step, the user document is created in the 'users' collection.
  } catch (error) {
    // Handle registration error
    print("Registration error: $error");
  }
}
