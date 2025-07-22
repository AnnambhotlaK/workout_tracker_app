/*
import 'package:flutter/material.dart';
import 'package:main/curr_workout_data/curr_workouts_db.dart';
import 'package:uuid/uuid.dart';

import '../models/workout.dart';
import 'package:main/models/exercise.dart';
import 'package:main/models/set.dart';

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
      name: 'Chest, Triceps, & Shoulders',
      isActive: false,
      exercises: [
        Exercise(
            key: uuid.v4(),
            jsonId: 'Dumbbell_Bench_Press',
            name: 'Dumbbell Bench Press',
            isCompleted: false,
            sets: [
              Set(weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
            ]),
        Exercise(
            key: uuid.v4(),
            jsonId: 'Dumbbell_Shoulder_Press',
            name: 'Dumbbell Shoulder Press',
            isCompleted: false,
            sets: [
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
            ]),
        Exercise(
            key: uuid.v4(),
            jsonId: 'Side_Lateral_Raise',
            name: 'Side Lateral Raise',
            isCompleted: false,
            sets: [
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
            ]),
        Exercise(
            key: uuid.v4(),
            jsonId: 'Standing_Overhead_Barbell_Triceps_Extension',
            name: 'Standing Overhead Barbell Triceps Extension',
            isCompleted: false,
            sets: [
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
            ]),
      ],
    ),
    Workout(
      key: uuid.v4(),
      name: 'Back & Biceps',
      isActive: false,
      exercises: [
        Exercise(
            key: uuid.v4(),
            jsonId: 'Pullups',
            name: 'Pullups',
            isCompleted: false,
            sets: [
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
            ]),
        Exercise(
            key: uuid.v4(),
            jsonId: 'Bent_Over_Barbell_Row',
            name: 'Bent Over Barbell Row',
            isCompleted: false,
            sets: [
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
            ]),
        Exercise(
            key: uuid.v4(),
            jsonId: 'One_Arm_Lat_Pulldown',
            name: 'One Arm Lat Pulldown',
            isCompleted: false,
            sets: [
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
            ]),
        Exercise(
            key: uuid.v4(),
            jsonId: 'Seated_Dumbbell_Curl',
            name: 'Seated Dumbbell Curl',
            isCompleted: false,
            sets: [
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
            ]),
      ],
    ),
    Workout(
      key: uuid.v4(),
      name: 'Legs',
      isActive: false,
      exercises: [
        Exercise(
            key: uuid.v4(),
            jsonId: 'Barbell_Squat',
            name: 'Barbell Squat',
            isCompleted: false,
            sets: [
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
            ]),
        Exercise(
            key: uuid.v4(),
            jsonId: 'Leg_Extensions',
            name: 'Leg Extensions',
            isCompleted: false,
            sets: [
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
            ]),
        Exercise(
            key: uuid.v4(),
            jsonId: 'Lying_Leg_Curls',
            name: 'Lying Leg Curls',
            isCompleted: false,
            sets: [
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
            ]),
        Exercise(
            key: uuid.v4(),
            jsonId: 'Standing_Calf_Raises',
            name: 'Standing Calf Raises',
            isCompleted: false,
            sets: [
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
              Set(key: uuid.v4(), weight: '0', reps: '0', isCompleted: false),
            ]),
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
  }

  List<Workout> getWorkoutList() {
    return workoutList;
  }

  int numberOfExercisesInWorkout(String workoutKey) {
    return getRelevantWorkout(workoutKey).exercises.length;
  }

  int numberOfSetsInExercise(String workoutKey, String exerciseKey) {
    return getRelevantExercise(workoutKey, exerciseKey).sets.length;
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

  void addExercise(String workoutKey, String exerciseJsonId, String exerciseName) {
    // Find the relevant workouts
    Workout relevantWorkout = getRelevantWorkout(workoutKey);

    relevantWorkout.exercises.add(Exercise(
      key: uuid.v4(),
      jsonId: exerciseJsonId,
      name: exerciseName,
      sets: [],
    ));

    notifyListeners();
    currWorkoutsDb.saveToDatabase(workoutList);
  }

  void deleteExercise(String workoutKey, String exerciseKey) {
    Workout relevantWorkout = getRelevantWorkout(workoutKey);

    relevantWorkout.exercises
        .removeWhere((exercise) => exercise.key == exerciseKey);

    notifyListeners();
    currWorkoutsDb.saveToDatabase(workoutList);
  }

  // User can check off each exercise
  void checkOffExercise(String workoutKey, String exerciseKey) {
    // Find the relevant exercise
    Exercise relevantExercise = getRelevantExercise(workoutKey, exerciseKey);

    // Check off boolean showing user finished this workout
    relevantExercise.isCompleted = !relevantExercise.isCompleted;

    notifyListeners();
    currWorkoutsDb.saveToDatabase(workoutList);
  }

  void addSet(
      String workoutKey, String exerciseKey, String setWeight, String setReps) {
    Exercise relevantExercise = getRelevantExercise(workoutKey, exerciseKey);
    // Adds new set
    relevantExercise.sets.add(Set(
      key: uuid.v4(),
      weight: setWeight,
      reps: setReps,
      isCompleted: false,
    ));

    notifyListeners();
    currWorkoutsDb.saveToDatabase(workoutList);
  }

  void deleteSet(String workoutKey, String exerciseKey, String setKey) {
    Exercise relevantExercise = getRelevantExercise(workoutKey, exerciseKey);
    relevantExercise.sets.removeWhere((set) => set.key == setKey);

    notifyListeners();
    currWorkoutsDb.saveToDatabase(workoutList);
  }

  // User can check off each set
  void checkOffSet(String workoutKey, String exerciseKey, String setKey) {
    Set relevantSet = getRelevantSet(workoutKey, exerciseKey, setKey);
    relevantSet.isCompleted = !relevantSet.isCompleted;

    notifyListeners();
    currWorkoutsDb.saveToDatabase(workoutList);
  }

  // Returns relevant workout object given desired workout key
  Workout getRelevantWorkout(String workoutKey) {
    try {
      return workoutList.firstWhere((workout) => workout.key == workoutKey);
    } catch (e) {
      print(
          "Error (getRelevantWorkout): Workout with key '$workoutKey' not found in workout list");
      print(
          "Available workout keys: ${workoutList.map((w) => w.key).toList()}");
      rethrow;
    }
  }

  // Returns relevant exercise object given desired exercise key
  Exercise getRelevantExercise(String workoutKey, String exerciseKey) {
    Workout relevantWorkout = getRelevantWorkout(workoutKey);
    try {
      return relevantWorkout.exercises
          .firstWhere((exercise) => exercise.key == exerciseKey);
    } catch (e) {
      print(
          "Error (getRelevantExercise): Exercise with key '$exerciseKey' not found in workout '${relevantWorkout.name}");
      print(
          "Available exercise keys: ${relevantWorkout.exercises.map((e) => e.key).toList()}");
      rethrow;
    }
  }

  // Returns relevant set given relevant workout and exercise keys
  Set getRelevantSet(String workoutKey, String exerciseKey, String setKey) {
    Exercise relevantExercise = getRelevantExercise(workoutKey, exerciseKey);
    try {
      return relevantExercise.sets.firstWhere((set) => set.key == setKey);
    } catch (e) {
      print(
          "Error (getRelevantSet): Set with key '$setKey' not found in exercise '${relevantExercise.name}'.");
      print(
          "Available set keys: ${relevantExercise.sets.map((s) => s.key).toList()}");
      rethrow;
    }
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

  // Similar to isWorkoutActive, but actually gets workout
  // Returns String name if one active, empty string otherwise
  String getActiveWorkout() {
    for (int i = 0; i < workoutList.length; i++) {
      if (workoutList[i].isActive) {
        return workoutList[i].name;
      }
    }
    return "";
  }

  // Returns number of completed exercises in a workout
  int getNumCompletedExercises(Workout workout) {
    int sum = 0;
    for (int i = 0; i < workout.exercises.length; i++) {
      if (workout.exercises[i].isCompleted) {
        sum++;
      }
    }
    return sum;
  }

  void updateSetWeight(
      String workoutKey, String exerciseKey, String setKey, String newWeight) {
    try {
      Set relevantSet = getRelevantSet(workoutKey, exerciseKey, setKey);
      if (relevantSet.weight != newWeight) {
        relevantSet.weight = newWeight;
        currWorkoutsDb.saveToDatabase(workoutList);
        notifyListeners();
        print("Updated weight for set '$setKey' to '$newWeight'");
      }
    } catch (e) {
      print("Error updating weight: $e");
    }
  }

  void updateSetReps(
      String workoutKey, String exerciseKey, String setKey, String newReps) {
    try {
      Set relevantSet = getRelevantSet(
          workoutKey, exerciseKey, setKey); // Use your existing getter
      if (relevantSet.reps != newReps) {
        relevantSet.reps = newReps;
        currWorkoutsDb
            .saveToDatabase(workoutList); // Your method to save to Hive
        notifyListeners(); // Update UI
        print("Updated reps for set '$setKey' to '$newReps'");
      }
    } catch (e) {
      print("Failed to update set reps: $e");
      // Handle error appropriately
    }
  }
}
*/
