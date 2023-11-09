import 'package:firebase_auth/firebase_auth.dart';
import 'package:kadu_booking_app/services/sharedpreferences/remember_me_manager.dart';

class PersistentLoginManager {
  static Future<bool> isUserAuthenticated() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}
