import 'package:flutter/material.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/status_card.dart';
import 'package:mobilev/widgets/chart_usage.dart';

class AnalysisBody extends StatefulWidget {
  @override
  _AnalysisBodyState createState() => _AnalysisBodyState();
}

class _AnalysisBodyState extends State<AnalysisBody>
    with SingleTickerProviderStateMixin {
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
                        label: '25 recordings',
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
                        label: '38 minutes',
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
              child: BarChartWithSecondaryAxis.withSampleData(),
            ),
          ],
        ),
      );

  Container buildScoresContent() => Container(
        child: Column(
          children: [Text('Hello2')],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 40.0),
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
                    buildUsageContent(),
                    buildScoresContent(),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
