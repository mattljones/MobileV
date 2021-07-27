import 'package:flutter/material.dart';
import 'package:mobilev/widgets/recording_card.dart';

class RecordingsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
      ),
    );
  }
}
