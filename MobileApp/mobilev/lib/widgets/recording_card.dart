// Dart & Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/screens/view_recording.dart';
import 'package:mobilev/widgets/status_card.dart';
import 'package:mobilev/widgets/recording_card_score.dart';

class RecordingCard extends StatefulWidget {
  final String dateRecorded;
  final String date;
  final String type;
  final int duration;
  final String audioFilePath;
  final Map scores;
  final bool isShared;
  final AnalysisStatus analysisStatus;
  final int? wpm;
  final String? transcript;
  final String? wordCloudFilePath;
  final void Function(int) updateRecordingsScreen;

  RecordingCard(
      {required this.dateRecorded,
      required this.date,
      required this.type,
      required this.duration,
      required this.audioFilePath,
      required this.analysisStatus,
      required this.scores,
      required this.isShared,
      required this.wpm,
      required this.transcript,
      required this.wordCloudFilePath,
      required this.updateRecordingsScreen});

  @override
  _RecordingCardState createState() => _RecordingCardState();
}

class _RecordingCardState extends State<RecordingCard> {
  static String expansionTitle = 'View scores';

  // Constructs scores in the correct format for the card
  List<Widget> constructScores() {
    List<Widget> list = [];
    if (widget.wpm != null) {
      list.add(
        RecordingCardScore(scoreName: 'WPM', scoreValue: widget.wpm!),
      );
      list.add(
        SizedBox(height: 10.0),
      );
    }
    widget.scores.forEach((key, value) {
      list.add(
        RecordingCardScore(scoreName: value[0], scoreValue: value[1]),
      );
      list.add(
        SizedBox(height: 10.0),
      );
    });
    return list;
  }

  // Function to pass data to/load the view recording screen on tap
  void loadViewRecordingScreen(BuildContext context) async {
    String directoryPath = (await getApplicationDocumentsDirectory()).path;
    String audioAbsPath = join(directoryPath, widget.audioFilePath);
    String? cloudAbsPath = widget.wordCloudFilePath != null
        ? join(directoryPath, widget.wordCloudFilePath)
        : null;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ViewRecordingScreen(
          dateRecorded: widget.dateRecorded,
          type: widget.type,
          duration: widget.duration,
          audioPath: audioAbsPath,
          wpm: widget.wpm,
          scores: widget.scores,
          wordCloudPath: cloudAbsPath,
          transcript: widget.transcript,
        );
      }),
    ).then((value) {
      // Refresh data on main page if an update was made
      if (value != null && value == 1) {
        widget.updateRecordingsScreen(1); // Saved
      } else if (value != null && value == 2) {
        widget.updateRecordingsScreen(2); // Saved & shared
      } else if (value != null && value == 3) {
        widget.updateRecordingsScreen(3); // Deleted
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kCardColour,
      elevation: 6.0,
      margin: EdgeInsets.fromLTRB(4.0, 20.0, 4.0, 0.0),
      child: Container(
        padding: EdgeInsets.fromLTRB(
            15.0, 15.0, 15.0, widget.scores.isNotEmpty ? 0.0 : 15.0),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                loadViewRecordingScreen(context);
              },
              // Top row of card
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.date,
                    style: TextStyle(
                      color: kPrimaryColour,
                      fontSize: 22.0,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Roboto',
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: widget.type,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: '  |  ${widget.duration}s',
                          style: TextStyle(fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                loadViewRecordingScreen(context);
              },
              child: SizedBox(height: 15.0),
            ),
            // Middle row of card
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                loadViewRecordingScreen(context);
              },
              child: Row(
                children: [
                  widget.isShared
                      ? StatusCard(
                          colour: Colors.green,
                          label: 'Shared',
                          icon: Icon(
                            Icons.check_box_outlined,
                            color: Colors.white,
                          ),
                          iconFirst: false,
                        )
                      : StatusCard(
                          colour: kSecondaryTextColour,
                          label: 'Not shared',
                          icon: Icon(
                            Icons.disabled_by_default_outlined,
                            color: Colors.white,
                          ),
                          iconFirst: false,
                        ),
                  SizedBox(width: 10.0),
                  if (widget.analysisStatus == AnalysisStatus.pending)
                    StatusCard(
                      colour: Colors.orange,
                      label: 'Analysis pending',
                      icon: SpinKitWave(
                        type: SpinKitWaveType.center,
                        color: Colors.white,
                        size: 19.7,
                        itemCount: 7,
                        // lineWidth: 3.0,
                      ),
                      iconFirst: false,
                    )
                  else if (widget.analysisStatus == AnalysisStatus.received)
                    StatusCard(
                      colour: Colors.green,
                      label: 'Analysis received',
                      icon: Icon(
                        Icons.check_box_outlined,
                        color: Colors.white,
                      ),
                      iconFirst: false,
                    )
                  else if (widget.analysisStatus == AnalysisStatus.failed)
                    StatusCard(
                      colour: Colors.red,
                      label: 'Analysis failed',
                      icon: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                      ),
                      iconFirst: false,
                    ),
                ],
              ),
            ),
            SizedBox(width: 10.0),
            // Bottom row of card (scores expandable widget)
            if (widget.scores.isNotEmpty)
              ExpansionTile(
                textColor: Colors.black,
                iconColor: Colors.black,
                tilePadding: EdgeInsets.fromLTRB(10.0, 0.0, 160.0, 0.0),
                childrenPadding: EdgeInsets.only(left: 20.0),
                title: Text(expansionTitle),
                onExpansionChanged: (isExpanded) {
                  setState(() {
                    isExpanded
                        ? expansionTitle = 'Hide scores'
                        : expansionTitle = 'View scores';
                  });
                },
                children: constructScores(),
              ),
          ],
        ),
      ),
    );
  }
}
