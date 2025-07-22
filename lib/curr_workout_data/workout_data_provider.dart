import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/firestore_service.dart';
import '../models/workout.dart';
import '../models/set.dart';

// Assume you have a way to get current userId (e.g., from an AuthService)
String currentUserId = "test_id"; // Replace with actual user ID logic

class WorkoutDataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Workout> _workouts = [];
  String? _currentUserId; // Example: set this after login

  List<Workout> get workouts => _workouts;

  // Update _currentUserId
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
    // User logged in, listen to workouts
    if (_currentUserId != null) {
      _listenToWorkouts();
    }
    // User not logged in, initialize with 0 workouts
    else {
      _workouts = [];
      notifyListeners();
    }
  }

  void _listenToWorkouts() {
    if (_currentUserId == null) {
      return;
    }
    _firestoreService.getWorkouts(_currentUserId!).listen((workoutsData) {
      _workouts = workoutsData;
      notifyListeners();
    }).onError((error) {
      print(
          'Error in workout_data_provider.dart at _listenToWorkouts(): $error');
    });
  }

  Workout? getActiveWorkout() {
    for (Workout workout in _workouts) {
      if (workout.isActive) {
        return workout;
      }
    }
    return null;
  }

  // -- Workout Methods --

  Future<void> addWorkout(Workout workout) async {
    if (_currentUserId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at addWorkout(): User not logged in');
    }
    workout.userId = _currentUserId;
    await _firestoreService.addWorkout(_currentUserId!, workout);
  }

  Future<void> updateWorkout(Workout workout) async {
    if (_currentUserId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at updateWorkout(): User not logged in');
    }
    await _firestoreService.updateWorkout(_currentUserId!, workout);
  }

  Future<void> deleteWorkout(Workout workout) async {
    if (_currentUserId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at deleteWorkout(): User not logged in');
    }
    await _firestoreService.deleteWorkout(_currentUserId!, workout.id);
  }

  // -- Exercise Methods --

  Future<void> addExercise(Workout workout, Exercise exercise) async {
    if (_currentUserId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at addExercise(): User not logged in');
    }
    workout.exercises.add(exercise);
    await _firestoreService.updateWorkout(_currentUserId!, workout);
  }

  Future<void> updateExercise(Workout workout, Exercise exercise) async {
    if (_currentUserId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at updateExercise(): User not logged in');
    }
    final index = workout.exercises.indexWhere((ex) => ex.id == exercise.id);
    if (index != -1) {
      workout.exercises[index] = exercise;
      await _firestoreService.updateWorkout(_currentUserId!, workout);
    } else {
      return Future.error(
          'Error in workout_data_provider.dart at updateExercise(): Exercise not found in workout');
    }
  }

  Future<void> deleteExercise(Workout workout, Exercise exercise) async {
    if (_currentUserId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at deleteExercise(): User not logged in');
    }
    try {
      workout.exercises.remove(exercise);
    } catch (e) {
      return Future.error(
          'Error in workout_data_provider.dart at deleteExercise(): $e');
    }
    await _firestoreService.updateWorkout(_currentUserId!, workout);
  }

  // -- Set Methods --
  Future<void> addSet(Workout workout, Exercise exercise, Set set) async {
    if (_currentUserId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at addSet(): User not logged in');
    }
    final index = workout.exercises.indexWhere((ex) => ex.id == exercise.id);
    if (index != -1) {
      workout.exercises[index].sets.add(set);
      await _firestoreService.updateWorkout(_currentUserId!, workout);
    } else {
      return Future.error(
          'Error in workout_data_provider.dart at addSet(): Exercise not found in workout');
    }
  }

  Future<void> updateSet(Workout workout, Exercise exercise, Set set) async {
    if (_currentUserId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at updateSet(): User not logged in');
    }
    final exerciseIndex = workout.exercises.indexWhere((ex) => ex.id == exercise.id);
    if (exerciseIndex != -1) {
      final setIndex = exercise.sets.indexWhere((s) => s.id == set.id);
      if (setIndex != -1) {
        workout.exercises[exerciseIndex].sets[setIndex] = set;
        await _firestoreService.updateWorkout(_currentUserId!, workout);
      }
      else {
        return Future.error(
            'Error in workout_data_provider.dart at updateSet(): Set not found in exercise');
      }
    }
    else {
      return Future.error(
          'Error in workout_data_provider.dart at updateSet(): Exercise not found in workout');
    }
  }

  Future<void> deleteSet(Workout workout, Exercise exercise, Set set) async {
    if (_currentUserId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at deleteExercise(): User not logged in');
    }
    final exerciseIndex = workout.exercises.indexWhere((ex) => ex.id == exercise.id);
    if (exerciseIndex != -1) {
      try {
        workout.exercises[exerciseIndex].sets.remove(set);
      }
      catch (e) {
        return Future.error(
            'Error in workout_data_provider.dart at deleteExercise(): $e');
      }
    }
    else {
      return Future.error(
          'Error in workout_data_provider.dart at deleteExercise(): Exercise not found in workout');
    }
    await _firestoreService.updateWorkout(_currentUserId!, workout);
  }
}
