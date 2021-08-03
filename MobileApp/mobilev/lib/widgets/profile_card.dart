// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/config/constants.dart';

class ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final String route;

  ProfileCard({
    required this.icon,
    required this.title,
    required this.status,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 12.0),
        color: kBackgroundPrimaryColour,
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          trailing: Text(
            status,
            textAlign: TextAlign.end,
          ),
        ),
      ),
    );
  }
}
