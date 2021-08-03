// Dart & Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:charts_flutter/flutter.dart' as charts;

// Module imports
import 'package:mobilev/config/constants.dart';

class UsageChart extends StatelessWidget {
  final List<charts.Series> seriesList;

  UsageChart(this.seriesList);

  factory UsageChart.withSampleData() {
    return UsageChart(
      _createSampleData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: charts.BarChart(
        List.from(seriesList),
        animate: true,
        barGroupingType: charts.BarGroupingType.grouped,
        primaryMeasureAxis: charts.NumericAxisSpec(
            tickProviderSpec:
                charts.BasicNumericTickProviderSpec(desiredTickCount: 4)),
        barRendererDecorator: charts.BarLabelDecorator<String>(
          labelPosition: charts.BarLabelPosition.inside,
          insideLabelStyleSpec: charts.TextStyleSpec(
            fontSize: 13,
            color: charts.ColorUtil.fromDartColor(Colors.white),
          ),
        ),
        behaviors: [
          charts.SeriesLegend(
            position: charts.BehaviorPosition.bottom,
            cellPadding: EdgeInsets.fromLTRB(0.0, 20.0, 20.0, 30.0),
            outsideJustification: charts.OutsideJustification.startDrawArea,
          ),
          charts.ChartTitle(
            'Summary: Last 3 months',
            titleStyleSpec: charts.TextStyleSpec(
              fontFamily: 'PTSans',
              fontSize: 22,
              color: charts.MaterialPalette.black,
            ),
            behaviorPosition: charts.BehaviorPosition.top,
            titleOutsideJustification: charts.OutsideJustification.start,
            innerPadding: 40,
          ),
        ],
      ),
    );
  }

  static List<charts.Series<MonthlyUsage, String>> _createSampleData() {
    final recordingsData = [
      MonthlyUsage('May', 3),
      MonthlyUsage('Jun', 6),
      MonthlyUsage('Jul', 5),
      MonthlyUsage('Aug', 4),
    ];

    final minutesData = [
      MonthlyUsage('May', 6),
      MonthlyUsage('Jun', 11),
      MonthlyUsage('Jul', 9),
      MonthlyUsage('Aug', 14),
    ];

    return [
      charts.Series<MonthlyUsage, String>(
        id: 'No. Recordings',
        colorFn: (MonthlyUsage usage, _) => usage.month != 'Aug'
            ? charts.ColorUtil.fromDartColor(kLightPrimaryColour)
            : charts.ColorUtil.fromDartColor(kSecondaryTextColour),
        domainFn: (MonthlyUsage usage, _) => usage.month,
        measureFn: (MonthlyUsage usage, _) => usage.amount,
        data: recordingsData,
        labelAccessorFn: (MonthlyUsage usage, _) =>
            '${usage.amount.toString()}',
      ),
      charts.Series<MonthlyUsage, String>(
        id: 'No. Minutes',
        colorFn: (MonthlyUsage usage, _) => usage.month != 'Aug'
            ? charts.ColorUtil.fromDartColor(kLightAccentColour)
            : charts.ColorUtil.fromDartColor(Colors.grey.shade400),
        domainFn: (MonthlyUsage usage, _) => usage.month,
        measureFn: (MonthlyUsage usage, _) => usage.amount,
        data: minutesData,
        labelAccessorFn: (MonthlyUsage usage, _) =>
            '${usage.amount.toString()}',
      )
    ];
  }
}

class MonthlyUsage {
  final String month;
  final int amount;

  MonthlyUsage(this.month, this.amount);
}
