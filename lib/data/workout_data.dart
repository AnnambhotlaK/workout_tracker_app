// File for holding workout data and keeping code clean.

import 'package:flutter/material.dart';

import '../models/workout.dart';
import 'package:main/models/exercise.dart';

class WorkoutData extends ChangeNotifier{
  
  
  /*

    WORKOUT DATA STRUCTURE

    - List contains different workouts.
    - Each workout has a name and list of exercises.

  */

  List<Workout> workoutList = [
    // default workout
    Workout(name: 'Upper Body', exercises: [
      Exercise(
        name: 'Bicep Curls',
        weight: '15',
        reps: '10',
        sets: '3')
    ],
    ),
    // Followed by more workouts...
  ];

  // Getting list of workouts
  List<Workout> getWorkoutList() {
    return workoutList;
  }

  // Getting length of a workout
  int numberOfExercisesInWorkout(String workoutName) {
    Workout relevantWorkout = getRelevantWorkout(workoutName);
    return relevantWorkout.exercises.length;
  }

  // User can add workout
  void addWorkout() {
    // Adds new workout with blank list of exercises
    workoutList.add(Workout(name: 'Name', exercises: []));

    notifyListeners();
  }

  // User can add exercises
  void addExercise(String workoutName, String exerciseName, String weight, String reps, String sets) {
    // Find the relevant workouts
    Workout relevantWorkout = 
      workoutList.firstWhere((workout) => workout.name == workoutName);

    relevantWorkout.exercises.add(
      Exercise(
        name: exerciseName, 
        weight: weight, 
        reps: reps, 
        sets: sets,
        )
      );
    
    notifyListeners();
  }

  // User can check off each exercise
  void checkOffExercise(String workoutName, String exerciseName) {
    // Find the relevant exercise
    Exercise relevantExercise = getRelevantExercise(workoutName, exerciseName);

    // Check off boolean showing user finished this workout
    relevantExercise.isCompleted = !relevantExercise.isCompleted;

    notifyListeners();
  }


  // Returns relevant workout object given desired workout name
  Workout getRelevantWorkout(String workoutName) {
    Workout relevantWorkout = 
      workoutList.firstWhere((workout) => workout.name == workoutName);
    return relevantWorkout;
  }

  // Returns relevant exercise object given desired exercise name
  Exercise getRelevantExercise(String workoutName, String exerciseName) {
    // Find relevant workout first
    Workout relevantWorkout = getRelevantWorkout(workoutName);
    // Find relevant exercise
    Exercise relevantExercise = 
      relevantWorkout.exercises.firstWhere((exercise) => exercise.name == exerciseName);
    return relevantExercise;
  }
}