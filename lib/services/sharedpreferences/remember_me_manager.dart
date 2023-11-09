import 'package:shared_preferences/shared_preferences.dart';

class RememberMeManager {
  static const _rememberMeKey = 'rememberMe';
  static const _emailKey = 'email';
  static const _passwordKey = 'password';

  static Future<void> saveRememberMe(
      bool rememberMe, String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_rememberMeKey, rememberMe);
    if (rememberMe) {
      prefs.setString(_emailKey, email);
      prefs.setString(_passwordKey, password);
    } else {
      prefs.remove(_emailKey);
      prefs.remove(_passwordKey);
    }
  }

  static Future<Map<String, dynamic>> loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    String email = prefs.getString(_emailKey) ?? '';
    String password = prefs.getString(_passwordKey) ?? '';

    return {
      'rememberMe': rememberMe,
      'email': email,
      'password': password,
    };
  }
}
