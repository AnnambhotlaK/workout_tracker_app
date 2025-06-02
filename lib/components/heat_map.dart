import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:main/datetime/date_time.dart';

class MyHeatMap extends StatelessWidget {
  final Map<DateTime, int>? datasets;
  final String startDateYYYYMMDD;

  const MyHeatMap({
    super.key,
    required this.datasets,
    required this.startDateYYYYMMDD,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: HeatMapCalendar(
        initDate: createDateTimeObject(startDateYYYYMMDD),
        datasets: datasets,
        colorMode: ColorMode.color,
        defaultColor: Colors.black,
        textColor: Colors.white,
        showColorTip: false,
        flexible: true,
        size: 30,
        monthFontSize: 20,
        weekFontSize: 15,
        colorsets: const {1: Colors.green},
      ),
    );
  }
}
