// Dart & Flutter imports
import 'dart:convert';

// Package imports
import 'package:http/http.dart' as http;

class NetworkService {
  static const baseURL = 'http://10.0.2.2:5000';

  // Send password reset request
  static Future<bool> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(baseURL + '/reset-password-request/app'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );
      return (response.body == 'successful') ? true : false;
    } catch (e) {
      return false;
    }
  }
}
