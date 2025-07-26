import 'dart:core';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:main/datetime/date_time.dart';
import 'package:main/models/workout.dart';

/* Database for workouts, exercises, and sets in user's "library"

class HiveDatabase {
  // Reference hive box
  final _myBox = Hive.box('curr_workouts_database');

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

  // Write data
  void saveToDatabase(List<Workout> workouts) {
    _myBox.put("CURRENT_WORKOUTS", workouts);
    print("Database saved with ${workouts.length} workouts.");

    //Check if any exercises have been done
    //Put a 0 (not done) or 1 (done) for each yyyymmdd date
    if (exerciseCompleted(workouts)) {
      _myBox.put("COMPLETION_STATUS_${todaysDateYYYYMMDD()}", 1);
    } else {
      _myBox.put("COMPLETION_STATUS_${todaysDateYYYYMMDD()}", 0);
    }
  }

  // Read data, return list of workouts
  List<Workout> readFromDatabase() {
    final dynamic workouts = _myBox.get("CURRENT_WORKOUTS");
    if (workouts is List) {
      return workouts.cast<Workout>().toList();
    }
    return [];
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


 */