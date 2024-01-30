import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FileService {
  static String baseUrl =
      '${dotenv.env['API_URL']}/api/'; // Replace with your actual API base URL

  Future<List<Map<String, dynamic>>> getFilesForProperty(
      String propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/properties/$propertyId/files'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print(
            'Failed to get files for property. Server responded with status code ${response.statusCode}');
        return []; // or throw an exception based on your error handling strategy
      }
    } catch (e) {
      print('Error getting files for property: $e');
      return []; // or throw an exception based on your error handling strategy
    }
  }
}
