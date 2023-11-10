import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kadu_booking_app/services/users.dart';

Future<RegisteredUser?> handleLogin(String email, String password) async {
  try {
    String user = '$email@12345adivivekdomain.com';
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: user,
      password: password,
    );
    print("login success");

    String userId = userCredential.user!.uid;
    print(userId);
    QuerySnapshot querySnapshot = await firestore
        .collection('registered_users')
        .where('user_id', isEqualTo: userId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot document = querySnapshot.docs.first;
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      RegisteredUser user = RegisteredUser.fromJson(data);
      return user;
    } else {
      // Handle the case where no user with the given user_id is found.
      return null;
    }
  } catch (error) {
    // Handle registration error
    return null;
  }
}
