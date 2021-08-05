// Dart & Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:charts_flutter/flutter.dart' as charts;

// Module imports
import 'package:mobilev/config/constants.dart';

class UsageChart extends StatelessWidget {
  final List chartData;

  UsageChart(this.chartData);

  // Converting data to format required for plugin
  List<charts.Series<MonthlyUsage, String>> generateSeriesList() {
    final recordingsData = [
      for (var month in chartData)
        MonthlyUsage(month['month'], month['noRecordings'])
    ];

    final minutesData = [
      for (var month in chartData)
        MonthlyUsage(month['month'], month['noMinutes'])
    ];

    return [
      charts.Series<MonthlyUsage, String>(
        id: 'No. Recordings',
        colorFn: (MonthlyUsage usage, _) =>
            charts.ColorUtil.fromDartColor(kLightPrimaryColour),
        domainFn: (MonthlyUsage usage, _) => usage.month,
        measureFn: (MonthlyUsage usage, _) => usage.amount,
        data: recordingsData,
        labelAccessorFn: (MonthlyUsage usage, _) =>
            '${usage.amount.toString()}',
      ),
      charts.Series<MonthlyUsage, String>(
        id: 'No. Minutes',
        colorFn: (MonthlyUsage usage, _) =>
            charts.ColorUtil.fromDartColor(kLightAccentColour),
        domainFn: (MonthlyUsage usage, _) => usage.month,
        measureFn: (MonthlyUsage usage, _) => usage.amount,
        data: minutesData,
        labelAccessorFn: (MonthlyUsage usage, _) =>
            '${usage.amount.toString()}',
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: charts.BarChart(
        List.from(generateSeriesList()),
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
}

// Helper class
class MonthlyUsage {
  final String month;
  final int amount;

  MonthlyUsage(this.month, this.amount);
}
