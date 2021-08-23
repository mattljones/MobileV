// Dart & Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' as ap;
import 'package:charts_flutter/flutter.dart' as charts;

// Module imports
import 'package:mobilev/widgets/audio_player.dart';
import 'package:mobilev/widgets/chart_scores.dart';
import 'package:mobilev/widgets/chart_usage.dart';
import 'package:mobilev/widgets/dropdown.dart';
import 'package:mobilev/widgets/form_button.dart';
import 'package:mobilev/widgets/form_input_number.dart';
import 'package:mobilev/widgets/form_input_text.dart';
import 'package:mobilev/widgets/profile_card.dart';
import 'package:mobilev/widgets/recording_card_score.dart';
import 'package:mobilev/widgets/status_card.dart';
import 'package:mobilev/widgets/toggle_buttons.dart';

void main() {
  // audio_player.dart
  testWidgets('Test audio player loads correctly', (WidgetTester tester) async {
    for (bool hasDelete in [true, false]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AudioPlayer(
              source: ap.AudioSource.uri(Uri.parse('')),
              hasDelete: hasDelete,
              onDelete: () {},
            ),
          ),
        ),
      );
      final playButtonFinder = find.byType(InkWell);
      await tester.tap(playButtonFinder);
      await tester.pump();
      expect(playButtonFinder, findsOneWidget);
      expect(find.byType(AudioPlayer), findsOneWidget);
      expect(find.byType(IconButton),
          hasDelete ? findsOneWidget : findsNothing); // Delete button
    }
  });

  // chart_scores.dart
  testWidgets('Test score chart loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreChart(
            axisTitle: 'title',
            index: 0,
            chartData: [
              {'day': 1, 'score': 1, 'type': 'N'},
              {'day': 2, 'score': 2, 'type': 'T'},
              {'day': 3, 'score': 3, 'type': 'N'},
            ],
          ),
        ),
      ),
    );
    expect(find.byType(charts.LineChart), findsOneWidget);
  });

  // chart_usage.dart
  testWidgets('Test usage chart loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UsageChart([
            {'month': 'May', 'noRecordings': 1, 'noMinutes': 1},
            {'month': 'Jun', 'noRecordings': 2, 'noMinutes': 2},
            {'month': 'Jul', 'noRecordings': 3, 'noMinutes': 3},
            {'month': 'Aug', 'noRecordings': 4, 'noMinutes': 4}
          ]),
        ),
      ),
    );
    expect(find.byType(charts.BarChart), findsOneWidget);
  });

  // dropdown.dart
  testWidgets('Test custom dropdown loads correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyDropdown(
            items: ['item1', 'item2', 'item3'],
            prompt: 'Prompt',
            dropdownValue: 'item1',
            onChanged: null,
          ),
        ),
      ),
    );
    expect(find.byType(Text), findsNWidgets(4));
  });

  // form_button.dart
  testWidgets('Test main form submit button loads correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormButton(
            text: 'buttonText',
            buttonColour: Colors.blue,
            textColour: Colors.red,
            icon: Icon(Icons.check),
            onPressed: () {},
          ),
        ),
      ),
    );
    expect(find.text('buttonText'), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
  });

  // form_input_number.dart
  testWidgets('Test numeric-only form field loads correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormInputNumber(
            controller: TextEditingController(),
            label: 'label',
            validator: null,
            initialValue: null,
          ),
        ),
      ),
    );
    final inputFieldFinder = find.byType(FormInputNumber);
    expect(inputFieldFinder, findsOneWidget);
    await tester.enterText(inputFieldFinder, '12Aa@3');
    expect(find.text('123'), findsOneWidget);
  });

  // form_input_text.dart
  testWidgets('Test regular form field loads correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormInputText(
            controller: TextEditingController(),
            label: 'label',
            icon: Icons.check,
            obscureInput: false,
            keyboard: TextInputType.text,
            validator: null,
          ),
        ),
      ),
    );
    expect(find.text('label'), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
  });

  // profile_card.dart
  testWidgets('Test profile card loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileCard(
            icon: Icons.check,
            title: 'title',
            status: 'status',
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('title'), findsOneWidget);
    expect(find.text('status'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });

  // recording_card_score.dart
  testWidgets(
      'Test individual score in recording card accordion loads correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordingCardScore(
            scoreName: 'name',
            scoreValue: 1,
          ),
        ),
      ),
    );
    expect(find.byType(RichText), findsOneWidget);
  });

  // status_card.dart
  testWidgets('Test status card loads correctly', (WidgetTester tester) async {
    for (bool iconFirst in [true, false]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusCard(
              colour: Colors.red,
              label: 'label',
              icon: Icon(Icons.check),
              iconFirst: iconFirst,
            ),
          ),
        ),
      );
      expect(find.text('label'), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
    }
  });

  // toggle_buttons.dart
  testWidgets('Test toggle buttons load correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyToggleButtons(
            fields: ['field1', 'field2'],
            isSelected: [true, false],
            fontSize: 10.0,
            onPressed: (int index) {},
          ),
        ),
      ),
    );
    expect(find.text('field1'), findsOneWidget);
    expect(find.text('field2'), findsOneWidget);
  });
}
