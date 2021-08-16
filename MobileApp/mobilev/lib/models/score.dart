// Module imports
import 'package:mobilev/services/database_service.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class Score {
  final int scoreID;
  final String scoreName;
  final bool isCurrent;

  Score({
    required this.scoreID,
    required this.scoreName,
    required this.isCurrent,
  });

  // Helper functions ----------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'scoreID': scoreID,
      'scoreName': scoreName,
      'isCurrent': isCurrent,
    };
  }

  // Useful for development
  @override
  String toString() {
    return 'Score{scoreID: $scoreID, scoreName: $scoreName, isCurrent: $isCurrent}';
  }

  // Queries -------------------------------------------------------------------

  // Get list of all scores
  static Future<Map<int, String>> selectAllScores() async {
    final db = databaseService.db;
    final List<Map<String, dynamic>> list = await db!.query(
      'Score',
      columns: ['scoreID', 'scoreName'],
    );

    return Map<int, String>.fromIterable(
      list,
      key: (item) => item['scoreID'],
      value: (item) => item['scoreName'],
    );
  }

  // Get list of currently active scores
  static Future<Map<int, String>> selectActiveScores() async {
    final db = databaseService.db;
    final List<Map<String, dynamic>> list = await db!.query(
      'Score',
      columns: ['scoreID', 'scoreName'],
      where: 'isCurrent = ?',
      whereArgs: [1],
      orderBy: 'scoreID ASC',
    );

    return Map<int, String>.fromIterable(
      list,
      key: (item) => item['scoreID'],
      value: (item) => item['scoreName'],
    );
  }

  // Update scores saved in the database based on those retrieved from back-end
  static Future<void> updateActiveScores(Map latestScores) async {
    final db = databaseService.db;

    List<int> scoreIDs = [];
    for (String scoreID in latestScores.keys) {
      scoreIDs.add(int.parse(scoreID));
    }

    // Label newly non-current scores as non-current
    await db!.update(
      'Score',
      {'isCurrent': 0},
      where:
          'scoreID NOT IN (${('?' * (latestScores.keys.length)).split('').join(', ')})',
      whereArgs: scoreIDs,
    );

    // Insert new scores
    for (var i = 0; i < latestScores.keys.length; i++) {
      await db.insert(
        'Score',
        {
          'scoreID': int.parse(latestScores.keys.toList()[i]),
          'scoreName': latestScores.values.toList()[i],
          'isCurrent': 1
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
