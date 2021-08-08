// Module imports
import 'package:mobilev/services/database_service.dart';
import 'package:mobilev/models/score.dart';
import 'package:mobilev/config/constants.dart';

class Recording {
  final String dateRecorded;
  final String type;
  final int duration;
  final String audioFilePath;
  final int? score1ID;
  final int? score1Value;
  final int? score2ID;
  final int? score2Value;
  final int? score3ID;
  final int? score3Value;
  final int isShared;
  final String analysisStatus;
  final int? wpm;
  final String? transcript;
  final String? wordCloudFilePath;

  Recording({
    required this.dateRecorded,
    required this.type,
    required this.duration,
    required this.audioFilePath,
    this.score1ID,
    this.score1Value,
    this.score2ID,
    this.score2Value,
    this.score3ID,
    this.score3Value,
    required this.isShared,
    required this.analysisStatus,
    this.wpm,
    this.transcript,
    this.wordCloudFilePath,
  });

  // Helper functions ----------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'dateRecorded': dateRecorded,
      'type': type,
      'duration': duration,
      'audioFilePath': audioFilePath,
      'score1ID': score1ID,
      'score1Value': score1Value,
      'score2ID': score2ID,
      'score2Value': score2Value,
      'score3ID': score3ID,
      'score3Value': score3Value,
      'isShared': isShared,
      'analysisStatus': analysisStatus,
      'wpm': wpm,
      'transcript': transcript,
      'wordCloudFilePath': wordCloudFilePath,
    };
  }

  // Useful for development
  @override
  String toString() {
    return '''
      Recording(
        dateRecorded: $dateRecorded,
        type: $type,
        duration: $duration,
        audioFilePath: $audioFilePath,
        score1ID: $score1ID,
        score1Value: $score1Value,
        score2ID: $score2ID,
        score2Value: $score2Value,
        score3ID: $score3ID,
        score3Value: $score3Value,
        isShared: $isShared,
        analysisStatus: $analysisStatus,
        wpm: $wpm,
        transcript: $transcript,
        wordCloudFilePath: $wordCloudFilePath
      )''';
  }

  static String roundMinutes(int seconds) {
    var remainder = seconds.remainder(60);
    return remainder == 0
        ? (seconds / 60).toStringAsFixed(0)
        : (seconds / 60).toStringAsFixed(1);
  }

  // Queries -------------------------------------------------------------------

  // Insert a new recording
  static Future<void> insertRecording(Recording recording) async {
    final db = databaseService.db;
    await db!.insert(
      'Recording',
      recording.toMap(),
    );
  }

  // Update one (by domain)
  static Future<void> updateRecording(Recording recording) async {
    final db = databaseService.db;
    await db!.update(
      'Recording',
      recording.toMap(),
      where: 'dateRecorded = ?',
      whereArgs: [recording.dateRecorded],
    );
  }

  // Select most recent recordings
  static Future<List<dynamic>> selectMostRecent() async {
    final db = databaseService.db;
    final scores = await Score.selectAllScores();
    final List<Map<String, dynamic>> list = await db!.rawQuery('''
      SELECT strftime('%d/%m/%Y', dateRecorded) AS date, *
      FROM Recording
      ORDER BY dateRecorded DESC
      LIMIT 8
      ''');

    var output = [];

    for (var index = 0; index < list.length; index++) {
      var recording = Map.from(list[index]);
      var recScores = {};
      if (recording['wpm'] != null) {
        recScores['WPM'] = recording['wpm'];
      }
      for (var i in [1, 2, 3]) {
        if (recording['score${i}ID'] != null) {
          recScores[scores[recording['score${i}ID']]] =
              recording['score${i}Value'];
        }
      }
      recording['scores'] = recScores;
      output.add(recording);
    }

    print(output);
    return output;
  }

  // Select all recordings, grouped by month
  static Future<Map<dynamic, List>> selectByMonth() async {
    final db = databaseService.db;
    final scores = await Score.selectAllScores();
    final List months = (await selectMonths()).values.toList();
    final List<Map<String, dynamic>> list = await db!.rawQuery('''
      SELECT strftime('%m-%Y', dateRecorded) as month, strftime('%d/%m/%Y', dateRecorded) AS date, *
      FROM Recording
      ORDER BY dateRecorded DESC
      ''');

    var output = Map.fromIterable(
      months,
      key: (item) => item,
      value: (item) => [],
    );

    for (var index = 0; index < list.length; index++) {
      var recording = Map.from(list[index]);
      var recScores = {};
      if (recording['wpm'] != null) {
        recScores['WPM'] = recording['wpm'];
      }
      for (var i in [1, 2, 3]) {
        if (recording['score${i}ID'] != null) {
          recScores[scores[recording['score${i}ID']]] =
              recording['score${i}Value'];
        }
      }
      recording['scores'] = recScores;
      output[recording['month']]!.add(recording);
    }

    return output;
  }

  // Select list of months for which have recordings
  static Future<Map<String, String>> selectMonths() async {
    final db = databaseService.db;
    final List<Map<String, dynamic>> list = await db!.rawQuery('''
      SELECT DISTINCT strftime('%m-%Y', dateRecorded) AS month
      FROM Recording
      ORDER BY date(dateRecorded) DESC
      ''');

    return Map<String, String>.fromIterable(
      list,
      key: (item) =>
          months[item['month'].substring(0, 2)]! +
          ' ' +
          item['month'].substring(3),
      value: (item) => item['month'],
    );
  }

  // Select total number of recordings and minutes
  static Future<Map<String, dynamic>> selectTotals() async {
    final db = databaseService.db;
    final Map<String, dynamic> totals = (await db!.rawQuery('''
      SELECT COUNT(DISTINCT dateRecorded) AS noRecordings, SUM(duration) AS noSeconds 
      FROM Recording;
      '''))[0];

    return {
      'noRecordings': totals['noRecordings'],
      'noMinutes':
          totals['noSeconds'] != null ? roundMinutes(totals['noSeconds']) : '0',
    };
  }

  // Select total usage
  static Future<List<Map<String, dynamic>>> selectUsage() async {
    final db = databaseService.db;
    final List<Map<String, dynamic>> list = await db!.rawQuery('''
      SELECT strftime('%m', dateRecorded) AS month, COUNT(DISTINCT dateRecorded) AS noRecordings, SUM(duration) AS noSeconds
      FROM Recording
      WHERE dateRecorded >= date('now', 'start of month', '-3 months')
      GROUP BY month
      ORDER BY strftime('%Y', dateRecorded) ASC, month ASC
      ''');

    return List.generate(list.length, (i) {
      int? noSeconds = list[i]['noSeconds'];
      return {
        'month': months[list[i]['month']],
        'noRecordings': list[i]['noRecordings'],
        'noMinutes': noSeconds != null
            ? int.parse((noSeconds / 60).toStringAsFixed(0))
            : 0,
      };
    });
  }

  // Select word clouds per month for which have recordings
  static Future<Map<dynamic, dynamic>> selectWordClouds() async {
    final db = databaseService.db;
    final List<Map<String, dynamic>> list = await db!.rawQuery('''
      SELECT strftime('%d-%m-%Y', dateRecorded) AS date, wordCloudFilePath
      FROM Recording
      WHERE wordCloudFilePath IS NOT NULL 
      ORDER BY date(dateRecorded) DESC
      ''');

    var output = {};
    for (var wordCloud in list) {
      String date = wordCloud['date'];
      String month = date.substring(3);

      if (output.keys.contains(month)) {
        int count = 1;
        for (var wordCloud in output[month]) {
          if ((wordCloud['day']) ==
              date.substring(0, 2) + ' ' + months[date.substring(3, 5)]!) {
            count++;
          }
        }
        String? day;
        if (count > 1) {
          day = date.substring(0, 2) +
              ' ' +
              months[date.substring(3, 5)]! +
              ' ($count)';
        } else {
          day = date.substring(0, 2) + ' ' + months[date.substring(3, 5)]!;
        }
        output[month].add(
          {'day': day, 'filePath': wordCloud['wordCloudFilePath']},
        );
      } else {
        String day = date.substring(0, 2) + ' ' + months[date.substring(3, 5)]!;
        output[month] = [
          {'day': day, 'filePath': wordCloud['wordCloudFilePath']},
        ];
      }
    }

    return output;
  }

  // Select score analysis for active months
  static Future<Map<dynamic, dynamic>> selectAnalysis() async {
    final db = databaseService.db;
    final List months = (await selectMonths()).values.toList();
    final Map activeScores = await Score.selectActiveScores();
    final List scores = [...activeScores.keys, 'wpm'];

    final List<Map<String, dynamic>> list = await db!.rawQuery('''
        SELECT strftime('%d-%m-%Y', dateRecorded) AS date, type, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, wpm
        FROM Recording
        GROUP BY date(dateRecorded, 'start of day')
        ''');

    var output = {};
    for (var month in months) {
      output[month] = Map.fromIterable(
        scores,
        key: (item) => item,
        value: (item) => [],
      );
    }

    for (var recording in list) {
      String month = recording['date'].toString().substring(3);
      for (int num in [1, 2, 3]) {
        if (activeScores.keys.contains(recording['score${num}ID'])) {
          output[month][recording['score${num}ID']].add({
            'day': int.parse(recording['date'].toString().substring(0, 2)),
            'score': recording['score${num}Value'],
            'type': recording['type']
          });
        }
      }
      if (recording['wpm'] != null) {
        output[month]['wpm'].add({
          'day': int.parse(recording['date'].toString().substring(0, 2)),
          'score': recording['wpm'],
          'type': recording['type']
        });
      }
    }

    return output;
  }
}
