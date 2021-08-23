// Package imports
import 'package:flutter_test/flutter_test.dart';

// Module imports
import 'package:mobilev/services/database_service.dart';
import 'package:mobilev/models/user_data.dart';

void main() {
  // UserData.toMap()
  test('Test converting UserData to Map', () {
    final userData = UserData(
      domain: 'domain',
      field1: 'field1',
      field2: 'field2',
    );
    final mapped = userData.toMap();
    final expected = {
      'domain': 'domain',
      'field1': 'field1',
      'field2': 'field2',
    };
    expect(mapped, equals(expected));
  });

  // UserData.toShareString()
  test('Test converting sharePreference to a human-readable string', () {
    final userData = UserData(
      domain: 'sharePreference',
      field1: '1',
      field2: '0',
    );
    final string = userData.toShareString();
    final expected = 'Audio\nonly';
    expect(string, equals(expected));
  });

  // UserData.toRemindersString()
  test('Test converting remindersPreference to a human-readable string', () {
    final userData = UserData(
      domain: 'remindersPreference',
      field1: null,
      field2: null,
    );
    final string = userData.toRemindersString();
    final expected = 'Off';
    expect(string, equals(expected));
  });

  // UserData.selectUserData()
  test('Test selecting user data', () async {
    final db = await databaseService.initTest();
    final data = await UserData.selectUserData('sharePreference');
    final expected = UserData(
      domain: 'sharePreference',
      field1: '0',
      field2: '0',
    );
    expect(data, equals(expected));
    await db.close();
  });

  // UserData.updateUserData()
  test('Test updating user data', () async {
    final db = await databaseService.initTest();
    final newData = UserData(
      domain: 'sharePreference',
      field1: '1',
      field2: '1',
    );
    await UserData.updateUserData(newData);
    final data = await UserData.selectUserData('sharePreference');
    expect(data, equals(newData));
    await db.close();
  });
}
