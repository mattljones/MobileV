// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/screens/add_recording.dart';
import 'package:mobilev/screens/change_password.dart';
import 'package:mobilev/screens/forgot_password.dart';
import 'package:mobilev/screens/login.dart';
import 'package:mobilev/screens/my_home.dart';
import 'package:mobilev/screens/weekly_reminders.dart';
import 'package:mobilev/screens/share_agreement.dart';

final Map<String, WidgetBuilder> routes = {
  "/add-recording": (BuildContext context) => AddRecordingScreen(),
  "/change-password": (BuildContext context) => ChangePasswordScreen(),
  "/forgot-password": (BuildContext context) => ForgotPasswordScreen(),
  "/login": (BuildContext context) => LoginScreen(),
  "/my-home": (BuildContext context) => MyHomeScreen(),
  "/weekly-reminders": (BuildContext context) => WeeklyRemindersScreen(),
  "/share-agreement": (BuildContext context) => ShareAgreementScreen(),
};
