// Dart & Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  String? monthDropdownValue;
  String? cloudDropdownValue;

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

  @override
  void initState() {
    super.initState();
    getStatusCardTotals();
    getUsageData();
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
                    items: ['July 2021', 'June 2021', 'May 2021'],
                    prompt: 'July 2021',
                    dropdownValue: monthDropdownValue,
                    onChanged: (newValue) {
                      setState(() {
                        monthDropdownValue = newValue!;
                      });
                    },
                  ),
                  SizedBox(width: 30.0),
                  MyDropdown(
                    items: ['24 July', '17 July', '10 July'],
                    prompt: 'View word cloud',
                    dropdownValue: null,
                    onChanged: (newValue) async {
                      setState(() {
                        cloudDropdownValue = newValue!;
                      });
                      await showDialog(
                        context: context,
                        builder: (_) => WordCloudDialog(newValue!),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: ScoreChart.withSampleData('Score 1', 0),
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: ScoreChart.withSampleData('Score 2', 1),
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: ScoreChart.withSampleData('Score 3', 2),
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: ScoreChart.withSampleData('WPM', 3),
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
