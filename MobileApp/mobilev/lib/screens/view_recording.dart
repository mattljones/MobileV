// Dart & Flutter imports
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports
import 'package:just_audio/just_audio.dart' as ap;
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Module imports
import 'package:mobilev/services/network_service.dart';
import 'package:mobilev/models/recording.dart';
import 'package:mobilev/models/user_data.dart';
import 'package:mobilev/screens/share_agreement.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/audio_player.dart';
import 'package:mobilev/widgets/status_card.dart';
import 'package:mobilev/widgets/form_input_number.dart';
import 'package:mobilev/widgets/form_button.dart';

class ViewRecordingScreen extends StatefulWidget {
  final String dateRecorded;
  final String type;
  final int duration;
  final String audioPath;
  final int? wpm;
  final Map scores;
  final String? wordCloudPath;
  final String? transcript;
  final bool isShared;
  final AnalysisStatus analysisStatus;

  ViewRecordingScreen(
      {required this.dateRecorded,
      required this.type,
      required this.duration,
      required this.audioPath,
      required this.wpm,
      required this.scores,
      required this.wordCloudPath,
      required this.transcript,
      required this.isShared,
      required this.analysisStatus});

  @override
  _ViewRecordingScreenState createState() => _ViewRecordingScreenState(
        this.dateRecorded,
        this.type,
        this.duration,
        this.audioPath,
        this.wpm,
        this.scores,
        this.wordCloudPath,
        this.transcript,
        this.isShared,
        this.analysisStatus,
      );
}

class _ViewRecordingScreenState extends State<ViewRecordingScreen> {
  final String dateRecorded;
  final String type;
  final int duration;
  final String audioPath;
  final int? wpm;
  final Map scores;
  final String? wordCloudPath;
  final String? transcript;
  final bool isShared;
  final AnalysisStatus analysisStatus;
  final formKey = GlobalKey<FormState>();
  List scoreControllers = [];
  bool isUploading = false;

  _ViewRecordingScreenState(
    this.dateRecorded,
    this.type,
    this.duration,
    this.audioPath,
    this.wpm,
    this.scores,
    this.wordCloudPath,
    this.transcript,
    this.isShared,
    this.analysisStatus,
  );

  @override
  void initState() {
    super.initState();
    // Only instantiate the text controllers that are needed (expensive)
    for (var i = 0; i < scores.keys.length; i++) {
      var initialValue = scores.values.toList()[i][1].toString() != 'null'
          ? scores.values.toList()[i][1].toString()
          : '';
      scoreControllers.add(TextEditingController(text: initialValue));
    }
  }

  @override
  void dispose() {
    for (var scoreController in scoreControllers) {
      scoreController.dispose();
    }
    super.dispose();
  }

  // Helper function to construct the correct file name for an updated recording
  String constructFileName(String fileType) {
    String newFileName =
        dateRecorded.replaceAll(' ', '_').replaceAll(':', '-') +
            '_$fileType' +
            '_$type' +
            '_${duration}s';

    // Include WPM if available
    newFileName += wpm != null ? '_WPM_$wpm' : '';

    for (var i = 0; i < scores.keys.length; i++) {
      if (scoreControllers[i].text != '') {
        newFileName +=
            '_${scores.values.toList()[i][0]}_' + scoreControllers[i].text;
      }
    }

    // Add appropriate file extension
    newFileName += fileType == 'Audio' ? '.m4a' : '.jpg';

    return newFileName;
  }

  // Helper function to update a recording
  Future<bool> updateRecording() async {
    Map<String, dynamic> newFields = {};
    for (var i = 0; i < scores.keys.length; i++) {
      var current = scoreControllers[i].text != ''
          ? int.parse(scoreControllers[i].text)
          : null;
      if (current != scores.values.toList()[i][1]) {
        newFields['score${i + 1}Value'] = current;
      }
    }
    if (newFields.isNotEmpty) {
      String directoryPath = (await getApplicationDocumentsDirectory()).path;

      // Update audio file path
      String newAudioFilePath = constructFileName('Audio');
      newFields['audioFilePath'] = newAudioFilePath;
      File audio = File(path.join(directoryPath, audioPath));
      audio.renameSync(path.join(directoryPath, newAudioFilePath));

      // Update word cloud file path (if it exists)
      if (wordCloudPath != null) {
        String newWordCloudFilePath = constructFileName('WordCloud');
        newFields['wordCloudFilePath'] = newWordCloudFilePath;
        File cloud = File(path.join(directoryPath, wordCloudPath));
        cloud.renameSync(path.join(directoryPath, newWordCloudFilePath));
      }

      await Recording.updateRecording(
        dateRecorded: dateRecorded,
        newFields: newFields,
      );

      return true; // Signifies changes were made
    }

    return false; // Signifies no changes were made (no new fields)
  }

  // Helper function for sharing a recording that wasn't originally shared
  Future<bool> shareRecording(UserData sharePreference) async {
    // Construct relevant recording metadata
    Map<String, dynamic> recordingData = {
      'dateRecorded': dateRecorded,
      'type': type,
      'duration': duration,
      'score1_name':
          scores.values.length > 0 ? scores.values.toList()[0][0] : '',
      'score1_value': scores.values.length > 0 && scoreControllers[0].text != ''
          ? int.parse(scoreControllers[0].text)
          : '',
      'score2_name':
          scores.values.length > 1 ? scores.values.toList()[1][0] : '',
      'score2_value': scores.values.length > 1 && scoreControllers[1].text != ''
          ? int.parse(scoreControllers[1].text)
          : '',
      'score3_name':
          scores.values.length > 2 ? scores.values.toList()[2][0] : '',
      'score3_value': scores.values.length > 2 && scoreControllers[2].text != ''
          ? int.parse(scoreControllers[2].text)
          : '',
    };

    // Construct absolute file path
    String directoryPath = (await getApplicationDocumentsDirectory()).path;
    String absPath = path.join(directoryPath, constructFileName('Audio'));

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

  // Helper function to update scores on the server
  Future<bool> shareUpdatedScores() async {
    var newScore1Value =
        scores.values.length > 0 && scoreControllers[0].text != ''
            ? int.parse(scoreControllers[0].text)
            : '';
    var newScore2Value =
        scores.values.length > 1 && scoreControllers[1].text != ''
            ? int.parse(scoreControllers[1].text)
            : '';
    var newScore3Value =
        scores.values.length > 2 && scoreControllers[2].text != ''
            ? int.parse(scoreControllers[2].text)
            : '';

    final result = await NetworkService.updateScores(
        context, dateRecorded, newScore1Value, newScore2Value, newScore3Value);

    return result;
  }

  SingleChildScrollView buildScoresTab(BuildContext context) =>
      SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(45.0, 0.0, 45.0, 30.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AudioPlayer(
                source: ap.AudioSource.uri(Uri.parse(audioPath)),
                hasDelete: false,
                onDelete: () {},
              ),
              SizedBox(height: 30.0),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'Roboto',
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'WPM: ',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: (wpm ?? 'N/A').toString(),
                      style: TextStyle(fontWeight: FontWeight.w300),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              for (var i = 0; i < scores.keys.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: 30.0),
                  child: FormInputNumber(
                    controller: scoreControllers[i],
                    label: scores.values.toList()[i][0],
                  ),
                ),
              // Only show save/update buttons if there is at least one score field
              if (scores.keys.length > 0)
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: FormButton(
                        text: 'Save',
                        buttonColour: kSecondaryTextColour,
                        textColour: Colors.white,
                        onPressed: () {
                          // Check all fields complete
                          updateRecording();
                          Navigator.pop(context, 1);
                        },
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Flexible(
                      flex: 2,
                      child: FormButton(
                        text: isUploading ? '' : 'Save & Share',
                        buttonColour: kPrimaryColour,
                        textColour: Colors.white,
                        icon: isUploading
                            ? SpinKitPouringHourGlass(
                                color: Colors.white,
                                size: 40.0,
                              )
                            : null,
                        onPressed: () async {
                          // Check if user has accepted the sharing agreement
                          UserData sharePreference =
                              await UserData.selectUserData('sharePreference');
                          // If they haven't, make them accept it first
                          if (sharePreference.field1 == '0' &&
                              (sharePreference.field2 == '0' ||
                                  type == 'Numeric')) {
                            FocusScope.of(context).unfocus();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ShareAgreementScreen(
                                    firstLogin: false,
                                    sharePreference: sharePreference,
                                    shareRecording:
                                        sharePreference.field1 == '1',
                                    shareWordCloud:
                                        sharePreference.field2 == '1',
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
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            });
                          }
                          // Otherwise, update recording then try to share update
                          else {
                            bool changesMade = await updateRecording();
                            // If not yet shared, attempt to share
                            if (!isShared) {
                              setState(() {
                                isUploading = true;
                              });
                              final successfulShare =
                                  await shareRecording(sharePreference);
                              if (successfulShare) {
                                // Update recording to show that it's been shared
                                Recording.updateRecording(
                                  dateRecorded: dateRecorded,
                                  newFields: {
                                    'isShared': 1,
                                    'analysisStatus': 'pending',
                                  },
                                );
                                setState(() {
                                  isUploading = false;
                                });
                                Navigator.pop(this.context, 2);
                              } else {
                                setState(() {
                                  isUploading = false;
                                });
                                // Show error message
                                Navigator.pop(this.context, 3);
                              }
                            }
                            // Otherwise, consider different possibilities
                            else {
                              // Update scores on the server
                              if (changesMade &&
                                  analysisStatus == AnalysisStatus.received) {
                                setState(() {
                                  isUploading = true;
                                });
                                final successfulUpdate =
                                    await shareUpdatedScores();
                                if (successfulUpdate) {
                                  setState(() {
                                    isUploading = false;
                                  });
                                  Navigator.pop(this.context, 2);
                                } else {
                                  setState(() {
                                    isUploading = false;
                                  });
                                  // Show error message
                                  Navigator.pop(this.context, 3);
                                }
                              }
                              // Prevent sharing the update
                              else if (analysisStatus ==
                                  AnalysisStatus.pending) {
                                // Ask user to wait to receive analysis first before updating
                                Navigator.pop(this.context, 4);
                              }
                              // Finally, if none of the above, pop to main page
                              else {
                                Navigator.pop(context);
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );

  NotificationListener buildAnalysisTab() =>
      NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return true;
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0),
              Material(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: InteractiveViewer(
                    child: Image.file(
                      File(wordCloudPath!),
                    ),
                  ),
                ),
                elevation: 10.0,
              ),
              SizedBox(height: 30.0),
              Text(
                'Transcript',
                style: TextStyle(
                  fontFamily: 'PTSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                transcript!,
                style: TextStyle(
                  fontSize: 17.0,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View recording'),
        actions: [
          // Share (e.g. via WhatsApp) functionality
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.white,
            ),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (_) => SimpleDialog(
                  title: Text(
                    'Direct sharing',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  children: [
                    SimpleDialogOption(
                      child: Text(
                        'You can also share your recordings and/or word clouds directly (e.g. via WhatsApp)',
                        style: TextStyle(height: 1.3),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    SimpleDialogOption(
                      child: StatusCard(
                        colour: kPrimaryColour,
                        label: 'Recording',
                        icon: Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                        iconFirst: true,
                      ),
                      onPressed: () async {
                        Share.shareFiles([audioPath]);
                      },
                    ),
                    if (wordCloudPath != null)
                      SimpleDialogOption(
                        child: StatusCard(
                          colour: kPrimaryColour,
                          label: 'Word Cloud',
                          icon: Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                          iconFirst: true,
                        ),
                        onPressed: () async {
                          Share.shareFiles([wordCloudPath!]);
                        },
                      ),
                    if (wordCloudPath != null)
                      SimpleDialogOption(
                        child: StatusCard(
                          colour: kPrimaryColour,
                          label: 'Recording + Word Cloud',
                          icon: Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                          iconFirst: true,
                        ),
                        onPressed: () async {
                          Share.shareFiles([audioPath, wordCloudPath!]);
                        },
                      ),
                  ],
                ),
              );
            },
          ),
          // Delete recording functionality
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    'Confirm deletion',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  content: Text('This cannot be undone'),
                  actions: [
                    MaterialButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    MaterialButton(
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        // Delete from database
                        await Recording.deleteRecording(dateRecorded);
                        // Delete files (audio, word cloud if exists)
                        var directoryPath =
                            (await getApplicationDocumentsDirectory()).path;
                        String fullAudioPath =
                            path.join(directoryPath, audioPath);
                        File(fullAudioPath).delete();
                        if (wordCloudPath != null) {
                          String fullCloudPath =
                              path.join(directoryPath, wordCloudPath);
                          File(fullCloudPath).delete();
                        }
                        Navigator.pop(context);
                        Navigator.pop(context, 5);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Builder(builder: (BuildContext context) {
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 20.0),
                  child: TabBar(
                    indicatorColor: kPrimaryColour,
                    unselectedLabelColor: transcript != null
                        ? kPrimaryTextColour
                        : kSecondaryTextColour,
                    onTap: (index) {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      // Do not allow navigation to analysis tab if no analysis present
                      if (transcript == null) {
                        DefaultTabController.of(context)?.animateTo(0);
                      } else if (index == 1) {
                        sleep(Duration(milliseconds: 100));
                        DefaultTabController.of(context)?.animateTo(index);
                      } else {
                        DefaultTabController.of(context)?.animateTo(index);
                      }
                    },
                    tabs: [
                      Tab(text: 'SCORES'),
                      Tab(text: 'TRANSCRIPT'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      buildScoresTab(context),
                      // Do not build analysis tab if no analysis present
                      if (transcript != null) buildAnalysisTab() else Text(''),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
