// Module imports
import 'package:mobilev/services/database_service.dart';
import 'model_unit_tests/recording_unit.dart';
import 'model_unit_tests/score_unit.dart';
import 'model_unit_tests/user_data_unit.dart';

// Ensures that concurrency issues don't occur between tests sharing a database connection
void main() async {
  await databaseService.initTest();
  recordingUnitTests();
  scoreUnitTests();
  userDataUnitTests();
}
