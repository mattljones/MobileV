import 'package:flutter/material.dart';
import 'package:mobilev/screens/add_recording.dart';
import 'package:mobilev/screens/change_password.dart';
import 'package:mobilev/screens/forgot_password.dart';
import 'package:mobilev/screens/login.dart';
import 'package:mobilev/screens/my_home.dart';
import 'package:mobilev/screens/view_recording.dart';

final Map<String, WidgetBuilder> routes = {
  "/add-recording": (BuildContext context) => AddRecordingScreen(),
  "/change-password": (BuildContext context) => ChangePasswordScreen(),
  "/forgot-password": (BuildContext context) => ForgotPasswordScreen(),
  "/login": (BuildContext context) => LoginScreen(),
  "/my-home": (BuildContext context) => MyHomeScreen(),
  "/view-recording": (BuildContext context) => ViewRecordingScreen(),
};
