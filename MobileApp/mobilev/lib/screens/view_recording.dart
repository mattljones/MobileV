// Dart & Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:just_audio/just_audio.dart' as ap;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/audio_player.dart';
import 'package:mobilev/widgets/status_card.dart';
import 'package:mobilev/widgets/form_input_number.dart';
import 'package:mobilev/widgets/form_button.dart';

class ViewRecordingScreen extends StatefulWidget {
  final Map<String, int> scores;
  final AnalysisStatus analysisStatus;
  final String audioPath;

  ViewRecordingScreen({
    required this.scores,
    required this.analysisStatus,
    required this.audioPath,
  });

  @override
  _ViewRecordingScreenState createState() => _ViewRecordingScreenState(
        this.scores,
        this.analysisStatus,
        this.audioPath,
      );
}

class _ViewRecordingScreenState extends State<ViewRecordingScreen> {
  final score1Controller = TextEditingController();
  final score2Controller = TextEditingController();
  final score3Controller = TextEditingController();
  final Map<String, int> scores;
  final AnalysisStatus analysisStatus;
  final String audioPath;

  _ViewRecordingScreenState(this.scores, this.analysisStatus, this.audioPath);

  @override
  void dispose() {
    score1Controller.dispose();
    score2Controller.dispose();
    score3Controller.dispose();
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
                    text: (scores['WPM'] ?? 'N/A').toString(),
                    style: TextStyle(fontWeight: FontWeight.w300),
                  )
                ],
              ),
            ),
            SizedBox(height: 30.0),
            FormInputNumber(
              controller: score1Controller,
              label: 'Score 1',
              initialValue: "68",
            ),
            SizedBox(height: 30.0),
            FormInputNumber(
              controller: score2Controller,
              label: 'Score 2',
              initialValue: scores['ScoreName 2'].toString(),
            ),
            SizedBox(height: 30.0),
            FormInputNumber(
              controller: score3Controller,
              label: 'Score 3',
              initialValue: scores['ScoreName 3'].toString(),
            ),
            SizedBox(height: 30.0),
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: FormButton(
                    text: 'Save',
                    buttonColour: kSecondaryTextColour,
                    textColour: Colors.white,
                    onPressed: () {
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
                child: Image.asset('assets/images/wordcloud_example.jpg'),
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
              testTranscript,
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
                        var directory =
                            await getApplicationDocumentsDirectory();
                        String filePath = '${directory.path}/$audioPath';
                        Share.shareFiles(
                          [filePath],
                        );
                      },
                    ),
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
                      onPressed: () {},
                    ),
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
                      onPressed: () {},
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
                      onPressed: () {
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
                      buildAnalysisTab(),
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
