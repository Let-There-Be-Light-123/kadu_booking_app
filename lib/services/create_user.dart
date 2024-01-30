// // import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// Future<void> createUserInFirestore(String isHomeless, String? social_security,
//     String? name, String email, String password) async {
//   try {
//     UserCredential userCredential =
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );

//     // Access the user's unique ID
//     String userId = userCredential.user!.uid;
//     // Create a document with "is verified" and "user id" fields
//     await FirebaseFirestore.instance
//         .collection('registered_users')
//         .doc(userId)
//         .set({
//       'is_homeless': isHomeless,
//       'email': email,
//       'is_verified': false, // Set to false by default
//       'user_id': userId,
//       'social_security': social_security,
//       'name': name
//       // Add other user-related data here
//     });
//     print("User created in registered users");
//   } catch (error) {
//     // Handle registration error
//     print("Registration error: $error");
//   }
// }
