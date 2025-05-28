import 'package:flutter/material.dart';
import 'package:main/workout_data/curr_workouts_db.dart';
import 'package:main/datetime/date_time.dart';
import 'package:uuid/uuid.dart';

import '../models/workout.dart';
import '../models/session.dart';
import 'package:main/models/exercise.dart';

 /* Workout Data refers to the workouts and exercises
 *  that are currently in the user's page. Deleted
 *  workouts and exercises are removed from the db,
 *  and this does not include sessions or (potentially)
 *  saved past workouts and exercises
 * */

var uuid = const Uuid();

class WorkoutData extends ChangeNotifier {
  final currWorkoutsDb = HiveDatabase();

  /*

    WORKOUT DATA STRUCTURE

    - List contains different workouts.
    - Each workout has a String key, String name and List<Exercise> of exercises.
    
  */

  List<Workout> workoutList = [
    // Default workouts (Push, Pull, Legs)
    Workout(
      key: uuid.v4(),
      name: 'Push',
      exercises: [
        Exercise(
            key: uuid.v4(),
            name: 'Bench Press',
            weight: '60',
            reps: '5',
            sets: '5'),
        Exercise(
            key: uuid.v4(),
            name: 'Dumbbell Shoulder Press',
            weight: '12',
            reps: '8',
            sets: '3'),
        Exercise(
            key: uuid.v4(),
            name: 'Lateral Raise',
            weight: '5',
            reps: '10',
            sets: '3'),
        Exercise(
            key: uuid.v4(),
            name: 'Triceps Extension',
            weight: '15',
            reps: '10',
            sets: '3'),
      ],
    ),
    Workout(
      key: uuid.v4(),
      name: 'Pull',
      exercises: [
        Exercise(
            key: uuid.v4(),
            name: 'Pull Ups',
            weight: '0',
            reps: '6',
            sets: '4'),
        Exercise(
            key: uuid.v4(),
            name: 'Dumbbell Row',
            weight: '15',
            reps: '8',
            sets: '4'),
        Exercise(
            key: uuid.v4(),
            name: 'Lat Pulldown',
            weight: '60',
            reps: '8',
            sets: '3'),
        Exercise(
            key: uuid.v4(),
            name: 'Dumbbell Curl',
            weight: '10',
            reps: '10',
            sets: '3'),
      ],
    ),
    Workout(
      key: uuid.v4(),
      name: 'Legs',
      exercises: [
        Exercise(
            key: uuid.v4(),
            name: 'Barbell Squats',
            weight: '80',
            reps: '8',
            sets: '5'),
        Exercise(
            key: uuid.v4(),
            name: 'Leg Extensions',
            weight: '30',
            reps: '10',
            sets: '3'),
        Exercise(
            key: uuid.v4(),
            name: 'Leg Curl',
            weight: '20',
            reps: '10',
            sets: '3'),
        Exercise(
            key: uuid.v4(),
            name: 'Calf Raises',
            weight: '10',
            reps: '12',
            sets: '3'),
      ],
    ),
  ];

  // If there are workouts already in database, get that workout list
  // Otherwise, use default workouts
  void initializeWorkoutList() {
    if (currWorkoutsDb.previousDataExists()) {
      workoutList = currWorkoutsDb.readFromDatabase();
    } else {
      currWorkoutsDb.saveToDatabase(workoutList);
    }

    //loadHeatMap();
  }

  List<Workout> getWorkoutList() {
    return workoutList;
  }

  int numberOfExercisesInWorkout(String workoutName) {
    Workout relevantWorkout = getRelevantWorkout(workoutName);
    return relevantWorkout.exercises.length;
  }

  void addWorkout(String name) {
    // Adds new workout with blank list of exercises
    workoutList.add(Workout(key: uuid.v4(), name: name, exercises: []));

    notifyListeners();
    currWorkoutsDb.saveToDatabase(workoutList);
  }

  void deleteWorkout(String key) {
    workoutList.removeWhere((workout) => workout.key == key);

    notifyListeners();
    currWorkoutsDb.saveToDatabase(workoutList);
  }

  void addExercise(String workoutName, String exerciseName, String weight,
      String reps, String sets) {
    // Find the relevant workouts
    Workout relevantWorkout =
        workoutList.firstWhere((workout) => workout.name == workoutName);

    relevantWorkout.exercises.add(Exercise(
      key: uuid.v4(),
      name: exerciseName,
      weight: weight,
      reps: reps,
      sets: sets,
    ));

    notifyListeners();
    currWorkoutsDb.saveToDatabase(workoutList);
  }

  void deleteExercise(String workoutKey, String exerciseKey) {
    Workout relevantWorkout =
        workoutList.firstWhere((workout) => workout.key == workoutKey);

    relevantWorkout.exercises
        .removeWhere((exercise) => exercise.key == exerciseKey);

    notifyListeners();
    currWorkoutsDb.saveToDatabase(workoutList);
  }

  // User can check off each exercise
  void checkOffExercise(String workoutName, String exerciseName) {
    // Find the relevant exercise
    Exercise relevantExercise = getRelevantExercise(workoutName, exerciseName);

    // Check off boolean showing user finished this workout
    relevantExercise.isCompleted = !relevantExercise.isCompleted;

    notifyListeners();
    currWorkoutsDb.saveToDatabase(workoutList);
    // load heat map with new exercise activity
    //loadHeatMap();
  }

  // Returns relevant workout object given desired workout name
  Workout getRelevantWorkout(String workoutName) {
    Workout relevantWorkout =
        workoutList.firstWhere((workout) => workout.name == workoutName);
    return relevantWorkout;
  }

  // Returns relevant exercise object given desired exercise name
  Exercise getRelevantExercise(String workoutName, String exerciseName) {
    Workout relevantWorkout = getRelevantWorkout(workoutName);
    Exercise relevantExercise = relevantWorkout.exercises
        .firstWhere((exercise) => exercise.name == exerciseName);
    return relevantExercise;
  }

  // Check if any workout is active currently
  // Ensures no more than two workouts can be active at same time
  // True if a workout is active, false if not
  bool isWorkoutActive() {
    for (int i = 0; i < workoutList.length; i++) {
      if (workoutList[i].isActive) {
        return true;
      }
    }
    return false;
  }

  String getStartDate() {
    return currWorkoutsDb.getStartDate();
  }

}
