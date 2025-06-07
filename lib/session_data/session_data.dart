/*
  Used to store history of workouts completed
  Could be viewed by the user?
 */

import 'package:flutter/material.dart';
import 'package:main/session_data/session_data_db.dart';
import 'package:main/datetime/date_time.dart';
import 'package:uuid/uuid.dart';

import '../models/workout.dart';
import 'package:main/models/exercise.dart';
import '../models/session.dart';

/* Session Data refers to the completed workout sessions.
 */

var uuid = const Uuid();

class SessionData extends ChangeNotifier {
  /* Should get its own database */
  final sessionDb = HiveDatabase();

/*

    SESSION DATA STRUCTURE

    - List contains completed sessions, first is earliest, last is latest.
    - Each session has a String key,
       String name and
       List<Exercise> of exercises,
       and DateTime dateCompleted
       for now.
    - Note that session data also corresponds to heat map updates.
      (if completed session, show activity on heat map for today)
*/
  List<Session> sessionList = [];

  // If there are sessions already in database, get that list
  // Otherwise, use nothing
  void initializeSessionList() {
    if (sessionDb.previousDataExists()) {
      sessionList = sessionDb.readFromDatabase();
    } else {
      sessionDb.saveToDatabase(sessionList);
    }

    // Initialize heatMapSessionDataset
    for (int i = 0; i < sessionList.length; i++) {
      DateTime date = sessionList[i].dateCompleted;
      if (heatMapSessionDataset[date] == null) {
        heatMapSessionDataset[date] = [];
      }
      heatMapSessionDataset[date]!.add(sessionList[i]);
    }

    // Show session activity
    loadHeatMap();
  }

  List<Session> getSessionList() {
    return sessionList;
  }

  void addSession(
      String workoutName, List<Exercise> exercises, DateTime dateCompleted) {
    Session newSession = Session(
        key: uuid.v4(),
        workoutName: workoutName,
        exercises: exercises,
        dateCompleted: dateCompleted);
    sessionList.add(newSession);
    notifyListeners();
    sessionDb.saveToDatabase(sessionList);
    // Add session completed to dataset for heatmap onclick
    if (heatMapSessionDataset[dateCompleted] == null) {
      heatMapSessionDataset[dateCompleted] = [];
    }
    (heatMapSessionDataset[dateCompleted])!.add(newSession);
    loadHeatMap();
  }

  void deleteSession(String key) {
    sessionList.removeWhere((session) => session.key == key);

    notifyListeners();
    sessionDb.saveToDatabase(sessionList);
  }

  // Want to load heat map based on days with sessions
  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(sessionDb.getStartDate());

    // Count number of days to load
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // From start date to today, load each completion status in the database
    for (int i = 0; i < daysInBetween + 1; i++) {
      // use date to load to heatmapsessiondataset
      DateTime date = startDate.add(Duration(days: i));
      String yyyymmdd = convertDateTimeToYYYYMMDD(date);

      int completionStatus = sessionDb.getCompletionStatus(yyyymmdd);

      int year = date.year;
      int month = date.month;
      int day = date.day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): completionStatus,
      };

      // Add entry to heat map dataset
      heatMapDataset.addEntries(percentForEachDay.entries);
    }
  }

  String getStartDate() {
    return sessionDb.getStartDate();
  }

  // When clicking on a day on heatmap, show scrollable list of
  // sessions completed on date
  void showActivityOnDay(BuildContext context, DateTime date) {
    // load list of sessions on date
    List<Session> activityList = (heatMapSessionDataset[date] ?? []);
    // Print notification and return if activityList is empty
    if (activityList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sessions completed on this day.')),
      );
      return;
    }
    // Else, show dialog with list of workouts
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Sessions on ${date.toLocal().toString().split(' ')[0]}'), // Display date nicely
          content: SizedBox(
            // Constrain the size of the dialog content
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true, // Important for ListView inside AlertDialog
              itemCount: activityList.length,
              itemBuilder: (BuildContext context, int index) {
                Session session = activityList[index];
                return Card(
                  // Use Card for better visual separation
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          session
                              .workoutName, // Assuming Session has 'workoutName'
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          'Exercises:',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        // Assuming Session has a list of 'exercises' (e.g., List<String> or List<ExerciseModel>)
                        if (session.exercises.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: session.exercises.map((exercise) {
                              return Text(
                                  '- ${exercise.name} | ${exercise.sets}x${exercise.reps}');
                            }).toList(),
                          )
                        else
                          const Text('No exercises listed for this session.'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /*
    HEAT MAP
  */
  Map<DateTime, int> heatMapDataset = {};
  // Used to key datetimes to the list of sessions completed on date
  Map<DateTime, List<Session>> heatMapSessionDataset = {};
}
