import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:mobilev/config/constants.dart';

class ScoreChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final String axisTitle;
  final int index;

  ScoreChart({
    required this.seriesList,
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

  factory ScoreChart.withSampleData(String title, int index) {
    List<charts.Series<LinearSales, int>> _createSampleData() {
      final data = [
        LinearSales(2, 7, 'N'),
        LinearSales(9, 10, 'T'),
        LinearSales(17, 6, 'N'),
        LinearSales(22, 8, 'T'),
        LinearSales(30, 5, 'N'),
      ];

      return [
        charts.Series<LinearSales, int>(
          id: 'Sales',
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(colourList[index]),
          domainFn: (LinearSales sales, _) => sales.year,
          measureFn: (LinearSales sales, _) => sales.sales,
          labelAccessorFn: (LinearSales sales, _) =>
              '${sales.sales.toString()}',
          data: data,
        )..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId),
      ];
    }

    return new ScoreChart(
      seriesList: _createSampleData(),
      axisTitle: title,
      index: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.LineChart(
      List.from(seriesList),
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
            charts.TickSpec(2),
            charts.TickSpec(9),
            charts.TickSpec(17),
            charts.TickSpec(22),
            charts.TickSpec(30),
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
          )),
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
            charts.RangeAnnotationSegment(
              3,
              3,
              charts.RangeAnnotationAxisType.domain,
              labelAnchor: charts.AnnotationLabelAnchor.end,
              labelDirection: charts.AnnotationLabelDirection.horizontal,
              labelPosition: charts.AnnotationLabelPosition.margin,
              labelStyleSpec: charts.TextStyleSpec(),
              startLabel: 'N',
            ),
            charts.RangeAnnotationSegment(
              1,
              3,
              charts.RangeAnnotationAxisType.domain,
            ),
            charts.RangeAnnotationSegment(
              10,
              10,
              charts.RangeAnnotationAxisType.domain,
              labelAnchor: charts.AnnotationLabelAnchor.end,
              labelDirection: charts.AnnotationLabelDirection.horizontal,
              labelPosition: charts.AnnotationLabelPosition.margin,
              labelStyleSpec: charts.TextStyleSpec(),
              startLabel: 'T',
            ),
            charts.RangeAnnotationSegment(
              8,
              10,
              charts.RangeAnnotationAxisType.domain,
            ),
            charts.RangeAnnotationSegment(
              18,
              18,
              charts.RangeAnnotationAxisType.domain,
              labelAnchor: charts.AnnotationLabelAnchor.end,
              labelDirection: charts.AnnotationLabelDirection.horizontal,
              labelPosition: charts.AnnotationLabelPosition.margin,
              labelStyleSpec: charts.TextStyleSpec(),
              startLabel: 'T',
            ),
            charts.RangeAnnotationSegment(
              16,
              18,
              charts.RangeAnnotationAxisType.domain,
            ),
            charts.RangeAnnotationSegment(
              23,
              23,
              charts.RangeAnnotationAxisType.domain,
              labelAnchor: charts.AnnotationLabelAnchor.end,
              labelDirection: charts.AnnotationLabelDirection.horizontal,
              labelPosition: charts.AnnotationLabelPosition.margin,
              labelStyleSpec: charts.TextStyleSpec(),
              startLabel: 'N',
            ),
            charts.RangeAnnotationSegment(
              21,
              23,
              charts.RangeAnnotationAxisType.domain,
            ),
            charts.RangeAnnotationSegment(
              31,
              31,
              charts.RangeAnnotationAxisType.domain,
              labelAnchor: charts.AnnotationLabelAnchor.end,
              labelDirection: charts.AnnotationLabelDirection.horizontal,
              labelPosition: charts.AnnotationLabelPosition.margin,
              labelStyleSpec: charts.TextStyleSpec(),
              startLabel: 'N',
            ),
            charts.RangeAnnotationSegment(
              29,
              31,
              charts.RangeAnnotationAxisType.domain,
            ),
          ],
        ),
      ],
    );
  }
}

class LinearSales {
  final int year;
  final int sales;
  final String type;

  LinearSales(this.year, this.sales, this.type);
}
