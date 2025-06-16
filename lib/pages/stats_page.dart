import 'package:flutter/material.dart';
import 'package:main/session_data/session_data.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // Function to get number of workouts completed
  // each week, includes this week + 4 previous
  //
  List<int> getWeeklyActivity() {
    return [];
  }

  int getLifetimeSessions() {
    return Provider.of<SessionData>(context, listen: false)
        .getSessionList()
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionData>(
      builder: (BuildContext context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistics'),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          body: ListView(children: [
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(10, 10, 0, 0),
              child: Material(

                color: Colors.indigo,
                shape: RoundedRectangleBorder(
                    side: BorderSide.none, borderRadius: BorderRadius.circular(5)),
                textStyle: TextStyle(fontSize: 20),
                child: Text('Lifetime Sessions: ${getLifetimeSessions()}'),
              ),
            ),
          ]),
        );
      },
    );
  }
}
