// Dart & Flutter imports
import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final Color colour;
  final String label;
  final Widget icon;
  final bool iconFirst;

  StatusCard(
      {required this.colour,
      required this.label,
      required this.icon,
      required this.iconFirst});

  @override
  Widget build(BuildContext context) {
    Text textWidget = Text(
      label,
      style: TextStyle(color: Colors.white, fontSize: 15.0),
    );
    List<Widget> children = iconFirst
        ? [icon, SizedBox(width: 10.0), textWidget]
        : [textWidget, SizedBox(width: 10.0), icon];

    return Container(
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}
