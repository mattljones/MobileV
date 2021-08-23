// Package imports
import 'package:flutter_test/flutter_test.dart';

// Module imports
import 'package:mobilev/models/score.dart';

void scoreUnitTests() async {
  // Score.toMap()
  test('Test converting Score to Map', () {
    final score = Score(
      scoreID: 1,
      scoreName: 'name',
      isCurrent: true,
    );
    final mapped = score.toMap();
    final expected = {
      'scoreID': 1,
      'scoreName': 'name',
      'isCurrent': true,
    };
    expect(mapped, equals(expected));
  });

  // Score.selectAllScores()
  test('Test selecting all scores', () async {
    final data = await Score.selectAllScores();
    final expected = {
      1: 'Wellbeing',
      2: 'GAD7',
      3: 'Steps',
      4: 'OldScore',
    };
    expect(data, equals(expected));
  });

  // Score.selectActiveScores()
  test('Test selecting active scores only', () async {
    final data = await Score.selectActiveScores();
    final expected = {
      1: 'Wellbeing',
      2: 'GAD7',
      3: 'Steps',
    };
    expect(data, equals(expected));
  });

  // Score.updateActiveScores()
  test('Test updating scores based on API call', () async {
    final latestScores = {'1': 'newScore1', '2': 'newScore2'};
    await Score.updateActiveScores(latestScores);
    final data = await Score.selectActiveScores();
    final expected = {
      1: 'newScore1',
      2: 'newScore2',
    };
    expect(data, equals(expected));
  });
}
