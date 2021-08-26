// Dart & Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Module imports
import 'package:mobilev/services/database_service.dart';
import 'package:mobilev/services/notification_service.dart';
import 'package:mobilev/services/network_service.dart';
import 'package:mobilev/config/routes.dart';
import 'package:mobilev/config/theme.dart';

// Set to 'true' to seed phone's database with dummy data on installation
bool seedDatabase = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await NotificationService().init();
  seedDatabase
      ? await databaseService.initSeed()
      : await databaseService.init();
  // Do not require sign in if user closed the app without signing out
  bool hasToken = await NetworkService.checkHasToken();
  String initialRoute = hasToken ? '/my-home' : '/login';
  runApp(MobileVApp(initialRoute));
}

class MobileVApp extends StatelessWidget {
  final String initialRoute;
  MobileVApp(this.initialRoute);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MobileV',
      theme: theme,
      initialRoute: initialRoute,
      routes: routes,
    );
  }
}
