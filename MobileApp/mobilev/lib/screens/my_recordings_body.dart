// Dart & Flutter imports
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// Module imports
import 'package:mobilev/models/recording.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/services/network_service.dart';
import 'package:mobilev/widgets/recording_card.dart';
import 'package:mobilev/widgets/dropdown.dart';

class RecordingsBody extends StatefulWidget {
  @override
  _RecordingsBodyState createState() => _RecordingsBodyState();
}

class _RecordingsBodyState extends State<RecordingsBody>
    with SingleTickerProviderStateMixin {
  String? dropdownValue;
  TabController? _tabController;
  ScrollController? _scrollController;
  bool scoresLoading = true;
  Map? scores;
  bool mostRecentLoading = true;
  List? mostRecentData;
  bool monthlyLoading = true;
  Map? monthlyData;
  bool monthsLoading = true;
  Map<String, String>? months;
  bool isPolling = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    getMostRecentData();
    getMonthlyData();
    getMonths();
    pollForAnalysis();
  }

  @mustCallSuper
  @protected
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    getMostRecentData();
    getMonthlyData();
    getMonths();
    pollForAnalysis();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  void getMostRecentData() async {
    Recording.selectMostRecent().then((data) {
      setState(() {
        mostRecentData = data;
        mostRecentLoading = false;
      });
    });
  }

  void getMonthlyData() {
    Recording.selectByMonth().then((data) {
      setState(() {
        monthlyData = data;
        monthlyLoading = false;
      });
    });
  }

  void getMonths() {
    Recording.selectMonths().then((data) {
      setState(() {
        months = data;
        dropdownValue = months!.keys.isNotEmpty ? months!.keys.first : null;
        monthsLoading = false;
      });
    });
  }

  // Helper function to update a recording's file name in DB & memory
  Future<String> updateAudioFileName(String oldPath, String wpm) async {
    // Construct new audio file name
    String newPath =
        oldPath.substring(0, oldPath.length - 4) + '_WPM_$wpm' + '.m4a';

    // Update audio file name saved in memory
    String directoryPath = (await getApplicationDocumentsDirectory()).path;
    File audio = File(path.join(directoryPath, oldPath));
    audio.renameSync(path.join(directoryPath, newPath));

    return newPath;
  }

  // Helper function to create a new word cloud's file name
  String constructCloudFileName(String oldAudioPath, String wpm) {
    // Construct word cloud file path based on old audio file path
    String cloudPath = oldAudioPath.substring(0, 20) +
        'WordCloud' +
        oldAudioPath.substring(25, oldAudioPath.length - 4) +
        '_WPM_$wpm' +
        '.png';

    return cloudPath;
  }

  // Helper function to save a new word cloud
  Future<void> saveWordCloud(String base64string, String filePath) async {
    // Decode string
    Uint8List bytes = base64.decode(base64string);
    // Save file
    String directoryPath = (await getApplicationDocumentsDirectory()).path;
    File cloudFile = File(path.join(directoryPath, filePath));
    await cloudFile.writeAsBytes(bytes);
  }

  // Helper function to poll the API for pending analysis
  void pollForAnalysis() async {
    setState(() => isPolling = true);
    // Load a list of recordings pending analysis (oldest at beginning of list)
    var pendingRecordings = await Recording.selectPending();

    // Cycle through all recordings pending analysis
    for (int i = 0; i < pendingRecordings.length; i++) {
      String dateRecorded = pendingRecordings[i]['dateRecorded'];
      bool complete = false;
      // Continue polling for the given recording until its status is resolved
      while (complete == false) {
        await Future.delayed(Duration(seconds: 5)).then((value) async {
          var response = await NetworkService.downloadAnalysis(dateRecorded);
          // In case of an error connecting with the API, try again
          if (response == false) {
            complete = false;
          }
          // Otherwise, examine the JSON response
          else {
            // Try again if analysis not yet ready
            if (response['status'] == 'incomplete') {
              complete = false;
            }
            // If an error occurred during transcription, signal this
            else if (response['status'] == 'failed') {
              var newFields = {
                'isShared': 0,
                'analysisStatus': 'failed',
              };
              await Recording.updateRecording(
                dateRecorded: dateRecorded,
                newFields: newFields,
              );
              // Continue to next recording & update page
              complete = true;
              getMostRecentData();
              getMonthlyData();
              getMonths();
            }
            // If the analysis was successful, save as appropriate
            else if (response['status'] == 'success') {
              // If transcription wasn't completed, update database only
              if (response['transcript'] == '') {
                var newFields = {
                  'isShared': 1,
                  'analysisStatus': 'received',
                  'wpm': int.parse(response['WPM']),
                  'audioFilePath': await updateAudioFileName(
                      pendingRecordings[i]['audioFilePath'], response['WPM']),
                };
                await Recording.updateRecording(
                  dateRecorded: dateRecorded,
                  newFields: newFields,
                );
              }
              // If transcription was completed, update DB & save word cloud
              else {
                // Save word cloud
                String wordCloudFilePath = constructCloudFileName(
                    pendingRecordings[i]['audioFilePath'], response['WPM']);
                saveWordCloud(response['wordCloud'], wordCloudFilePath);
                // Update recording
                var newFields = {
                  'analysisStatus': 'received',
                  'wpm': int.parse(response['WPM']),
                  'transcript': response['transcript'],
                  'audioFilePath': await updateAudioFileName(
                      pendingRecordings[i]['audioFilePath'], response['WPM']),
                  'wordCloudFilePath': wordCloudFilePath,
                };
                await Recording.updateRecording(
                  dateRecorded: dateRecorded,
                  newFields: newFields,
                );
              }
              // Continue to next recording & update page
              complete = true;
              getMostRecentData();
              getMonthlyData();
              getMonths();
            }
          }
        });
      }
    }
    setState(() => isPolling = false);
  }

  // Helper callback function for updating the screen after a recording is edited or deleted
  void updateRecordingsScreen(int type) {
    if (type == 1) {
      final snackBar = SnackBar(
        backgroundColor: kSecondaryTextColour,
        content: Text('Recording updated'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (type == 2) {
      final snackBar = SnackBar(
        backgroundColor: kSecondaryTextColour,
        content: Text('Recording updated & shared'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      if (!isPolling) {
        pollForAnalysis(); // Start polling the API for the analysis
      }
    } else if (type == 3) {
      final snackBar = SnackBar(
        backgroundColor: kSecondaryTextColour,
        content: Text('Unable to share recording. Please try again.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (type == 4) {
      final snackBar = SnackBar(
        backgroundColor: kSecondaryTextColour,
        content:
            Text('Please wait to receive analysis before sharing an update'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (type == 5) {
      final snackBar = SnackBar(
        backgroundColor: kSecondaryTextColour,
        content: Text('Recording deleted'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    getMostRecentData();
    getMonthlyData();
    getMonths();
  }

  Container loadMostRecentContent() => Container(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: ListView(
            children: [
              // If data still loading, show nothing
              if (mostRecentLoading)
                Text('')
              // If no recordings have been made, show prompt message
              else if (mostRecentData!.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 18,
                          color: kSecondaryTextColour,
                          fontFamily: 'PTSans',
                        ),
                        children: [
                          TextSpan(text: 'Press the '),
                          TextSpan(
                              text: 'button',
                              style: TextStyle(color: kDarkAccentColour)),
                          TextSpan(text: ' to make a recording'),
                        ],
                      ),
                    ),
                  ),
                )
              // Otherwise, show data
              else
                Column(
                  children: [
                    for (var recording in mostRecentData!)
                      RecordingCard(
                        dateRecorded: recording['dateRecorded'],
                        date: recording['date'],
                        type: recording['type'],
                        duration: recording['duration'],
                        audioFilePath: recording['audioFilePath'],
                        scores: Map.from(recording['scores']),
                        isShared: recording['isShared'] == 1 ? true : false,
                        analysisStatus:
                            analysisStatus[recording['analysisStatus']]!,
                        wpm: recording['wpm'],
                        transcript: recording['transcript'],
                        wordCloudFilePath: recording['wordCloudFilePath'],
                        updateRecordingsScreen: updateRecordingsScreen,
                      ),
                    SizedBox(height: 20.0),
                  ],
                ),
            ],
          ),
        ),
      );

  Container loadByMonthContent() => Container(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: ListView(
            children: [
              // If data is loading, show nothing
              if (monthsLoading || monthlyLoading)
                Text('')
              // If no recordings have been made, show text prompt
              else if (monthlyData!.isEmpty || months!.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 18,
                          color: kSecondaryTextColour,
                          fontFamily: 'PTSans',
                        ),
                        children: [
                          TextSpan(text: 'Press the '),
                          TextSpan(
                              text: 'button',
                              style: TextStyle(color: kDarkAccentColour)),
                          TextSpan(text: ' to make a recording'),
                        ],
                      ),
                    ),
                  ),
                )
              // Otherwise show specified month's recording data
              else
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: MyDropdown(
                        items: months!.keys.toList(),
                        prompt:
                            months!.keys.isNotEmpty ? months!.keys.first : '',
                        dropdownValue: dropdownValue,
                        onChanged: (newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                      ),
                    ),
                    for (var recording in monthlyData![months![dropdownValue]]!)
                      RecordingCard(
                        dateRecorded: recording['dateRecorded'],
                        date: recording['date'],
                        type: recording['type'],
                        duration: recording['duration'],
                        audioFilePath: recording['audioFilePath'],
                        scores: Map.from(recording['scores']),
                        isShared: recording['isShared'] == 1 ? true : false,
                        analysisStatus:
                            analysisStatus[recording['analysisStatus']]!,
                        wpm: recording['wpm'],
                        transcript: recording['transcript'],
                        wordCloudFilePath: recording['wordCloudFilePath'],
                        updateRecordingsScreen: updateRecordingsScreen,
                      ),
                    SizedBox(height: 20.0),
                  ],
                ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
      child: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, value) {
          return [
            SliverToBoxAdapter(
              child: TabBar(
                controller: _tabController,
                indicatorColor: kPrimaryColour,
                tabs: [
                  Tab(text: 'MOST RECENT'),
                  Tab(text: 'BY MONTH'),
                ],
              ),
            )
          ];
        },
        body: Container(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              loadMostRecentContent(),
              loadByMonthContent(),
            ],
          ),
        ),
      ),
    );
  }
}
