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
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Module imports
import 'package:mobilev/services/network_service.dart';
import 'package:mobilev/models/recording.dart';
import 'package:mobilev/models/user_data.dart';
import 'package:mobilev/models/score.dart';
import 'package:mobilev/screens/share_agreement.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/toggle_buttons.dart';
import 'package:mobilev/widgets/audio_player.dart';
import 'package:mobilev/widgets/form_button.dart';
import 'package:mobilev/widgets/form_input_number.dart';

/*
 * ADD RECORDING SCREEN --------------------------------------------------------
 */

class AddRecordingScreen extends StatefulWidget {
  @override
  _AddRecordingScreenState createState() => _AddRecordingScreenState();
}

class _AddRecordingScreenState extends State<AddRecordingScreen>
    with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  int tabIndex = 0;
  List<String> types = ['Text', 'Numeric'];
  List<bool> typeIsSelected = [true, false];
  String typeSet = 'Text';
  List<int> durations = [30, 60, 90, 120];
  List<bool> durationIsSelected = [true, false, false, false];
  int durationSet = 30;
  bool hasRecording = false;
  bool showPlayer = false;
  ap.AudioSource? audioSource;
  bool scoresLoading = true;
  bool scoresLoaded = false;
  Map? latestScores;
  List scoreControllers = [];
  bool isUploading = false;

  // Load scores from the server that the user is supposed to assess themself against
  void getScores() {
    NetworkService.getScores(context).then((data) async {
      // If data couldn't be loaded, use latest 'current' scores stored on device
      if (data == false) {
        var localScores = await Score.selectActiveScores();
        setState(() {
          latestScores = localScores;
          scoresLoading = false;
          // Initialise only the controllers that are needed (expensive)
          for (var i = 0; i < latestScores!.keys.length; i++) {
            scoreControllers.add(TextEditingController());
          }
        });
      }
      // Otherwise, use scores retrieved from server
      else {
        setState(() {
          latestScores = data;
          scoresLoaded = true;
          scoresLoading = false;
          // Initialise only the controllers that are needed (expensive)
          for (var i = 0; i < latestScores!.keys.length; i++) {
            scoreControllers.add(TextEditingController());
          }
          // Update scores saved in database
        });
        await Score.updateActiveScores(latestScores!);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getScores();
  }

  @override
  void dispose() {
    for (var scoreController in scoreControllers) {
      scoreController.dispose();
    }
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
        '_Audio' +
        '_$typeSet' +
        '_${durationSet}s';

    for (var i = 0; i < latestScores!.keys.length; i++) {
      newFileName +=
          '_${latestScores!.values.toList()[i]}_' + scoreControllers[i].text;
    }

    newFileName += '.m4a';

    return newFileName;
  }

  // Helper function for saving a new recording
  Future<List<String>> saveRecording() async {
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
      score1ID: latestScores!.keys.length > 0
          ? int.parse(latestScores!.keys.toList()[0])
          : null,
      score1Value: latestScores!.keys.length > 0
          ? int.parse(scoreControllers[0].text)
          : null,
      score2ID: latestScores!.keys.length > 1
          ? int.parse(latestScores!.keys.toList()[1])
          : null,
      score2Value: latestScores!.keys.length > 1
          ? int.parse(scoreControllers[1].text)
          : null,
      score3ID: latestScores!.keys.length > 2
          ? int.parse(latestScores!.keys.toList()[2])
          : null,
      score3Value: latestScores!.keys.length > 2
          ? int.parse(scoreControllers[2].text)
          : null,
      isShared: 0,
      analysisStatus: 'unavailable',
    );
    await Recording.insertRecording(newRecording);
    return [timeNow, newFileName];
  }

  // Helper function for sharing a new recording
  Future<bool> shareRecording(
      String dateRecorded, String audioPath, UserData sharePreference) async {
    // Construct relevant recording metadata
    Map<String, dynamic> recordingData = {
      'dateRecorded': dateRecorded,
      'type': typeSet,
      'duration': durationSet,
      'score1_name': latestScores!.values.length > 0
          ? latestScores!.values.toList()[0]
          : '',
      'score1_value': latestScores!.values.length > 0
          ? int.parse(scoreControllers[0].text)
          : '',
      'score2_name': latestScores!.values.length > 1
          ? latestScores!.values.toList()[1]
          : '',
      'score2_value': latestScores!.values.length > 1
          ? int.parse(scoreControllers[1].text)
          : '',
      'score3_name': latestScores!.values.length > 2
          ? latestScores!.values.toList()[2]
          : '',
      'score3_value': latestScores!.values.length > 2
          ? int.parse(scoreControllers[2].text)
          : '',
    };

    // Construct absolute file path
    String directoryPath = (await getApplicationDocumentsDirectory()).path;
    String absPath = path.join(directoryPath, audioPath);

    // Translate sharePreference object to string
    String? shareType;
    if (sharePreference.field1 == '1' && sharePreference.field2 == '0') {
      shareType = 'audio';
    } else if (sharePreference.field1 == '0' && sharePreference.field2 == '1') {
      shareType = 'wordCloud';
    } else {
      shareType = 'both';
    }

    final result = await NetworkService.uploadRecording(
        context, recordingData, absPath, shareType);

    return result;
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
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 35.0),
              // If unable to load latest scores, explain to the user
              if (scoresLoaded == false)
                Padding(
                  padding: EdgeInsets.only(bottom: 30.0),
                  child: Text(
                    'Unable to download the latest scoring domains. Most recently loaded scores can be used instead:',
                    style: TextStyle(
                      color: Colors.red,
                      height: 1.3,
                    ),
                  ),
                ),
              // If still loading, show nothing
              if (scoresLoading)
                Text('')
              // Otherwise, dynamically list scores
              else
                for (var i = 0; i < latestScores!.keys.length; i++)
                  Column(
                    children: [
                      FormInputNumber(
                        controller: scoreControllers[i],
                        label: latestScores!.values.toList()[i],
                        validator: (value) {
                          if (value!.length == 0) {
                            return 'Please provide this score';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30.0),
                    ],
                  ),
              FormButton(
                text: 'Save',
                buttonColour: kSecondaryTextColour,
                textColour: Colors.white,
                onPressed: () {
                  // Check all fields complete
                  if (formKey.currentState!.validate()) {
                    saveRecording();
                    Navigator.pop(this.context, 0);
                  }
                },
              ),
              SizedBox(height: 15.0),
              FormButton(
                text: isUploading ? '' : 'Save & Share',
                buttonColour: kPrimaryColour,
                textColour: Colors.white,
                icon: isUploading
                    ? SpinKitPouringHourglass(
                        color: Colors.white,
                        size: 40.0,
                      )
                    : null,
                onPressed: () async {
                  // Check all fields complete
                  if (formKey.currentState!.validate()) {
                    // Check if user has accepted the sharing agreement
                    UserData sharePreference =
                        await UserData.selectUserData('sharePreference');
                    // If they haven't, push the share agreement screen
                    if (sharePreference.field1 == '0' &&
                        (sharePreference.field2 == '0' ||
                            typeSet == 'Numeric')) {
                      FocusScope.of(context).unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ShareAgreementScreen(
                              firstLogin: false,
                              sharePreference: sharePreference,
                              shareRecording: sharePreference.field1 == '1',
                              shareWordCloud: sharePreference.field2 == '1',
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
                    }
                    // Otherwise, save and then try to share
                    else {
                      var recordingData = await saveRecording();
                      setState(() {
                        isUploading = true;
                      });
                      final isShared = await shareRecording(
                          recordingData[0], recordingData[1], sharePreference);
                      if (isShared) {
                        // Update saved recording to show that it's been shared
                        Recording.updateRecording(
                          dateRecorded: recordingData[0],
                          newFields: {
                            'isShared': 1,
                            'analysisStatus': 'pending',
                          },
                        );
                        setState(() {
                          isUploading = false;
                        });
                        Navigator.pop(this.context, 1);
                      } else {
                        setState(() {
                          isUploading = false;
                        });
                        // Explain in snack bar that an error occurred when sharing
                        Navigator.pop(this.context, 2);
                      }
                    }
                  }
                },
              ),
            ],
          ),
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
