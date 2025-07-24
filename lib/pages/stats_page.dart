import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session.dart';
import '../session_data/session_data_provider.dart';

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
    return Provider.of<SessionDataProvider>(context, listen: false)
        .sessions.length;
  }

  int getLifetimeExercises() {
    List<Session> sessionList = Provider.of<SessionDataProvider>(context, listen: false).sessions;
    int exercises = 0;
    for (int i = 0; i < sessionList.length; i++) {
      exercises += sessionList[i].exercises.length;
    }
    return exercises;
  }

  int getLifetimeSets() {
    List<Session> sessionList =
        Provider.of<SessionDataProvider>(context, listen: false).sessions;
    int sets = 0;
    for (int i = 0; i < sessionList.length; i++) {
      for (int j = 0; j < sessionList[i].exercises.length; j++) {
        sets += sessionList[i].exercises[j].sets.length;
      }
    }
    return sets;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionDataProvider>(
      builder: (BuildContext context, sessionProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistics'),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          body: ListView(children: [

            // LAST 5 WEEK ACTIVITY CHART

            // LIFETIME SESSIONS
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Lifetime Sessions: ${getLifetimeSessions()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // LIFETIME EXERCISES
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Lifetime Exercises: ${getLifetimeExercises()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // LIFETIME SETS
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Lifetime Sets: ${getLifetimeSets()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            //TODO: CHART OF SESSIONS COMPLETED OVER PAST FIVE WEEKS

          ]),
        );
      },
    );
  }
}
