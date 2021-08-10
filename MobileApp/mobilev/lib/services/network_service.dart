// Dart & Flutter imports
import 'dart:convert';

// Package imports
import 'package:http/http.dart' as http;

class NetworkService {
  static const baseURL = 'http://10.0.2.2:5000';

  // POST: Change password
  static Future<String> changePassword(
      String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse(baseURL + '/change-password/app'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // POST: Password reset request
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

  // GET: User's name and SRO name
  static Future<dynamic> getNames() async {
    try {
      final response = await http.get(Uri.parse(baseURL + '/get-names'));
      if (response.statusCode == 200) {
        return (jsonDecode(response.body));
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // GET: User's currently allocated scores
  static Future<dynamic> getScores() async {
    try {
      final response = await http.get(Uri.parse(baseURL + '/get-scores'));
      if (response.statusCode == 200) {
        return (jsonDecode(response.body));
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
