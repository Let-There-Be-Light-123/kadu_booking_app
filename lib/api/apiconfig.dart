import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String? baseUrl = dotenv.env['API_URL'];

  static String buildUrl(String endpoint) {
    return '$baseUrl/$endpoint';
  }

  // static String authKey = "411573Aa1y6QKQsl657759ffP1";
  // 411573AYVkbfHl6575e175P1
  static String authKey = "412445AF20Kj9G658845bfP1";
  static String emailDomain = "lkseqc.mailer91.com";
}
