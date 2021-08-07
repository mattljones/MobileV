// Module imports
import 'package:mobilev/services/database_service.dart';

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
}
