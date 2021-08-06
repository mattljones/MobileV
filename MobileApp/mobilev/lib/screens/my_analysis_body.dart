// Dart & Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// Module imports
import 'package:mobilev/models/recording.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/status_card.dart';
import 'package:mobilev/widgets/dropdown.dart';
import 'package:mobilev/widgets/chart_usage.dart';
import 'package:mobilev/widgets/chart_scores.dart';
import 'package:mobilev/widgets/word_cloud_dialog.dart';

class AnalysisBody extends StatefulWidget {
  @override
  _AnalysisBodyState createState() => _AnalysisBodyState();
}

class _AnalysisBodyState extends State<AnalysisBody>
    with SingleTickerProviderStateMixin {
  bool statusCardTotalsLoading = true;
  int? noRecordings;
  String? noMinutes;
  bool usageDataLoading = true;
  List? usageData;
  bool monthsLoading = true;
  Map<String, String>? activeMonths;
  bool cloudsLoading = true;
  Map? cloudData;
  bool activeScoresLoading = true;
  Map? activeScores;
  bool monthlyScoresLoading = true;
  Map? monthlyScores;
  String? monthDropdownValue;
  String? cloudDropdownValue;
  String? cloudFilePath;

  void getStatusCardTotals() {
    Recording.selectTotals().then((data) {
      setState(() {
        noRecordings = data['noRecordings'];
        noMinutes = data['noMinutes'];
        statusCardTotalsLoading = false;
      });
    });
  }

  void getUsageData() {
    Recording.selectUsage().then((data) {
      setState(() {
        usageData = data;
        usageDataLoading = false;
      });
    });
  }

  void getMonths() {
    Recording.selectMonths().then((data) {
      print('months');
      print(data);
      print('');
      setState(() {
        activeMonths = data;
        monthDropdownValue = activeMonths!.keys.first;
        monthsLoading = false;
      });
    });
  }

  void getWordClouds() {
    Recording.selectWordClouds().then((data) {
      print('wordclouds');
      print(data);
      print('');
      setState(() {
        cloudData = data;
        cloudsLoading = false;
      });
    });
  }

  void getActiveScores() {
    Recording.selectActiveScores().then((data) {
      print('activescores');
      print(data);
      print('');
      setState(() {
        activeScores = data;
        activeScoresLoading = false;
      });
    });
  }

  void getAnalysis() async {
    Recording.selectAnalysis().then((data) {
      print('analysis');
      print(data);
      print('');
      setState(() {
        monthlyScores = data;
        monthlyScoresLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Loading 'Usage' tab data
    getStatusCardTotals();
    getUsageData();
    // Loading 'Scores' tab data
    getMonths();
    getWordClouds();
    getActiveScores();
    getAnalysis();
  }

  Container buildUsageContent() => Container(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: StatusCard(
                        colour: kPrimaryColour,
                        label: '$noRecordings recordings',
                        icon: Icon(
                          Icons.mic,
                          color: Colors.white,
                        ),
                        iconFirst: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: StatusCard(
                        colour: kDarkAccentColour,
                        label: '$noMinutes minutes',
                        icon: Icon(
                          Icons.timer,
                          color: Colors.white,
                        ),
                        iconFirst: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: UsageChart(usageData!),
              ),
            ),
          ],
        ),
      );

  Container buildScoresContent() => Container(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyDropdown(
                    items: activeMonths!.keys.toList(),
                    prompt: activeMonths!.keys.first,
                    dropdownValue: monthDropdownValue,
                    onChanged: (newValue) {
                      setState(() {
                        monthDropdownValue = newValue!;
                        cloudDropdownValue = null;
                      });
                    },
                  ),
                  SizedBox(width: 30.0),
                  MyDropdown(
                    items: cloudData!.keys
                            .contains(activeMonths![monthDropdownValue])
                        ? List.generate(
                            cloudData![activeMonths![monthDropdownValue]]
                                .length,
                            (index) =>
                                cloudData![activeMonths![monthDropdownValue]]
                                    [index]['day'])
                        : [],
                    prompt: cloudData!.keys
                            .contains(activeMonths![monthDropdownValue])
                        ? 'View word cloud'
                        : 'No word clouds',
                    dropdownValue: cloudDropdownValue,
                    onChanged: (newValue) async {
                      String? filePath;
                      for (var cloud
                          in cloudData![activeMonths![monthDropdownValue]]) {
                        if (cloud['day'] == newValue) {
                          filePath = cloud['filePath'];
                        }
                      }
                      setState(() {
                        cloudDropdownValue = newValue!;
                        cloudFilePath = filePath;
                      });
                      String absPath = path.join(
                          (await getApplicationDocumentsDirectory()).path,
                          cloudFilePath);
                      await showDialog(
                        context: context,
                        builder: (_) => WordCloudDialog(
                          date: cloudDropdownValue!.split(' (')[0],
                          filePath: absPath,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: int.parse(
                  (24 / (activeScores!.keys.length + 1)).toStringAsFixed(0)),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: ScoreChart(
                  chartData: monthlyScores![months[monthDropdownValue]]['wpm'],
                  axisTitle: 'WPM',
                  index: 0,
                ),
              ),
            ),
            for (var i = 0; i < activeScores!.keys.length; i++)
              Expanded(
                flex: int.parse(
                    (24 / (activeScores!.keys.length + 1)).toStringAsFixed(0)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.0),
                  child: ScoreChart.withSampleData(
                      activeScores!.values.toList()[i], i + 1),
                ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: TabBar(
                indicatorColor: kPrimaryColour,
                tabs: [
                  Tab(text: 'USAGE'),
                  Tab(text: 'SCORES'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  if (statusCardTotalsLoading || usageDataLoading)
                    Center(
                      child: SpinKitRing(
                        color: kSecondaryTextColour,
                        size: 24.0,
                        lineWidth: 3.0,
                      ),
                    )
                  else
                    buildUsageContent(),
                  if (monthsLoading ||
                      cloudsLoading ||
                      activeScoresLoading ||
                      monthlyScoresLoading)
                    Center(
                      child: SpinKitRing(
                        color: kSecondaryTextColour,
                        size: 24.0,
                        lineWidth: 3.0,
                      ),
                    )
                  else
                    buildScoresContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
