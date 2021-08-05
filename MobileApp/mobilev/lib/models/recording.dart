// Module imports
import 'package:mobilev/services/database_service.dart';
import 'package:mobilev/models/score.dart';
import 'package:mobilev/config/constants.dart';

class Recording {
  final String dateRecorded;
  final String type;
  final String duration;
  final String audioFilePath;
  final int? score1ID;
  final int? score1Value;
  final int? score2ID;
  final int? score2Value;
  final int? score3ID;
  final int? score3Value;
  final bool isShared;
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

  // Queries -------------------------------------------------------------------

  // Select total recordings and minutes
  static Future<Map<String, dynamic>> selectTotals() async {
    final db = databaseService.db;
    final Map<String, dynamic> totals = (await db!.rawQuery('''
      SELECT COUNT(DISTINCT dateRecorded) AS noRecordings, SUM(duration) AS noMinutes 
      FROM Recording;
      '''))[0];

    return totals;
  }

  // Select total usage
  static Future<List<Map<String, dynamic>>> selectUsage() async {
    final db = databaseService.db;
    final List<Map<String, dynamic>> list = await db!.rawQuery('''
      SELECT strftime('%m', dateRecorded) AS month, COUNT(DISTINCT dateRecorded) AS noRecordings, SUM(duration) AS noMinutes
      FROM Recording
      WHERE dateRecorded >= date('now', 'start of month', -3 months)
      GROUP BY date(dateRecorded, 'start of month')
      ORDER BY date(dateRecorded) ASC
      ''');

    return List.generate(list.length, (i) {
      return {
        'month': months[list[i]['month']],
        'noRecordings': list[i]['noRecordings'],
        'noMinutes': list[i]['noMinutes'],
      };
    });
  }

  // Select list of months for which have recordings
  static Future<List<String>> selectMonths() async {
    final db = databaseService.db;
    final List<Map<String, dynamic>> list = await db!.rawQuery('''
      SELECT DISTINCT strftime('%m-%Y', dateRecorded) AS month
      FROM Recording
      ORDER BY date(dateRecorded) DESC
      ''');

    return List.generate(list.length, (i) {
      return list[i]['month'];
    });
  }

  // Select word clouds per month for which have recordings
  static Future<List<Map<String, dynamic>>> selectWordClouds(
      String month) async {
    final db = databaseService.db;
    final List<Map<String, dynamic>> list = await db!.rawQuery('''
      SELECT strftime('%d-%m', dateRecorded) AS date, wordCloudFilePath
      FROM Recording
      WHERE strftime('%m-%Y', dateRecorded) = $month
      AND wordCloudFilePath IS NOT NULL 
      ORDER BY date(dateRecorded) DESC
      ''');

    return list;
  }

  // Get list of currently active scores
  static Future<List<Score>> selectActiveScores() async {
    final db = databaseService.db;
    final List<Map<String, dynamic>> list = await db!.query(
      'Score',
      where: 'isCurrent = ?',
      whereArgs: [1],
    );

    return List.generate(list.length, (i) {
      return Score(
        scoreID: list[i]['scoreID'],
        scoreName: list[i]['scoreName'],
        isCurrent: list[i]['isCurrent'],
      );
    });
  }

  // Select score analysis for a given month
  static Future<Iterable<dynamic>> selectAnalysis(String month) async {
    final db = databaseService.db;
    final List<Score> activeScores = await selectActiveScores();

    final List<Map<String, dynamic>> list = await db!.rawQuery('''
        SELECT strftime('%d', dateRecorded) AS day, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, wpm 
        FROM Recording
        WHERE strftime('%m-%Y', dateRecorded) = $month 
        GROUP BY date(dateRecorded, 'start of day')
        ''');

    var output = {};
    for (var score in activeScores) {
      output[score.scoreID] = [score.scoreName, []];
    }
    output['wpm'] = ['wpm', []];

    for (var recording in list) {
      if (output.keys.contains(recording['score1ID'])) {
        output[recording['score1ID']][1].add(
          {recording['day']: recording['score1Value']},
        );
      }
      if (output.keys.contains(recording['score2ID'])) {
        output[recording['score2ID']][1].add(
          {recording['day']: recording['score2Value']},
        );
      }
      if (output.keys.contains(recording['score3ID'])) {
        output[recording['score3ID']][1].add(
          {recording['day']: recording['score3Value']},
        );
      }
      if (recording['wpm'] != null) {
        output['wpm'][1].add(
          {recording['day']: recording['wpm']},
        );
      }
    }

    return output.values;
  }
}
