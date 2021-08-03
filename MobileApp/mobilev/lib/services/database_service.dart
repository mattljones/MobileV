// Package imports
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/*
 * MAIN DATABASE SERVICE -------------------------------------------------------
 */

class DatabaseService {
  Database? db;

  Future<void> init() async {
    db = await openDatabase(
      'database.db',
      onCreate: (db, version) async {
        await db.execute(sqlCreateScore);
        await db.execute(sqlCreateUserData);
        await db.execute(sqlCreateRecording);
        await db.execute(sqlInsertUsername);
        await db.execute(sqlInsertRemindersPreference);
        await db.execute(sqlInsertSharePreference);
      },
      version: 1,
    );
  }

  Future<void> initSeed() async {
    db = await openDatabase('assets/database.db');
    var databasePath = await getDatabasesPath();
    var path = join(databasePath, 'database.db');

    // Check if database already exists: if not, copy from assets (first login)
    var dbExists = await databaseExists(path);

    if (!dbExists) {
      print('Creating DB');
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from assets folder
      ByteData data =
          await rootBundle.load(join('assets/database', 'database.db'));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes
      await File(path).writeAsBytes(bytes, flush: true);
    }

    // Open the database
    db = await openDatabase(path);
  }
}

/*
 * CONSTANTS -------------------------------------------------------------------
 */

final databaseService = DatabaseService();

String sqlCreateScore = '''
CREATE TABLE Score(
  scoreID INTEGER PRIMARY KEY, 
  scoreName TEXT NOT NULL, 
  isCurrent INTEGER NOT NULL
); 
''';

String sqlCreateUserData = '''
CREATE TABLE UserData(
  domain TEXT PRIMARY KEY, 
  field1 TEXT, 
  field2 TEXT
); 
''';

String sqlCreateRecording = '''
CREATE TABLE Recording(
  dateRecorded TEXT PRIMARY KEY, 
  type TEXT NOT NULL, 
  duration INTEGER NOT NULL,
  audioFilePath TEXT NOT NULL, 
  score1ID INTEGER,
  score1Value INTEGER,
  score2ID INTEGER,
  score2Value INTEGER,
  score3ID INTEGER,
  score3Value INTEGER,
  isShared INTEGER NOT NULL,
  analysisStatus TEXT NOT NULL,
  wpm INTEGER,
  transcript TEXT,
  wordCloudFilePath TEXT,
  FOREIGN KEY(score1ID) REFERENCES Score(scoreID),
  FOREIGN KEY(score2ID) REFERENCES Score(scoreID),
  FOREIGN KEY(score3ID) REFERENCES Score(scoreID)
); 
''';

String sqlInsertUsername = '''
INSERT INTO UserData (domain, field1, field2)
VALUES ('username', null, null); 
''';

String sqlInsertRemindersPreference = '''
INSERT INTO UserData (domain, field1, field2)
VALUES ('remindersPreference', null, null); 
''';

String sqlInsertSharePreference = '''
INSERT INTO UserData (domain, field1, field2)
VALUES ('sharePreference', '0', '0'); 
''';
