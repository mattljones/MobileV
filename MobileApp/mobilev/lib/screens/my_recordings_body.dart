import 'package:flutter/material.dart';
import 'package:mobilev/widgets/recording_card.dart';

class RecordingsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RecordingCard(),
          ],
        ),
      ),
    );
  }
}
