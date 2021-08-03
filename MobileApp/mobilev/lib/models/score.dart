// Package imports
import 'package:sqflite/sqflite.dart';

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

  @override
  String toString() {
    return 'UserData{scoreID: $scoreID, scoreName: $scoreName, isCurrent: $isCurrent}';
  }

  // Queries -------------------------------------------------------------------

}
