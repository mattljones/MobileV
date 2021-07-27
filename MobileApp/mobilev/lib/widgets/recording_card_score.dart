import 'package:flutter/material.dart';

class RecordingCardScore extends StatelessWidget {
  final String scoreName;
  final int scoreValue;

  RecordingCardScore({required this.scoreName, required this.scoreValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: '$scoreName: ',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: '$scoreValue'),
            ],
          ),
        ),
      ],
    );
  }
}
