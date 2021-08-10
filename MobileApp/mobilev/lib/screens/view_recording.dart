// Dart & Flutter imports
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports
import 'package:just_audio/just_audio.dart' as ap;
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// Module imports
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

  ViewRecordingScreen({
    required this.dateRecorded,
    required this.type,
    required this.duration,
    required this.audioPath,
    required this.wpm,
    required this.scores,
    required this.wordCloudPath,
    required this.transcript,
  });

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
  List scoreControllers = [];

  _ViewRecordingScreenState(
      this.dateRecorded,
      this.type,
      this.duration,
      this.audioPath,
      this.wpm,
      this.scores,
      this.wordCloudPath,
      this.transcript);

  @override
  void initState() {
    super.initState();
    // Only instantiate the text controllers that are needed (expensive)
    for (var i = 0; i < scores.keys.length; i++) {
      scoreControllers.add(
          TextEditingController(text: scores.values.toList()[i][1].toString()));
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

    for (var i = 0; i < scores.keys.length; i++) {
      newFileName +=
          '_${scores.values.toList()[i][0]}_' + scoreControllers[i].text;
    }

    newFileName += fileType == 'Audio' ? '.m4a' : '.jpg';

    return newFileName;
  }

  // Helper function to update a recording
  void updateRecording() async {
    Map<String, dynamic> newFields = {};
    for (var i = 0; i < scores.keys.length; i++) {
      int current = int.parse(scoreControllers[i].text);
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
    }
  }

  SingleChildScrollView buildScoresTab(BuildContext context) =>
      SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(45.0, 0.0, 45.0, 30.0),
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
                    flex: 2,
                    child: FormButton(
                      text: 'Save',
                      buttonColour: kSecondaryTextColour,
                      textColour: Colors.white,
                      onPressed: () {
                        updateRecording();
                        Navigator.pop(context, 1);
                      },
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Flexible(
                    flex: 3,
                    child: FormButton(
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
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          });
                        } else {
                          updateRecording();
                          Navigator.pop(context, 2);
                        }
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      );

  SingleChildScrollView buildAnalysisTab() => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            Material(
              child: InteractiveViewer(
                child: Image.file(
                  File(wordCloudPath!),
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
                          'You can also share your recordings and/or word clouds directly (e.g. via WhatsApp)'),
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
                        await Recording.deleteRecording(dateRecorded);
                        Navigator.pop(context);
                        Navigator.pop(context, 3);
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
                      Tab(text: 'ANALYSIS'),
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
