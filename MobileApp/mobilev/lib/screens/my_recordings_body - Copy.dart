import 'package:flutter/material.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/recording_card.dart';
import 'package:mobilev/widgets/month_dropdown.dart';

class RecordingsBody extends StatefulWidget {
  @override
  _RecordingsBodyState createState() => _RecordingsBodyState();
}

class _RecordingsBodyState extends State<RecordingsBody> {
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 20.0),
        child: DefaultTabController(
          length: 2,
          initialIndex: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBar(
                indicatorColor: kPrimaryColour,
                tabs: [
                  Tab(text: 'MOST RECENT'),
                  Tab(text: 'BY MONTH'),
                ],
              ),
              Container(
                height: 680.0,
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Column(
                      children: [
                        RecordingCard(
                          dateRecorded: '24/07/2021',
                          type: 'Test',
                          duration: 60,
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
                          type: 'Test',
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
                          type: 'Test',
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
                          dateRecorded: '03/07/2021',
                          type: 'Test',
                          duration: 60,
                          isShared: true,
                          analysisStatus: AnalysisStatus.received,
                          scores: {},
                        ),
                      ],
                    ),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 10.0),
                            child: MonthDropdown(
                              months: ['July 2021', 'June 2021', 'May 2021'],
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
                            type: 'Test',
                            duration: 60,
                            isShared: true,
                            analysisStatus: AnalysisStatus.pending,
                            scores: {
                              'ScoreName 1': 30,
                              'ScoreName 2': 60,
                              'ScoreName 3': 45,
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
