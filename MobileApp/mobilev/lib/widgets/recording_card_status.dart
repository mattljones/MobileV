import 'package:flutter/material.dart';

class RecordingCardStatus extends StatelessWidget {
  final Color colour;
  final String label;
  final Widget icon;

  RecordingCardStatus(
      {required this.colour, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 15.0),
          ),
          SizedBox(width: 10.0),
          icon,
        ],
      ),
    );
  }
}
