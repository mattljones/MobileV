// Dart & Flutter imports
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

// Package imports
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Module imports
import 'package:mobilev/config/constants.dart';

class NetworkService {
  static const baseURL = 'http://139.162.211.13';
  static final storage = FlutterSecureStorage();

  // JWT helper functions ------------------------------------------------------

  // Insert or update access and refresh tokens
  static Future<void> updateTokens(
      String accessToken, String refreshToken) async {
    await storage.deleteAll();
    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);
  }

  // Retrieve access token
  static Future<String> getAccessToken() async {
    String? accessToken = await storage.read(key: 'accessToken');
    return accessToken!;
  }

  // Retrieve refresh token
  static Future<String> getRefreshToken() async {
    String? refreshToken = await storage.read(key: 'refreshToken');
    return refreshToken!;
  }

  // GET requests --------------------------------------------------------------

  // My profile body names
  static Future<dynamic> getNames(BuildContext context,
      {bool refreshedToken = false}) async {
    String token = await NetworkService.getAccessToken();
    try {
      final response = await http.get(
        Uri.parse(baseURL + '/get-names'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return (jsonDecode(response.body));
      } else if (response.statusCode == 401 && !refreshedToken) {
        bool refreshedToken = await NetworkService.refreshToken(context);
        return refreshedToken
            ? NetworkService.getNames(context, refreshedToken: true)
            : false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // User's currently allocated scores
  static Future<dynamic> getScores(BuildContext context,
      {bool refreshedToken = false}) async {
    String token = await NetworkService.getAccessToken();
    try {
      final response = await http.get(
        Uri.parse(baseURL + '/get-scores'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return (jsonDecode(response.body));
      } else if (response.statusCode == 401 && !refreshedToken) {
        bool refreshedToken = await NetworkService.refreshToken(context);
        return refreshedToken
            ? NetworkService.getScores(context, refreshedToken: true)
            : false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // POST requests -------------------------------------------------------------

  // Sign in
  static Future<dynamic> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseURL + '/login/app'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          <String, String>{
            'username': username,
            'password': password,
          },
        ),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Incorrect credentials
        if (json['authenticated'] == 'False') {
          return 'wrong_credentials';
        }
        // Correct credentials
        else {
          await NetworkService.updateTokens(
              json['accessToken'], json['refreshToken']);
          return true;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Refresh access token (called on a 401 response when logged in)
  static Future<bool> refreshToken(BuildContext context) async {
    String token = await NetworkService.getRefreshToken();
    try {
      final response = await http.post(
        Uri.parse(baseURL + '/refresh-jwt'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final newTokens = jsonDecode(response.body);
        await NetworkService.updateTokens(
            newTokens['accessToken'], newTokens['refreshToken']);
        return true;
      } else if (response.statusCode == 401) {
        Navigator.popAndPushNamed(context, '/login');
        final snackBar = SnackBar(
          backgroundColor: kSecondaryTextColour,
          content: Text('Your session has expired. Please sign in again.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Uploading recording and associated metadata
  static Future<dynamic> uploadRecording(BuildContext context,
      Map<String, dynamic> recordingData, String audioPath, String shareType,
      {bool refreshedToken = false}) async {
    String token = await NetworkService.getAccessToken();
    try {
      List<int> rawBytes = File(audioPath).readAsBytesSync();
      String base64Audio = base64.encode(rawBytes);
      final response = await http.post(
        Uri.parse(baseURL + '/transcribe-analyse'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
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
      if (response.statusCode == 401 && !refreshedToken) {
        bool refreshedToken = await NetworkService.refreshToken(context);
        return refreshedToken
            ? NetworkService.uploadRecording(
                context, recordingData, audioPath, shareType,
                refreshedToken: true)
            : false;
      }
      return (response.body == 'successful') ? true : false;
    } catch (e) {
      return false;
    }
  }

  // Try to download recording analysis
  static Future<dynamic> downloadAnalysis(
      BuildContext context, String dateRecorded,
      {bool refreshedToken = false}) async {
    String token = await NetworkService.getAccessToken();
    try {
      final response = await http.post(
        Uri.parse(baseURL + '/get-analysis'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'dateRecorded': dateRecorded,
        }),
      );
      if (response.statusCode == 200) {
        return (jsonDecode(response.body));
      } else if (response.statusCode == 401 && !refreshedToken) {
        bool refreshedToken = await NetworkService.refreshToken(context);
        return refreshedToken
            ? NetworkService.downloadAnalysis(context, dateRecorded,
                refreshedToken: true)
            : false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Update scores
  static Future<dynamic> updateScores(BuildContext context, String dateRecorded,
      String newScore1Value, String newScore2Value, String newScore3Value,
      {bool refreshedToken = false}) async {
    String token = await NetworkService.getAccessToken();
    try {
      final response = await http.post(
        Uri.parse(baseURL + '/update-recording-scores'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'dateRecorded': dateRecorded,
          'new_score1_value': newScore1Value,
          'new_score2_value': newScore2Value,
          'new_score3_value': newScore3Value,
        }),
      );
      if (response.statusCode == 401 && !refreshedToken) {
        bool refreshedToken = await NetworkService.refreshToken(context);
        return refreshedToken
            ? NetworkService.updateScores(context, dateRecorded, newScore1Value,
                newScore2Value, newScore3Value,
                refreshedToken: true)
            : false;
      }
      return (response.body == 'successful') ? true : false;
    } catch (e) {
      return false;
    }
  }

  // Change password
  static Future<dynamic> changePassword(
      BuildContext context, String oldPassword, String newPassword,
      {bool refreshedToken = false}) async {
    String token = await NetworkService.getAccessToken();
    try {
      final response = await http.post(
        Uri.parse(baseURL + '/change-password/app'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );
      if (response.statusCode == 401 && !refreshedToken) {
        bool refreshedToken = await NetworkService.refreshToken(context);
        return refreshedToken
            ? NetworkService.changePassword(context, oldPassword, newPassword,
                refreshedToken: true)
            : 'error';
      }
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
