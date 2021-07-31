import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:mobilev/config/constants.dart';

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}

class BarChartWithSecondaryAxis extends StatelessWidget {
  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';
  final List<charts.Series> seriesList;

  BarChartWithSecondaryAxis(this.seriesList);

  factory BarChartWithSecondaryAxis.withSampleData() {
    return BarChartWithSecondaryAxis(
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
        secondaryMeasureAxis: charts.NumericAxisSpec(
            tickProviderSpec:
                charts.BasicNumericTickProviderSpec(desiredTickCount: 4)),
        barRendererDecorator: charts.BarLabelDecorator<String>(
          labelPosition: charts.BarLabelPosition.inside,
          insideLabelStyleSpec: charts.TextStyleSpec(
            fontSize: 10,
            color: charts.ColorUtil.fromDartColor(Colors.white),
          ),
        ),
        behaviors: [
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
          charts.ChartTitle('No. Recordings',
              behaviorPosition: charts.BehaviorPosition.start,
              titleStyleSpec: charts.TextStyleSpec(
                fontFamily: 'PTSans',
                color: charts.ColorUtil.fromDartColor(kPrimaryColour),
              ),
              innerPadding: 0,
              outerPadding: 15,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea),
          charts.ChartTitle('No. Minutes',
              behaviorPosition: charts.BehaviorPosition.end,
              titleStyleSpec: charts.TextStyleSpec(
                fontFamily: 'PTSans',
                color: charts.ColorUtil.fromDartColor(kDarkAccentColour),
              ),
              innerPadding: 0,
              outerPadding: 15,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea),
        ],
      ),
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final globalSalesData = [
      OrdinalSales('May', 3),
      OrdinalSales('Jun', 6),
      OrdinalSales('Jul', 5),
      OrdinalSales('Aug', 4),
    ];

    final losAngelesSalesData = [
      OrdinalSales('May', 6),
      OrdinalSales('Jun', 10),
      OrdinalSales('Jul', 9),
      OrdinalSales('Aug', 14),
    ];

    return [
      charts.Series<OrdinalSales, String>(
        id: 'Recordings',
        colorFn: (OrdinalSales sales, _) =>
            charts.ColorUtil.fromDartColor(kLightPrimaryColour),
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: globalSalesData,
        labelAccessorFn: (OrdinalSales sales, _) => '${sales.sales.toString()}',
      ),
      charts.Series<OrdinalSales, String>(
        id: 'Minutes',
        colorFn: (OrdinalSales sales, _) =>
            charts.ColorUtil.fromDartColor(kLightAccentColour),
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: losAngelesSalesData,
        labelAccessorFn: (OrdinalSales sales, _) => '${sales.sales.toString()}',
      )..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId)
    ];
  }
}
