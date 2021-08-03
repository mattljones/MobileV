// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
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

  @override
  void initState() {
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  Container loadMostRecentContent() => Container(
        child: ListView(
          children: [
            RecordingCard(
              dateRecorded: '24/07/2021',
              type: 'Text',
              duration: 120,
              isShared: true,
              analysisStatus: AnalysisStatus.pending,
              scores: {
                'ScoreName 1': 30,
                'ScoreName 2': 60,
                'ScoreName 3': 45,
              },
            ),
            RecordingCard(
              dateRecorded: '17/07/2021',
              type: 'Numeric',
              duration: 60,
              isShared: true,
              analysisStatus: AnalysisStatus.received,
              scores: {
                'WPM': 67,
                'ScoreName 1': 30,
                'ScoreName 2': 60,
                'ScoreName 3': 45,
              },
            ),
            RecordingCard(
              dateRecorded: '10/07/2021',
              type: 'Text',
              duration: 120,
              isShared: true,
              analysisStatus: AnalysisStatus.received,
              scores: {
                'WPM': 67,
                'ScoreName 1': 30,
                'ScoreName 2': 60,
                'ScoreName 3': 45,
              },
            ),
            RecordingCard(
              dateRecorded: '03/07/2021',
              type: 'Numeric',
              duration: 60,
              isShared: true,
              analysisStatus: AnalysisStatus.received,
              scores: {},
            ),
            SizedBox(height: 20.0),
          ],
        ),
      );

  Container loadByMonthContent() => Container(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: MyDropdown(
                items: ['July 2021', 'June 2021', 'May 2021'],
                prompt: 'Select month',
                dropdownValue: dropdownValue,
                onChanged: (newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
              ),
            ),
            RecordingCard(
              dateRecorded: '24/07/2021',
              type: 'Numeric',
              duration: 60,
              isShared: true,
              analysisStatus: AnalysisStatus.pending,
              scores: {
                'ScoreName 1': 30,
                'ScoreName 2': 60,
                'ScoreName 3': 45,
              },
            ),
            SizedBox(height: 20.0),
          ],
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
