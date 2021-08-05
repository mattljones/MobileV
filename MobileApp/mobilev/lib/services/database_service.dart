// Package imports
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/*
 * MAIN DATABASE SERVICE -------------------------------------------------------
 */

class DatabaseService {
  Database? db;

  // Regular database initialisation (and creation on first app open)
  Future<void> init() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      onCreate: (db, version) async {
        await createTables(db);
        await insertUserData(db);
      },
      version: 1,
    );
  }

  // Seeded database initialisation (for development)
  Future<void> initSeed() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      onCreate: (db, version) async {
        await createTables(db);
        // Seeding with dummy data
        for (var insert in sqlSeeds) {
          await db.execute(insert);
        }
      },
      version: 1,
    );
  }

  Future<void> createTables(Database db) async {
    await db.execute(sqlCreateScore);
    await db.execute(sqlCreateUserData);
    await db.execute(sqlCreateRecording);
  }

  // Inserts default UserData records
  Future<void> insertUserData(Database db) async {
    await db.execute(sqlInsertUsername);
    await db.execute(sqlInsertSharePreference);
    await db.execute(sqlInsertRemindersPreference);
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
  FOREIGN KEY(score1ID) REFERENCES Score(scoreID) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY(score2ID) REFERENCES Score(scoreID) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY(score3ID) REFERENCES Score(scoreID) ON UPDATE CASCADE ON DELETE RESTRICT
); 
''';

String sqlInsertUsername = '''
INSERT INTO UserData (domain, field1, field2)
VALUES ('username', null, null); 
''';

String sqlInsertSharePreference = '''
INSERT INTO UserData (domain, field1, field2)
VALUES ('sharePreference', '0', '0'); 
''';

String sqlInsertRemindersPreference = '''
INSERT INTO UserData (domain, field1, field2)
VALUES ('remindersPreference', null, null); 
''';

/*
 * DUMMY DATA-------------------------------------------------------------------
 */

List<String> sqlSeeds = [
  '''INSERT INTO UserData (domain, field1, field2) VALUES ('username', 'test', null);''',
  '''INSERT INTO UserData (domain, field1, field2) VALUES ('sharePreference', '0', '1');''',
  '''INSERT INTO UserData (domain, field1, field2) VALUES ('remindersPreference', '4', '19:00');''',
  '''INSERT INTO Score (scoreID, scoreName, isCurrent) VALUES (1, 'Breathing', 0);''',
  '''INSERT INTO Score (scoreID, scoreName, isCurrent) VALUES (2, 'Well being', 1);''',
  '''INSERT INTO Score (scoreID, scoreName, isCurrent) VALUES (3, 'GAD7', 1);''',
  '''INSERT INTO Score (scoreID, scoreName, isCurrent) VALUES (4, 'Steps', 1);''',
  // August data
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-08-04 12:00:00', 'Numeric', 120, 'test.m4a', 2, 5, 3, 8, 4, 2560, 1, 'pending', null, null, null);''',
  // July data
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-07-31 12:00:00', 'Numeric', 30, 'test.m4a', 1, 5, 3, 9, 4, 3004, 1, 'received', 60, null, null);''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-07-21 12:00:00', 'Text', 120, 'test.m4a', 2, 7, 3, 6, 4, 3160, 1, 'received', 55, 'Lorem ipsum...', null);''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-07-19 12:00:00', 'Numeric', 90, 'test.m4a', 1, 7, null, null, null, null, 1, 'received', 52, null, null);''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-07-17 12:00:00', 'Text', 30, 'test.m4a', null, null, null, null, null, null, 1, 'received', 53, 'Lorem ipsum...', 'test.jpg');''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-07-16 12:00:00', 'Numeric', 120, 'test.m4a', 2, 4, 3, 6, 4, 3120, 1, 'received', 52, null, null);''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-07-04 12:00:00', 'Text', 30, 'test.m4a', 2, 5, 3, 8, 4, 2950, 1, 'received', 61, 'Lorem ipsum...', 'test.jpg');''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-07-01 12:00:00', 'Numeric', 60, 'test.m4a', 2, 2, 3, 10, 4, 2412, 1, 'received', 70, null, null);''',
  // June data
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-06-29 12:00:00', 'Text', 90, 'test.m4a', 2, 8, 3, 6, 4, 3150, 1, 'received', 65, 'Lorem ipsum...', 'test.jpg');''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-06-22 12:00:00', 'Numeric', 60, 'test.m4a', 2, 9, 3, 2, 4, 2598, 1, 'received', 51, null, null);''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-06-18 12:00:00', 'Numeric', 30, 'test.m4a', 2, 10, 3, 6, null, null, 1, 'received', 40, null, null);''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-06-06 12:00:00', 'Text', 30, 'test.m4a', 2, 5, 3, 8, 4, 2900, 1, 'received', 59, 'Lorem ipsum...', 'test.jpg');''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-06-02 12:00:00', 'Numeric', 120, 'test.m4a', null, null, 1, 8, null, null, 1, 'received', 68, null, null);''',
  // May data
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-05-27 12:00:00', 'Text', 90, 'test.m4a', 2, 4, 3, 6, 4, 3150, 1, 'received', 50, 'Lorem ipsum...', 'test.jpg');''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-05-22 12:00:00', 'Numeric', 60, 'test.m4a', 2, 8, 3, 6, 4, 2598, 1, 'received', 72, null, null);''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2021-05-10 12:00:00', 'Text', 30, 'test.m4a', 2, 7, 3, 8, 4, 2950, 1, 'received', 70, 'Lorem ipsum...', 'test.jpg');''',
  // April data
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2020-12-30 12:00:00', 'Text', 90, 'test.m4a', 2, 4, 3, 6, 4, 3150, 1, 'received', 50, 'Lorem ipsum...', 'test.jpg');''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2020-12-11 12:00:00', 'Numeric', 60, 'test.m4a', 2, 8, 3, 6, 4, 2598, 1, 'received', 72, null, null);''',
  '''INSERT INTO Recording (dateRecorded, type, duration, audioFilePath, score1ID, score1Value, score2ID, score2Value, score3ID, score3Value, isShared, analysisStatus, wpm, transcript, wordCloudFilePath) 
     VALUES ('2020-12-08 12:00:00', 'Text', 30, 'test.m4a', 2, 7, 3, 8, 4, 2950, 1, 'received', 70, 'Lorem ipsum...', 'test.jpg');''',
];
