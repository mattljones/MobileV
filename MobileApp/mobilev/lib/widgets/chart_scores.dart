// Dart & Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:charts_flutter/flutter.dart' as charts;

// Module imports
import 'package:mobilev/config/constants.dart';

class ScoreChart extends StatelessWidget {
  final List chartData;
  final String axisTitle;
  final int index;

  ScoreChart({
    required this.chartData,
    required this.axisTitle,
    required this.index,
  });

  static List<Color> colourList = [
    kLightPrimaryColour,
    kLightAccentColour,
    Color(0xFFAE2573),
    Color(0xFFFFA000),
  ];

  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  // Skips an x-axis label if adjacent (to prevent overlap in UI)
  List getCollisionFreeChartData() {
    var tempList = [];
    var collisionFreeList = [];
    for (var day in chartData) {
      if (tempList.contains(day['day'] - 1)) {
        continue;
      } else {
        tempList.add(day['day']);
        collisionFreeList.add({'day': day['day'], 'type': day['type']});
      }
    }

    return collisionFreeList;
  }

  // Converting data to format required for plugin
  List<charts.Series<DailyRecording, int>> generateSeriesList() {
    final data = [
      for (var day in chartData)
        DailyRecording(day['day'], day['score'], day['type'])
    ];

    return [
      charts.Series<DailyRecording, int>(
        id: 'Scores',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(colourList[index]),
        domainFn: (DailyRecording recording, _) => recording.day,
        measureFn: (DailyRecording recording, _) => recording.score,
        labelAccessorFn: (DailyRecording recording, _) =>
            '${recording.score.toString()}',
        data: data,
      )..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.LineChart(
      List.from(generateSeriesList()),
      animate: false,
      defaultRenderer: charts.LineRendererConfig(
        includePoints: true,
      ),
      layoutConfig: charts.LayoutConfig(
        leftMarginSpec: charts.MarginSpec.fixedPixel(42),
        rightMarginSpec: charts.MarginSpec.fixedPixel(42),
        topMarginSpec: charts.MarginSpec.fixedPixel(16),
        bottomMarginSpec: charts.MarginSpec.fixedPixel(16),
      ),
      domainAxis: charts.NumericAxisSpec(
        viewport: charts.NumericExtents(0, 32),
        tickProviderSpec: charts.StaticNumericTickProviderSpec(
          [
            for (var day in getCollisionFreeChartData())
              charts.TickSpec(
                day['day'],
              )
          ],
        ),
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(kSecondaryTextColour),
          ),
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(Colors.transparent),
          ),
        ),
        showAxisLine: false,
      ),
      secondaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec:
            charts.BasicNumericTickProviderSpec(desiredTickCount: 3),
        renderSpec: charts.GridlineRendererSpec(
          labelJustification: charts.TickLabelJustification.inside,
        ),
      ),
      behaviors: [
        charts.ChartTitle(
          axisTitle,
          behaviorPosition: charts.BehaviorPosition.start,
          outerPadding: 20,
          titleStyleSpec: charts.TextStyleSpec(
              fontSize: 15,
              fontFamily: 'PTSans',
              color: charts.ColorUtil.fromDartColor(
                  colourList[index]) //fromDartColor(colourList[index]),
              ),
        ),
        charts.RangeAnnotation(
          [
            for (var day in chartData)
              charts.RangeAnnotationSegment(
                day['day'] + 1,
                day['day'] + 1,
                charts.RangeAnnotationAxisType.domain,
                labelAnchor: charts.AnnotationLabelAnchor.end,
                labelDirection: charts.AnnotationLabelDirection.horizontal,
                labelPosition: charts.AnnotationLabelPosition.margin,
                labelStyleSpec: charts.TextStyleSpec(fontSize: 11),
                startLabel: day['type'][0],
              ),
            for (var day in chartData)
              charts.RangeAnnotationSegment(
                day['day'] - 1,
                day['day'] + 1,
                charts.RangeAnnotationAxisType.domain,
              ),
          ],
        ),
      ],
    );
  }
}

// Helper class
class DailyRecording {
  final int day;
  final int score;
  final String type;

  DailyRecording(this.day, this.score, this.type);
}
