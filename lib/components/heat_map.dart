import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:main/datetime/date_time.dart';
import 'package:main/session_data/session_data_provider.dart';
import 'package:provider/provider.dart';

class MyHeatMap extends StatelessWidget {
  final Map<DateTime, int>? datasets;
  final DateTime startDate;

  const MyHeatMap({
    super.key,
    required this.datasets,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: HeatMapCalendar(
        initDate: startDate,
        datasets: datasets,
        //colorMode: ColorMode.color,
        //defaultColor: Provider.of<ThemeData>(context).primaryColor,
        //textColor: Colors.white,
        showColorTip: false,
        flexible: true,
        size: 30,
        monthFontSize: 20,
        weekFontSize: 15,
        colorsets: {
          1: Colors.green.shade100,
          2: Colors.green.shade200,
          3: Colors.green.shade300,
          4: Colors.green.shade400,
          //5: Colors.green.shade500,
          //6: Colors.green.shade600,
          //7: Colors.green.shade700,
          //8: Colors.green.shade800,
          //9: Colors.green.shade900
        },
        onClick: (date) {
          Provider.of<SessionDataProvider>(context, listen: false)
              .showActivityOnDay(context, date);
        },
      ),
    );
  }
}
