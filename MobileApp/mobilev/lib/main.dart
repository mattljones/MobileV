import 'package:flutter/material.dart';
import 'package:mobilev/config/routes.dart';
import 'package:mobilev/config/theme.dart';

void main() {
  runApp(MobileVApp());
}

class MobileVApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MobileV',
      theme: theme,
      initialRoute: '/home',
      routes: routes,
    );
  }
}
