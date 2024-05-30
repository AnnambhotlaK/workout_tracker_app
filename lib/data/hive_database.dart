import 'package:hive_flutter/hive_flutter.dart';
import 'package:main/datetime/date_time.dart';
import 'package:main/models/exercise.dart';
import 'package:main/models/workout.dart';

class HiveDatabase {
  // Reference hive box
  final _myBox = Hive.box('workout_database');

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
    final workoutList = convertObjectToWorkoutList(workouts);
    final exerciseList = convertObjectToExerciseList(workouts);

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
    _myBox.put("WORKOUTS", workoutList);
    _myBox.put("EXERCISES", exerciseList);
  }

  // Read data, return list of workouts
  List<Workout> readFromDatabase() {
    List<Workout> mySavedWorkouts = [];

    List<String> workoutNames = _myBox.get("WORKOUTS");
    final exerciseDetails = _myBox.get("EXERCISES");

    // Create workout objects
    for (int i = 0; i < workoutNames.length; i++) {
      // Each workout can have multiple exercises
      List<Exercise> exercisesInEachWorkout = [];

      for (int j = 0; j < exerciseDetails[i].length; j++) {
        exercisesInEachWorkout.add(
          Exercise(
              name: exerciseDetails[i][j][0],
              weight: exerciseDetails[i][j][1],
              reps: exerciseDetails[i][j][2],
              sets: exerciseDetails[i][j][3],
              isCompleted: exerciseDetails[i][j][4] == 'true' ? true : false),
        );
      }

      // Create individual workout
      Workout workout =
          Workout(name: workoutNames[i], exercises: exercisesInEachWorkout);

      // Add workout to overall list
      mySavedWorkouts.add(workout);
    }
    // return final list of saved workouts
    return mySavedWorkouts;
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

  // Return workout completion status on date yyyymmdd
  int getCompletionStatus(String yyyymmdd) {
    // returns 0 or 1, if null then return 0
    int completionStatus = _myBox.get("COMPLETION_STATUS_$yyyymmdd") ?? 0;
    return completionStatus;
  }
}

// Convert workout objects into lists of Strings -> [ upperBody, lowerBody ]
// (Hive is best with primitive data types)
List<String> convertObjectToWorkoutList(List<Workout> workouts) {
  List<String> workoutList = [
    // [upperbody, lowerbody]
  ];

  for (int i = 0; i < workouts.length; i++) {
    workoutList.add(
      workouts[i].name,
    );
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

    // Go through each exercise in exerciseList
    for (int j = 0; j < exercisesInWorkout.length; j++) {
      List<String> individualExercise = [
        // ['biceps', 10 kg, 10 reps, 3 sets]
      ];
      individualExercise.addAll(
        [
          exercisesInWorkout[j].name,
          exercisesInWorkout[j].weight,
          exercisesInWorkout[j].reps,
          exercisesInWorkout[j].sets,
          exercisesInWorkout[j].isCompleted.toString(),
        ],
      );
      individualWorkout.add(individualExercise);
    }
    exerciseList.add(individualWorkout);
  }
  return exerciseList;
}
