// Dart & Flutter imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/models/recording.dart';
import 'package:mobilev/config/constants.dart';
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

  @override
  void initState() {
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    getMostRecentData();
    getMonthlyData();
    getMonths();
  }

  @mustCallSuper
  @protected
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    getMostRecentData();
    getMonthlyData();
    getMonths();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  void getMostRecentData() {
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
