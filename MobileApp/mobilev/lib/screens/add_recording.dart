import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as ap;
import 'package:record/record.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/toggle_buttons.dart';
import 'package:mobilev/widgets/audio_player.dart';

class AddRecordingScreen extends StatefulWidget {
  @override
  _AddRecordingScreenState createState() => _AddRecordingScreenState();
}

class _AddRecordingScreenState extends State<AddRecordingScreen> {
  List<bool> typeIsSelected = [true, false];
  List<bool> durationIsSelected = [true, false, false, false];
  bool showPlayer = false;
  ap.AudioSource? audioSource;

  @override
  void initState() {
    showPlayer = false;
    super.initState();
  }

  Column getRecordTab() => Column(
        children: [
          SizedBox(height: 30.0),
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
          SizedBox(height: 60.0),
          showPlayer
              ? AudioPlayer(
                  source: audioSource!,
                  onDelete: () {
                    setState(() => showPlayer = false);
                  },
                )
              : AudioRecorder(
                  onStop: (path) {
                    setState(() {
                      audioSource = ap.AudioSource.uri(Uri.parse(path));
                      showPlayer = true;
                    });
                  },
                ),
        ],
      );

  Center getShareTab() => Center(
        child: Text('Share content'),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a recording'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                child: TabBar(
                  indicatorColor: kPrimaryColour,
                  tabs: [
                    Tab(text: 'RECORD'),
                    Tab(text: 'SAVE & SHARE'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    getRecordTab(),
                    getShareTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AudioRecorder extends StatefulWidget {
  final void Function(String path) onStop;
  AudioRecorder({required this.onStop});

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool isRecording = false;
  final audioRecorder = Record();

  @override
  void initState() {
    isRecording = false;
    super.initState();
  }

  @override
  void dispose() {
    audioRecorder.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecorder.hasPermission()) {
        await audioRecorder.start();
        bool isRecording = await audioRecorder.isRecording();
        setState(() {
          isRecording = isRecording;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> stopRecording() async {
    final path = await audioRecorder.stop();
    widget.onStop(path!);
    setState(() => isRecording = false);
  }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
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
        isRecording ? stopRecording() : startRecording();
        setState(() {
          isRecording = !isRecording;
        });
      },
    );
  }
}
