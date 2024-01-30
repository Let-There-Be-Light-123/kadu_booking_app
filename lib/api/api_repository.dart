import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kadu_booking_app/api/apiconfig.dart';

class Network {
  final String _url = ApiConfig.buildUrl('api/');
  var token;
  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var storedToken = localStorage.getString('token');
    if (storedToken != null) {
      token = jsonDecode(storedToken)['token'];
    } else {
      print('Token not found in local storage.');
    }
  }

  authData(data, apiUrl) async {
    debugPrint(_url);

    var fullUrl = Uri.parse(_url + apiUrl);
    var response = await http.post(fullUrl,
        body: jsonEncode(data), headers: _setHeaders());
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData.containsKey('token')) {
        var receivedToken = responseData['token'];
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('token', jsonEncode({'token': receivedToken}));
      }
    }

    return response;
  }

  getData(apiUrl) async {
    await _getToken();
    var fullUrl = Uri.parse(_url + apiUrl);
    debugPrint('Sending GET request to: $fullUrl');
    var response = await http.get(fullUrl, headers: _setHeaders());
    debugPrint('Response status: ${response.statusCode}');
    return response;
  }

  logout() async {
    await _getToken();
    var fullUrl = Uri.parse(_url + 'logout');
    var response = await http.get(fullUrl, headers: _setHeaders());
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove('token');
    return response;
  }

  _setHeaders() {
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    // print("Attempting to get the token $token");
    if (token != null) {
      // print("the token is $token");
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> validateEmail(String userEmail) async {
    try {
      final response = await http.post(
        Uri.parse('$_url/validateEmail'),
        body: {'user_email': userEmail},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to validate email');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> signUp(Map<String, dynamic> userData) async {
    try {
      debugPrint("Registering with user data $userData");
      userData.forEach((key, value) {
        debugPrint('$key: ${value.runtimeType}');
      });

      var fullUrl = Uri.parse('${_url}register');
      final response = await http.post(fullUrl,
          body: jsonEncode(userData),
          headers: {'Content-type': 'application/json'});

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 500) {
        throw Exception('Failed to register user. Internal Server Error.');
      } else {
        throw Exception(
            'Failed to register user. ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Failed to register user. Network error: $e');
      } else {
        throw Exception('Failed to register user: $e');
      }
    }
  }

  Future<void> getAndSendFCMTokenToServer() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();

    if (fcmToken != null) {
      try {
        final response = await http.post(
          Uri.parse('${dotenv.env['API_URL']}/api/store-fcm-token'),
          body: {'remember_token': fcmToken},
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          },
        );

        if (response.statusCode == 200) {
          debugPrint('FCM Token sent to server successfully.');
        } else {
          debugPrint(
              'Failed to send FCM Token to server. Status Code: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error sending FCM Token to server: $e');
      }
    }
  }
}
