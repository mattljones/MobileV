// Dart & Flutter imports
import 'dart:io';
import 'dart:convert';

// Package imports
import 'package:http/http.dart' as http;

class NetworkService {
  static const baseURL = 'http://10.0.2.2:5000';

  // GET requests --------------------------------------------------------------

  // My profile body names
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

  // User's currently allocated scores
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

  // POST requests --------------------------------------------------------------

  // Uploading recording and associated metadata
  static Future<bool> uploadRecording(Map<String, dynamic> recordingData,
      String audioPath, String shareType) async {
    try {
      List<int> rawBytes = File(audioPath).readAsBytesSync();
      String base64Audio = base64.encode(rawBytes);
      final response = await http.post(
        Uri.parse(baseURL + '/transcribe'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'dateRecorded': recordingData['dateRecorded'],
          'type': recordingData['type'],
          'duration': recordingData['duration'].toString(),
          'score1_name': recordingData['score1_name'],
          'score1_value': recordingData['score1_value'].toString(),
          'score2_name': recordingData['score2_name'],
          'score2_value': recordingData['score2_value'].toString(),
          'score3_name': recordingData['score3_name'],
          'score3_value': recordingData['score3_value'].toString(),
          'shareType': shareType,
          'audioFile': base64Audio,
        }),
      );
      return (response.body == 'successful') ? true : false;
    } catch (e) {
      return false;
    }
  }

  // Change password
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

  // Password reset
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
