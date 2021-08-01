import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:mobilev/config/constants.dart';

class UsageChart extends StatelessWidget {
  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';
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
      OrdinalSales('Jun', 11),
      OrdinalSales('Jul', 9),
      OrdinalSales('Aug', 14),
    ];

    return [
      charts.Series<OrdinalSales, String>(
        id: 'No. Recordings',
        colorFn: (OrdinalSales sales, _) => sales.year != 'Aug'
            ? charts.ColorUtil.fromDartColor(kLightPrimaryColour)
            : charts.ColorUtil.fromDartColor(kSecondaryTextColour),
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: globalSalesData,
        labelAccessorFn: (OrdinalSales sales, _) => '${sales.sales.toString()}',
      ),
      charts.Series<OrdinalSales, String>(
        id: 'No. Minutes',
        colorFn: (OrdinalSales sales, _) => sales.year != 'Aug'
            ? charts.ColorUtil.fromDartColor(kLightAccentColour)
            : charts.ColorUtil.fromDartColor(Colors.grey.shade400),
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: losAngelesSalesData,
        labelAccessorFn: (OrdinalSales sales, _) => '${sales.sales.toString()}',
      )
    ];
  }
}

class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
