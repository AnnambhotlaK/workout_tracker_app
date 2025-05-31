/* Database for saved workout sessions */
import 'package:hive_flutter/hive_flutter.dart';
import 'package:main/datetime/date_time.dart';
import 'package:main/models/exercise.dart';
import 'package:main/models/workout.dart';
import 'package:main/models/session.dart';

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
  // TODO: Implement
  void saveToDatabase(List<Session> sessions) {
    // convert workout objects to String lists
    //final sessionList = convertObjectToSessionList(sessions);
    //final exerciseList = convertObjectToExerciseList(sessions);

    /*
      Check if any exercises have been done
      Put a 0 (not done) or 1 (done) for each yyyymmdd date
      Note: All exercises in session should be completed
    */

    if (/*exerciseCompleted(workouts)*/false) {
      _myBox.put("COMPLETION_STATUS_${todaysDateYYYYMMDD()}", 1);
    }
    else {
      _myBox.put("COMPLETION_STATUS_${todaysDateYYYYMMDD()}", 0);
    }

    // Save into hive
    //_myBox.put("SESSIONS", sessionList);
    //_myBox.put("EXERCISES", exerciseList);
  }

  // Read data, return list of workouts
  List<Session> readFromDatabase() {
    List<Session> mySavedSessions = [];

    List<List<String>> sessions =
    List<List<String>>.from(_myBox.get("SESSIONS"));
    //final exerciseDetails = _myBox.get("EXERCISES");

    // Create session objects
    for (int i = 0; i < sessions.length; i++) {
      // Each session has exercises
      /*
      List<Exercise> exercisesInSession = [];

      for (int j = 0; j < exerciseDetails[i].length; j++) {
        exercisesInSession.add(
          Exercise(
              key: exerciseDetails[i][j][0],
              name: exerciseDetails[i][j][1],
              weight: exerciseDetails[i][j][2],
              reps: exerciseDetails[i][j][3],
              sets: exerciseDetails[i][j][4],
              isCompleted: exerciseDetails[i][j][5] == 'true' ? true : false),
        );
      }
      */

      /*
      // Create individual workout
      Session session = Session(
          key: sessions[i][0],
          workoutName: sessions[i][1],
          exercises: exercisesInSession);
       */

      // Add session to list
      //mySavedSessions.add(session);
    }
    // return final list of saved workouts
    return mySavedSessions;
  }

  // Check if any exercises have been done
  bool exerciseCompleted(List<Workout> workouts) {
    // Go through workouts
    for (var workout in workouts) {
      // go through each exercise in workout
      for (var exercise in workout.exercises) {
        if (exercise.isCompleted) {
          return true;
        }
      }
    }
    return false;
  }

}