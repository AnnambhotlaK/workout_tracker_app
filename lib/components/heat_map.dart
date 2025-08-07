import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:main/data_providers/session_data_provider.dart';
import 'package:main/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class MyHeatMap extends StatelessWidget {
  const MyHeatMap({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sessionDataProvider =
        Provider.of<SessionDataProvider>(context, listen: false);
    final themeDataProvider =
        Provider.of<ThemeProvider>(context, listen: false);

    final Map<DateTime, int>? datasetsForHeatMap =
        sessionDataProvider.heatMapDataset;
    final DateTime startDateForHeatMap =
        sessionDataProvider.getStartDateForHeatMap();

    // DEBUG: Print what MyHeatMap is receiving
    print("MyHeatMap build(): StartDate: $startDateForHeatMap");
    print(
        "MyHeatMap build(): Datasets received by widget: $datasetsForHeatMap");
    if (datasetsForHeatMap != null && datasetsForHeatMap.isNotEmpty) {
      datasetsForHeatMap.forEach((date, value) {
        print("  Dataset entry for HeatMap: Date: $date, Value: $value");
      });
    } else {
      print("MyHeatMap build(): Datasets are null or empty.");
    }

    return Container(
      padding: const EdgeInsets.all(25),
      child: HeatMapCalendar(
        initDate: startDateForHeatMap,
        datasets: datasetsForHeatMap,
        showColorTip: false,
        flexible: true,
        size: 30,
        monthFontSize: 20,
        weekFontSize: 15,
        colorMode: ColorMode.color,
        colorsets: const {
          1: Colors.green,
        },
        defaultColor: themeDataProvider.isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade200,
        textColor: themeDataProvider.isDarkMode
            ? Colors.white
            : Colors.black,
        weekTextColor: themeDataProvider.isDarkMode
            ? Colors.white
            : Colors.black,
        onClick: (date) {
          Provider.of<SessionDataProvider>(context, listen: false)
              .showActivityOnDay(context, date);
        },
      ),
    );
  }
}
