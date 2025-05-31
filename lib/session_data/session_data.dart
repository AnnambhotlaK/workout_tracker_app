/*
  Used to store history of workouts completed
  Could be viewed by the user?
 */

import 'package:flutter/material.dart';
import 'package:main/workout_data/curr_workouts_db.dart';
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
       List<Exercise> of exercises
       for now.
    - Note that session data also corresponds to heat map updates.
      (if completed session, show activity on heat map for today)
*/
  List<Session> sessionList = [];

  // If there are sessions already in database, get that list
  // Otherwise, use nothing
  void initializeSessionList() {
    if (sessionDb.previousDataExists()) {
      //sessionList = sessionList.readFromDatabase();
    } else {
      //sessionDb.saveToDatabase(workoutList);
    }

    //loadHeatMap();
  }

  List<Session> getSessionList() {
    return sessionList;
  }

  void addSession(
      String workoutName, List<Exercise> exercises, DateTime dateCompleted) {
    sessionList.add(Session(
        key: uuid.v4(),
        workoutName: workoutName,
        exercises: exercises,
        dateCompleted: dateCompleted));

    notifyListeners();
    //sessionDb.saveToDatabase(sessionList);
  }

  void deleteSession(String key) {
    sessionList.removeWhere((session) => session.key == key);

    notifyListeners();
    //sessionDb.saveToDatabase(sessionList);
  }

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(sessionDb.getStartDate());

    // Count number of days to load
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // From start date to today, load each completion status in the dataset
    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd =
          convertDateTimeToYYYYMMDD(startDate.add(Duration(days: i)));

      int completionStatus = sessionDb.getCompletionStatus(yyyymmdd);

      int year = startDate.add(Duration(days: i)).year;

      int month = startDate.add(Duration(days: i)).month;

      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): completionStatus,
      };

      // Add entry to heat map dataset
      heatMapDataset.addEntries(percentForEachDay.entries);
    }
  }

  /*
    HEAT MAP
  */
  Map<DateTime, int> heatMapDataset = {};
}
