// Dart & Flutter imports
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports
import 'package:just_audio/just_audio.dart' as ap;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:wakelock/wakelock.dart';

// Module imports
import 'package:mobilev/models/recording.dart';
import 'package:mobilev/models/user_data.dart';
import 'package:mobilev/screens/share_agreement.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/toggle_buttons.dart';
import 'package:mobilev/widgets/audio_player.dart';
import 'package:mobilev/widgets/form_button.dart';
import 'package:mobilev/widgets/form_input_number.dart';

/*
 * ADD RECORDING LAYOUT & LOGIC ------------------------------------------------
 */

class AddRecordingScreen extends StatefulWidget {
  @override
  _AddRecordingScreenState createState() => _AddRecordingScreenState();
}

class _AddRecordingScreenState extends State<AddRecordingScreen>
    with TickerProviderStateMixin {
  int tabIndex = 0;
  List<String> types = ['Numeric', 'Text'];
  List<bool> typeIsSelected = [true, false];
  String typeSet = 'Numeric';
  List<int> durations = [30, 60, 90, 120];
  List<bool> durationIsSelected = [true, false, false, false];
  int durationSet = 30;
  bool hasRecording = false;
  bool showPlayer = false;
  ap.AudioSource? audioSource;
  final score1Controller = TextEditingController();
  final score2Controller = TextEditingController();
  final score3Controller = TextEditingController();

  @override
  void dispose() {
    score1Controller.dispose();
    score2Controller.dispose();
    score3Controller.dispose();
    super.dispose();
  }

  // Helper function to update state based on whether the user has made a recording
  void updateRecordingStatus(bool status) {
    status
        ? setState(() => hasRecording = true)
        : setState(() => hasRecording = false);
  }

  // Helper function to construct the correct file name for the new recording
  String constructFileName(String timeNow) {
    String newFileName = timeNow.replaceAll(' ', '_').replaceAll(':', '-') +
        '_Recording' +
        '_$typeSet' +
        '_${durationSet}s' +
        '_Well being_' +
        score1Controller.text +
        '_GAD7_' +
        score2Controller.text +
        '_Steps_' +
        score3Controller.text +
        '.m4a';

    return newFileName;
  }

  // Helper function for saving a new recording
  void saveRecording() async {
    String timeNow = DateTime.now().toString().substring(0, 19);
    // Rename saved audio file to uniquely identify it
    String directoryPath = (await getApplicationDocumentsDirectory()).path;
    String newFileName = constructFileName(timeNow);
    File audio = File(path.join(directoryPath, 'new_recording.m4a'));
    audio.renameSync(path.join(directoryPath, newFileName));

    // Save recording details to database
    var newRecording = Recording(
      dateRecorded: timeNow,
      type: typeSet,
      duration: durationSet,
      audioFilePath: newFileName,
      score1ID: 2,
      score1Value: int.parse(score1Controller.text),
      score2ID: 3,
      score2Value: int.parse(score2Controller.text),
      score3ID: 4,
      score3Value: int.parse(score3Controller.text),
      isShared: 0,
      analysisStatus: 'unavailable',
    );
    await Recording.insertRecording(newRecording);
  }

  Column buildRecordTab(BuildContext context) => Column(
        children: [
          SizedBox(height: 30.0),
          // Type selection
          MyToggleButtons(
            fields: types,
            isSelected: typeIsSelected,
            onPressed: (int index) {
              setState(() {
                for (int buttonIndex = 0;
                    buttonIndex < typeIsSelected.length;
                    buttonIndex++) {
                  if (buttonIndex == index) {
                    typeIsSelected[buttonIndex] = true;
                    typeSet = types[buttonIndex];
                  } else {
                    typeIsSelected[buttonIndex] = false;
                  }
                }
              });
            },
          ),
          SizedBox(height: 30.0),
          // Duration selection
          MyToggleButtons(
            fields: [for (var duration in durations) '${duration}s'],
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
          SizedBox(height: 55.0),
          // Either show a record button or audio player depending on state
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
          // If the user has a recording, show a 'continue' button
          if (hasRecording && showPlayer)
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
            SizedBox(height: 35.0),
            FormInputNumber(
              controller: score1Controller,
              label: 'Well being',
            ),
            SizedBox(height: 30.0),
            FormInputNumber(
              controller: score2Controller,
              label: 'GAD7',
            ),
            SizedBox(height: 30.0),
            FormInputNumber(
              controller: score3Controller,
              label: 'Steps',
            ),
            SizedBox(height: 30.0),
            FormButton(
              text: 'Save',
              buttonColour: kSecondaryTextColour,
              textColour: Colors.white,
              onPressed: () {
                saveRecording();
                Navigator.pop(this.context, false);
              },
            ),
            SizedBox(height: 15.0),
            FormButton(
              text: 'Save & Share',
              buttonColour: kPrimaryColour,
              textColour: Colors.white,
              onPressed: () async {
                // Check if user has accepted the sharing agreement
                UserData sharePreference =
                    await UserData.selectUserData('sharePreference');
                if (sharePreference.field1 == '0' &&
                    sharePreference.field2 == '0') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ShareAgreementScreen(
                          firstLogin: false,
                          sharePreference: sharePreference,
                          shareRecording: false,
                          shareWordCloud: false,
                        );
                      },
                    ),
                  ).then((value) {
                    // Notify user if they accepted the agreement
                    if (value != null && value == true) {
                      final snackBar = SnackBar(
                        backgroundColor: kSecondaryTextColour,
                        content: Text('Share agreement accepted'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  });
                } else {
                  saveRecording();
                  Navigator.pop(this.context, true);
                }
              },
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Delete recording if one was made but not saved
        var directoryPath = (await getApplicationDocumentsDirectory()).path;
        String filePath = path.join(directoryPath, 'new_recording.m4a');
        if (File(filePath).existsSync()) {
          File(filePath).delete();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add recording'),
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
                      unselectedLabelColor: hasRecording && showPlayer
                          ? kPrimaryTextColour
                          : kSecondaryTextColour,
                      onTap: (index) {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        if (!hasRecording || !showPlayer) {
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

/*
 * RECORDING FUNCTIONALITY -----------------------------------------------------
 */

// This code is based on: https://github.com/llfbandit/record/blob/master/record/example/lib/main.dart

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
    widget.updateRecordingStatus(true);
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
        String directoryPath = (await getApplicationDocumentsDirectory()).path;
        String audioPath = path.join(directoryPath, 'new_recording.m4a');
        await audioRecorder.start(path: audioPath);
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
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowGlow();
        return true;
      },
      child: ListView(
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
      ),
    );
  }
}
