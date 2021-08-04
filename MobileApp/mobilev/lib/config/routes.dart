// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/screens/add_recording.dart';
import 'package:mobilev/screens/forgot_password.dart';
import 'package:mobilev/screens/login.dart';
import 'package:mobilev/screens/my_home.dart';

final Map<String, WidgetBuilder> routes = {
  "/add-recording": (BuildContext context) => AddRecordingScreen(),
  "/forgot-password": (BuildContext context) => ForgotPasswordScreen(),
  "/login": (BuildContext context) => LoginScreen(),
  "/my-home": (BuildContext context) => MyHomeScreen(),
};
