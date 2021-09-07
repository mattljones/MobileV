// Package imports
import 'package:flutter_test/flutter_test.dart';

// Module imports
import 'package:mobilev/models/recording.dart';

void recordingUnitTests() async {
  // Recording.toMap()
  test('Test converting Recording to Map', () {
    final recording = Recording(
      dateRecorded: 'date',
      type: 'type',
      duration: 30,
      audioFilePath: 'audioPath',
      isShared: 1,
      analysisStatus: 'received',
    );
    final mapped = recording.toMap();
    final expected = {
      'dateRecorded': 'date',
      'type': 'type',
      'duration': 30,
      'audioFilePath': 'audioPath',
      'score1ID': null,
      'score1Value': null,
      'score2ID': null,
      'score2Value': null,
      'score3ID': null,
      'score3Value': null,
      'isShared': 1,
      'analysisStatus': 'received',
      'wpm': null,
      'transcript': null,
      'wordCloudFilePath': null,
    };
    expect(mapped, equals(expected));
  });

  // Recording.roundMinutes()
  test('Test converting seconds to minutes with correct no. of dp.', () {
    final rounded1 = Recording.roundMinutes(120);
    expect(rounded1, '2');
    final rounded2 = Recording.roundMinutes(30);
    expect(rounded2, '0.5');
  });

  // Recording.insertRecording()
  test('Test inserting a recording', () async {
    final newRecording = Recording(
      dateRecorded: 'date',
      type: 'type',
      duration: 30,
      audioFilePath: 'audioPath',
      isShared: 1,
      analysisStatus: 'received',
    );
    await Recording.insertRecording(newRecording);
  });

  // Recording.updateRecording()
  test('Test updating a recording', () async {
    final date = 'date';
    final newFields = {
      'isShared': 0,
    };
    await Recording.updateRecording(
      dateRecorded: date,
      newFields: newFields,
    );
  });

  // Recording.deleteRecording()
  test('Test deleting a recording', () async {
    final date = 'date';
    await Recording.deleteRecording(date);
  });

  // Recording.selectPending()
  test('Test selecting a list of pending recordings (for polling)', () async {
    final data = await Recording.selectPending();
    final expected = [];
    expect(data, equals(expected));
  });

  // Recording.selectMostRecent()
  test('Test selecting the most recent recordings (for the splash screen)',
      () async {
    final data = (await Recording.selectMostRecent())[0];
    final expected = {
      'date': '12/08/2021',
      'dateRecorded': '2021-08-12 12:00:00',
      'type': 'Text',
      'duration': 60,
      'audioFilePath': 'test2.m4a',
      'score1ID': 1,
      'score1Value': 8,
      'score2ID': 2,
      'score2Value': 7,
      'score3ID': 3,
      'score3Value': 3120,
      'isShared': 1,
      'analysisStatus': 'received',
      'wpm': 60,
      'transcript': 'Lorem ipsum...',
      'wordCloudFilePath': 'test2.jpg',
      'scores': {
        1: ['Wellbeing', 8],
        2: ['GAD7', 7],
        3: ['Steps', 3120]
      }
    };
    expect(data, equals(expected));
  });

  // Recording.selectByMonth()
  test('Test selecting all recordings grouped by month', () async {
    final data = (await Recording.selectByMonth())['08-2021'];
    final expected = [
      {
        'month': '08-2021',
        'date': '12/08/2021',
        'dateRecorded': '2021-08-12 12:00:00',
        'type': 'Text',
        'duration': 60,
        'audioFilePath': 'test2.m4a',
        'score1ID': 1,
        'score1Value': 8,
        'score2ID': 2,
        'score2Value': 7,
        'score3ID': 3,
        'score3Value': 3120,
        'isShared': 1,
        'analysisStatus': 'received',
        'wpm': 60,
        'transcript': 'Lorem ipsum...',
        'wordCloudFilePath': 'test2.jpg',
        'scores': {
          1: ['Wellbeing', 8],
          2: ['GAD7', 7],
          3: ['Steps', 3120]
        }
      },
      {
        'month': '08-2021',
        'date': '04/08/2021',
        'dateRecorded': '2021-08-04 12:00:00',
        'type': 'Numeric',
        'duration': 120,
        'audioFilePath': 'test1.m4a',
        'score1ID': 1,
        'score1Value': 5,
        'score2ID': 2,
        'score2Value': 8,
        'score3ID': 3,
        'score3Value': 2560,
        'isShared': 1,
        'analysisStatus': 'received',
        'wpm': 55,
        'transcript': null,
        'wordCloudFilePath': null,
        'scores': {
          1: ['Wellbeing', 5],
          2: ['GAD7', 8],
          3: ['Steps', 2560]
        }
      }
    ];
    expect(data, equals(expected));
  });

  // Recording.selectMonths()
  test('Test selecting a list of months for which have recordings', () async {
    final data = await Recording.selectMonths();
    final expected = {
      'Aug 2021': '08-2021',
      'Jul 2021': '07-2021',
      'Jun 2021': '06-2021',
      'May 2021': '05-2021',
      'Dec 2020': '12-2020'
    };
    expect(data, equals(expected));
  });

  // Recording.selectTotals()
  test('Test selecting overall total number of recordings & minutes', () async {
    final data = await Recording.selectTotals();
    final expected = {
      'noRecordings': 20,
      'noMinutes': '22.5',
    };
    expect(data, equals(expected));
  });

  // Recording.selectUsage()
  test('Test selecting data for analysis "usage" chart', () async {
    final data = await Recording.selectUsage();
    final expected = [
      {'month': 'Jun', 'noRecordings': 5, 'noMinutes': 330},
      {'month': 'Jul', 'noRecordings': 7, 'noMinutes': 480},
      {'month': 'Aug', 'noRecordings': 2, 'noMinutes': 180}
    ];
    expect(data, equals(expected));
  });

  // Recording.selectWordClouds()
  test('Test selecting clouds per month (avoiding name clashes)', () async {
    final data = (await Recording.selectWordClouds())['07-2021'];
    final expected = [
      {'day': '31 Jul', 'filePath': 'test1.jpg'},
      {'day': '31 Jul (2)', 'filePath': 'test2.jpg'},
      {'day': '04 Jul', 'filePath': 'test2.jpg'}
    ];
    expect(data, equals(expected));
  });

  // Recording.selectAnalysis()
  test('Test selecting score analysis per month', () async {
    final data = (await Recording.selectAnalysis())['08-2021'];
    final expected = {
      1: [
        {'day': 4, 'score': 5, 'type': 'Numeric'},
        {'day': 12, 'score': 8, 'type': 'Text'}
      ],
      2: [
        {'day': 4, 'score': 8, 'type': 'Numeric'},
        {'day': 12, 'score': 7, 'type': 'Text'}
      ],
      3: [
        {'day': 4, 'score': 2560, 'type': 'Numeric'},
        {'day': 12, 'score': 3120, 'type': 'Text'}
      ],
      'wpm': [
        {'day': 4, 'score': 55, 'type': 'Numeric'},
        {'day': 12, 'score': 60, 'type': 'Text'}
      ]
    };
    expect(data, equals(expected));
  });
}
