import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/toggle_buttons.dart';

class AddRecordingScreen extends StatefulWidget {
  @override
  _AddRecordingScreenState createState() => _AddRecordingScreenState();
}

class _AddRecordingScreenState extends State<AddRecordingScreen> {
  List<bool> typeIsSelected = [true, false];
  List<bool> durationIsSelected = [true, false, false, false];
  bool isRecording = false;
  int duration = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a recording'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 120.0),
          RawMaterialButton(
            elevation: 10.0,
            constraints: BoxConstraints.tightFor(
              width: 110.0,
              height: 110.0,
            ),
            shape: CircleBorder(),
            child: isRecording
                ? Icon(Icons.mic, size: 55.0)
                : Icon(Icons.touch_app, size: 55.0),
            fillColor: isRecording ? Colors.red : kAccentColour,
            onPressed: () {
              final player = AudioCache();
              isRecording
                  ? player.play('audio/record_off.mp3')
                  : player.play('audio/record_on.mp3');
              setState(() {
                isRecording = !isRecording;
              });
            },
          ),
          SizedBox(height: 50.0),
          MyToggleButtons(
            fields: ['Numeric', 'Text'],
            isSelected: typeIsSelected,
            onPressed: (int index) {
              setState(() {
                for (int buttonIndex = 0;
                    buttonIndex < typeIsSelected.length;
                    buttonIndex++) {
                  if (buttonIndex == index) {
                    typeIsSelected[buttonIndex] = true;
                  } else {
                    typeIsSelected[buttonIndex] = false;
                  }
                }
              });
            },
          ),
          SizedBox(height: 30.0),
          MyToggleButtons(
            fields: ['30s', '60s', '90s', '120s'],
            isSelected: durationIsSelected,
            onPressed: (int index) {
              setState(() {
                for (int buttonIndex = 0;
                    buttonIndex < durationIsSelected.length;
                    buttonIndex++) {
                  if (buttonIndex == index) {
                    durationIsSelected[buttonIndex] = true;
                  } else {
                    durationIsSelected[buttonIndex] = false;
                  }
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
