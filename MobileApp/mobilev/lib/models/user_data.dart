// Package imports
import 'package:sqflite/sqflite.dart';

class UserData {
  final String domain;
  final String field1;
  final String field2;

  UserData({
    required this.domain,
    required this.field1,
    required this.field2,
  });

  // Helper functions ----------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'domain': domain,
      'field1': field1,
      'field2': field2,
    };
  }

  @override
  String toString() {
    return 'UserData{domain: $domain, field1: $field1, field2: $field2}';
  }

  // Queries -------------------------------------------------------------------

}
