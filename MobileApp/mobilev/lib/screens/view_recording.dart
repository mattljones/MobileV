// Dart & Flutter imports
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports
import 'package:just_audio/just_audio.dart' as ap;
import 'package:share_plus/share_plus.dart';

// Module imports
import 'package:mobilev/models/recording.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/audio_player.dart';
import 'package:mobilev/widgets/status_card.dart';
import 'package:mobilev/widgets/form_input_number.dart';
import 'package:mobilev/widgets/form_button.dart';

class ViewRecordingScreen extends StatefulWidget {
  final String dateRecorded;
  final String audioPath;
  final int? wpm;
  final Map scores;
  final String? wordCloudPath;
  final String? transcript;

  ViewRecordingScreen({
    required this.dateRecorded,
    required this.audioPath,
    required this.wpm,
    required this.scores,
    required this.wordCloudPath,
    required this.transcript,
  });

  @override
  _ViewRecordingScreenState createState() => _ViewRecordingScreenState(
        this.dateRecorded,
        this.audioPath,
        this.wpm,
        this.scores,
        this.wordCloudPath,
        this.transcript,
      );
}

class _ViewRecordingScreenState extends State<ViewRecordingScreen> {
  final String dateRecorded;
  final String audioPath;
  final int? wpm;
  final Map scores;
  final String? wordCloudPath;
  final String? transcript;
  List scoreControllers = [];

  _ViewRecordingScreenState(this.dateRecorded, this.audioPath, this.wpm,
      this.scores, this.wordCloudPath, this.transcript);

  void updateRecording() async {
    Map<String, int> newScores = {};
    for (var i = 0; i < scores.keys.length; i++) {
      int current = int.parse(scoreControllers[i].text);
      if (current != scores.values.toList()[i][1]) {
        newScores['score${i + 1}Value'] = current;
      }
    }
    if (newScores.isNotEmpty) {
      await Recording.updateRecording(
        dateRecorded: dateRecorded,
        newScores: newScores,
      );
    }
  }

  @override
  void initState() {
    super.initState();
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
                        Navigator.pop(context, true);
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
                      onPressed: () {
                        updateRecording();
                        Navigator.pop(context, true);
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
                        Navigator.pop(context, true);
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
