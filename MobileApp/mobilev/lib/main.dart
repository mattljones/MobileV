// Dart & Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Module imports
import 'package:mobilev/services/database_service.dart';
import 'package:mobilev/services/notification_service.dart';
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
  runApp(MobileVApp());
}

class MobileVApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MobileV',
      theme: theme,
      initialRoute: '/login',
      routes: routes,
    );
  }
}
