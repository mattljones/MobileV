// Package imports
import 'package:sqflite/sqflite.dart';

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

}
