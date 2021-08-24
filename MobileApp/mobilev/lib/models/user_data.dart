// Module imports
import 'package:mobilev/services/database_service.dart';
import 'package:mobilev/config/constants.dart';

class UserData {
  final String domain;
  final String? field1;
  final String? field2;

  UserData({required this.domain, this.field1, this.field2});

  @override
  bool operator ==(other) {
    return (other is UserData) &&
        other.domain == domain &&
        other.field1 == field1 &&
        other.field2 == field2;
  }

  // coverage:ignore-start
  @override
  int get hashCode => super.hashCode;
  // coverage:ignore-end

  // Helper functions ----------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'domain': domain,
      'field1': field1,
      'field2': field2,
    };
  }

  // String representation of share preferences for 'My profile' screen
  String toShareString() {
    if (field1 == '0' && field2 == '0') {
      return 'Declined';
    } else if (field1 == '1' && field2 == '0') {
      return 'Audio\nonly';
    } else if (field1 == '0' && field2 == '1') {
      return 'Word clouds\nonly';
    } else {
      return 'Audio,\nWord clouds';
    }
  }

  // String representation of reminders preferences for 'My profile' screen
  String toRemindersString() {
    if (field1 == null && field2 == null) {
      return 'Off';
    } else {
      return '${days[field1]}\n@ $field2';
    }
  }

  // coverage:ignore-start
  @override
  String toString() {
    return 'UserData{domain: $domain, field1: $field1, field2: $field2}';
  }
  // coverage:ignore-end

  // Queries -------------------------------------------------------------------

  // Select one (by domain)
  static Future<UserData> selectUserData(String domain) async {
    final db = databaseService.db;
    final Map<String, dynamic> map = (await db!.query(
      'UserData',
      where: 'domain = ?',
      whereArgs: [domain],
    ))[0];

    return UserData(
      domain: map['domain'],
      field1: map['field1'],
      field2: map['field2'],
    );
  }

  // Update one (by domain)
  static Future<void> updateUserData(UserData userData) async {
    final db = databaseService.db;
    await db!.update(
      'UserData',
      userData.toMap(),
      where: 'domain = ?',
      whereArgs: [userData.domain],
    );
  }
}
