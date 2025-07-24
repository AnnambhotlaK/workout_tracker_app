/*
import 'package:hive_flutter/hive_flutter.dart';
import 'package:main/datetime/date_time.dart';
import 'package:main/models/session.dart';

/* Database for completed and saved workouts, exercises, and sets*/

class HiveDatabase {
  final _myBox = Hive.box('session_database');

  // Check if there is already data stored
  // If not, record start date
  bool previousDataExists() {
    if (_myBox.isEmpty) {
      // ignore: avoid_print
      print('Previous data does NOT exist');
      _myBox.put("START_DATE", todaysDateYYYYMMDD());
      return false;
    } else {
      // ignore: avoid_print
      print('Previous data DOES exist');
      return true;
    }
  }

  // Return start date as yyyymmdd
  String getStartDate() {
    return _myBox.get("START_DATE");
  }

  // Save a session to the database
  void saveToDatabase(List<Session> sessions) {
    _myBox.put("SAVED_SESSIONS", sessions);
    print("Database saved with ${sessions.length} sessions.");

    // for each session, add completion status on that day
    for (int i = 0; i < sessions.length; i++) {
      DateTime dateCompleted = sessions[i].dateCompleted;
      String yyyymmddCompleted = convertDateTimeToYYYYMMDD(dateCompleted);
      _myBox.put("COMPLETION_STATUS_$yyyymmddCompleted", 1);
    }
  }

  // Read data, return list of workouts
  List<Session> readFromDatabase() {
    final dynamic sessions = _myBox.get("SAVED_SESSIONS");
    if (sessions is List) {
      return sessions.cast<Session>().toList();
    }
    return [];
  }

  // Return workout completion status on date yyyymmdd
  int getCompletionStatus(String yyyymmdd) {
    // returns 0 or 1, if null then return 0
    int completionStatus = _myBox.get("COMPLETION_STATUS_$yyyymmdd") ?? 0;
    return completionStatus;
  }
}
*/
