import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart' as ap;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/toggle_buttons.dart';
import 'package:mobilev/widgets/audio_player.dart';
import 'package:mobilev/widgets/form_button.dart';
import 'package:mobilev/widgets/form_input_number.dart';

class AddRecordingScreen extends StatefulWidget {
  @override
  _AddRecordingScreenState createState() => _AddRecordingScreenState();
}

class _AddRecordingScreenState extends State<AddRecordingScreen>
    with TickerProviderStateMixin {
  int tabIndex = 0;
  List<bool> typeIsSelected = [true, false];
  List<int> durations = [30, 60, 90, 120];
  List<bool> durationIsSelected = [true, false, false, false];
  int durationSet = 30;
  bool hasRecording = false;
  bool showPlayer = false;
  ap.AudioSource? audioSource;

  @override
  void initState() {
    showPlayer = false;
    super.initState();
  }

  void updateRecordingStatus(bool status) {
    status
        ? setState(() => hasRecording = true)
        : setState(() => hasRecording = false);
  }

  Column buildRecordTab(BuildContext context) => Column(
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
              if (!hasRecording) {
                setState(() {
                  for (int buttonIndex = 0;
                      buttonIndex < durationIsSelected.length;
                      buttonIndex++) {
                    if (buttonIndex == index) {
                      durationIsSelected[buttonIndex] = true;
                      durationSet = durations[buttonIndex];
                    } else {
                      durationIsSelected[buttonIndex] = false;
                    }
                  }
                });
              }
            },
          ),
          SizedBox(height: 60.0),
          showPlayer
              ? Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: AudioPlayer(
                    source: audioSource!,
                    hasDelete: true,
                    onDelete: () {
                      setState(() {
                        hasRecording = false;
                        showPlayer = false;
                      });
                    },
                  ),
                )
              : Column(
                  children: [
                    AudioRecorder(
                      durationSet: durationSet,
                      updateRecordingStatus: updateRecordingStatus,
                      onStop: (path) {
                        setState(() {
                          audioSource = ap.AudioSource.uri(Uri.parse(path));
                          showPlayer = true;
                        });
                      },
                    ),
                  ],
                ),
          if (hasRecording)
            Container(
              padding: EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 0.0),
              child: FormButton(
                text: 'Continue',
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                ),
                buttonColour: kPrimaryColour,
                textColour: Colors.white,
                onPressed: () {
                  DefaultTabController.of(context)?.animateTo(1);
                },
              ),
            )
        ],
      );

  SingleChildScrollView buildShareTab() => SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60.0),
            FormInputNumber(label: 'Score 1'),
            SizedBox(height: 30.0),
            FormInputNumber(label: 'Score 2'),
            SizedBox(height: 30.0),
            FormInputNumber(label: 'Score 3'),
            SizedBox(height: 30.0),
            FormButton(
              text: 'Save',
              buttonColour: kSecondaryTextColour,
              textColour: Colors.white,
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            SizedBox(height: 15.0),
            FormButton(
              text: 'Save & Share',
              buttonColour: kPrimaryColour,
              textColour: Colors.white,
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var directory = await getApplicationDocumentsDirectory();
        String filePath = '${directory.path}/test.m4a';
        if (File(filePath).existsSync()) {
          File(filePath).delete();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add a recording'),
        ),
        body: DefaultTabController(
          length: 2,
          child: Builder(builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    child: TabBar(
                      indicatorColor: kPrimaryColour,
                      unselectedLabelColor: hasRecording
                          ? kPrimaryTextColour
                          : kSecondaryTextColour,
                      onTap: (index) {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        if (!hasRecording) {
                          DefaultTabController.of(context)?.animateTo(0);
                        } else if (index == 0) {
                          sleep(Duration(milliseconds: 100));
                          DefaultTabController.of(context)?.animateTo(index);
                        } else {
                          DefaultTabController.of(context)?.animateTo(index);
                        }
                      },
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
                        buildRecordTab(context),
                        buildShareTab(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class AudioRecorder extends StatefulWidget {
  final void Function(String path) onStop;
  final int durationSet;
  final Function(bool) updateRecordingStatus;
  AudioRecorder(
      {required this.onStop,
      required this.updateRecordingStatus,
      required this.durationSet});

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool isRecording = false;
  bool isCancelled = false;
  final audioRecorder = Record();
  bool isCountingDown = false;
  int countdownRemaining = 3;
  Timer? countdownTimer;
  late int timeRemaining;

  Timer? recordTimer;

  @override
  void initState() {
    timeRemaining = widget.durationSet;
    isRecording = false;
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => widget.updateRecordingStatus(false));
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    recordTimer?.cancel();
    audioRecorder.dispose();
    super.dispose();
  }

  Widget buildRecordButtonChild() {
    if (isRecording) {
      return Icon(Icons.mic, size: 55.0);
    } else if (isCountingDown) {
      return Text(
        countdownRemaining.toString(),
        style: TextStyle(
          fontFamily: 'PTMono',
          fontSize: 48.0,
        ),
      );
    } else {
      return Icon(Icons.touch_app, size: 55.0);
    }
  }

  void startCountdownTimer() {
    countdownTimer?.cancel();
    setState(() => isCountingDown = true);
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (countdownRemaining == 1) {
        startRecording();
      }
      if (countdownRemaining > 1) {
        setState(() => countdownRemaining--);
      }
    });
  }

  void startRecordTimer() {
    recordTimer?.cancel();
    setState(() => isCountingDown = true);
    recordTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => timeRemaining--);
      if (timeRemaining == 0) {
        stopRecording();
      }
    });
  }

  Future<void> startRecording() async {
    countdownTimer?.cancel();
    try {
      if (await audioRecorder.hasPermission()) {
        setState(() {
          timeRemaining = widget.durationSet;
        });
        var directory = await getApplicationDocumentsDirectory();
        await audioRecorder.start(path: '${directory.path}/test.m4a');
        bool _isRecording = await audioRecorder.isRecording();
        setState(() {
          isRecording = _isRecording;
          isCountingDown = false;
        });
        startRecordTimer();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> stopRecording() async {
    recordTimer?.cancel();
    isCancelled
        ? widget.updateRecordingStatus(false)
        : widget.updateRecordingStatus(true);
    final path = await audioRecorder.stop();
    widget.onStop(path!);
    setState(() {
      isRecording = false;
      timeRemaining = widget.durationSet;
    });
    Wakelock.disable();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        RawMaterialButton(
          elevation: 10.0,
          disabledElevation: 10.0,
          constraints: BoxConstraints.tightFor(
            width: 110.0,
            height: 110.0,
          ),
          shape: CircleBorder(),
          child: buildRecordButtonChild(),
          fillColor: isRecording ? Colors.red : kAccentColour,
          onPressed: isRecording
              ? null
              : () {
                  Wakelock.enable();
                  startCountdownTimer();
                },
        ),
        SizedBox(height: 30.0),
        Text(
          isRecording
              ? timeRemaining.toString() + 's'
              : widget.durationSet.toString() + 's',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PTMono',
            fontSize: 30.0,
          ),
        ),
        SizedBox(height: 30.0),
        if (isRecording)
          GestureDetector(
            onTap: () {
              setState(() {
                isCancelled = true;
              });
              stopRecording();
            },
            child: Text(
              'Cancel',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }
}
