import 'dart:core';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:main/datetime/date_time.dart';
import 'package:main/models/exercise.dart';
import 'package:main/models/workout.dart';
import 'package:main/models/set.dart';

/* Database for current workouts/exercises */

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
    // convert workout objects to String lists
    //final workoutList = convertObjectToWorkoutList(workouts);
    //final exerciseList = convertObjectToExerciseList(workouts);
    //final setList = convertObjectToSetList(workouts);

    /*
      Check if any exercises have been done
      Put a 0 (not done) or 1 (done) for each yyyymmdd date
    */

    if (exerciseCompleted(workouts)) {
      _myBox.put("COMPLETION_STATUS_${todaysDateYYYYMMDD()}", 1);
    } else {
      _myBox.put("COMPLETION_STATUS_${todaysDateYYYYMMDD()}", 0);
    }

    // Save into hive
    //_myBox.put("WORKOUTS", workoutList);
    _myBox.put("CURRENT_WORKOUTS", workouts);
    print("Database saved with ${workouts.length} workouts.");
    //_myBox.put("EXERCISES", exerciseList);
    //_myBox.put("SETS", setList);
  }

  // Read data, return list of workouts
  List<Workout> readFromDatabase() {
    final dynamic workouts = _myBox.get("CURRENT_WORKOUTS");
    if (workouts is List) {
      return workouts.cast<Workout>().toList();
    }
    return [];
    /*
    List<Workout> mySavedWorkouts = [];

    List<List<String>> workouts =
        List<List<String>>.from(_myBox.get("WORKOUTS"));
    final exerciseDetails = _myBox.get("EXERCISES");
    final setDetails = _myBox.get("SETS");

    // Create workout objects
    for (int i = 0; i < workouts.length; i++) {
      // Each workout can have multiple exercises
      List<Exercise> exercisesInEachWorkout = [];

      for (int j = 0; j < exerciseDetails[i].length; j++) {
        // Each exercise can have multiple sets
        List<Set> setsInEachExercise = [];

        for (int k = 0; k < setDetails[i][j].length; k++) {
          setsInEachExercise.add(
            Set(
                key: setDetails[i][j][k][0],
                weight: setDetails[i][j][k][1],
                reps: setDetails[i][j][k][2],
                isCompleted: setDetails[i][j][k][3] == 'true' ? true : false),
          );
        }

        exercisesInEachWorkout.add(
          Exercise(
              key: exerciseDetails[i][j][0],
              name: exerciseDetails[i][j][1],
              isCompleted: exerciseDetails[i][j][2] == 'true' ? true : false,
              //weight: exerciseDetails[i][j][2],
              //reps: exerciseDetails[i][j][3],
              sets: setsInEachExercise,
          )
        );
      }

      // Create individual workout
      Workout workout = Workout(
          key: workouts[i][0],
          name: workouts[i][1],
          exercises: exercisesInEachWorkout);

      // Add workout to overall list
      mySavedWorkouts.add(workout);
    }
    // return final list of saved workouts
    return mySavedWorkouts;
     */
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

  /*
  // Return workout completion status on date yyyymmdd
  int getCompletionStatus(String yyyymmdd) {
    // returns 0 or 1, if null then return 0
    int completionStatus = _myBox.get("COMPLETION_STATUS_$yyyymmdd") ?? 0;
    return completionStatus;
  }
   */
}

// Convert workout objects into lists of Strings -> [ upperBody, lowerBody ]
// (Hive is best with primitive data types)
List<List<String>> convertObjectToWorkoutList(List<Workout> workouts) {
  List<List<String>> workoutList = [
    // [upperbody, lowerbody]
  ];

  for (int i = 0; i < workouts.length; i++) {
    workoutList.add(
        [workouts[i].key, workouts[i].name, workouts[i].isActive.toString()]);
  }

  return workoutList;
}

// Convert exercise objects in each workout object into lists
// List of workouts (1d)
// Each workout is a list of exercises (2d)
// Each exercise is a list of exercise features (3d)
List<List<List<String>>> convertObjectToExerciseList(List<Workout> workouts) {
  List<List<List<String>>> exerciseList = [
    /*
        [upperBody, lowerBody]
        [ [ ['biceps', 10kg, 10 reps, 3 sets], [another exercise] ], [ [lower body], [lower body] ] ]
      */
  ];

  // Go through each workout
  for (int i = 0; i < workouts.length; i++) {
    List<Exercise> exercisesInWorkout = workouts[i].exercises;

    List<List<String>> individualWorkout = [
      // [ ['biceps', 10 kg, 10 reps, 3 sets] ]
    ];

    // Go through each exercise in the workout
    for (int j = 0; j < exercisesInWorkout.length; j++) {
      List<String> individualExercise = [];
      individualExercise.addAll(
        [
          exercisesInWorkout[j].key,
          exercisesInWorkout[j].name,
          //exercisesInWorkout[j].weight,
          //exercisesInWorkout[j].reps,
          //exercisesInWorkout[j].sets,
          exercisesInWorkout[j].isCompleted.toString(),
        ],
      );
      individualWorkout.add(individualExercise);
    }

    exerciseList.add(individualWorkout);
  }
  return exerciseList;
}

// Convert workouts into list of all strings
// List of workouts (1d)
// Each workout is its own list (2d)
// Each exercise in each workout is its own list (3d)
// Each set in each exercise is its own list (4d)
// Example:
// Workouts: [ [key1, 'Push'], [key2, 'Pull'], []... ]
// Exercises: [ [ ['Bench', 10 reps, 100 lbs, 3 sets], []
// Sets: [ [ [[set1], [set2]], ] ]
List<List<List<List<String>>>> convertObjectToSetList(List<Workout> workouts) {
  List<List<List<List<String>>>> setList = [];

  // Iterate over each Workout
  for (int i = 0; i < workouts.length; i++) {
    // In workout, iterate over each Exercise
    List<Exercise> exercisesInWorkout = workouts[i].exercises;
    List<List<List<String>>> individualWorkout = [];

    for (int j = 0; j < exercisesInWorkout.length; j++) {
      // In each exercise, iterate over the sets
      List<Set> setsInExercise = exercisesInWorkout[j].sets;
      List<List<String>> individualExercise = [];

      for (int k = 0; k < setsInExercise.length; k++) {
        List<String> individualSet = [];
        individualSet.addAll([
          setsInExercise[k].key,
          setsInExercise[k].weight,
          setsInExercise[k].reps,
          setsInExercise[k].isCompleted.toString(),
        ]);
        individualExercise.add(individualSet);
      }

      individualWorkout.add(individualExercise);
    }

    setList.add(individualWorkout);
  }
  return setList;
}
