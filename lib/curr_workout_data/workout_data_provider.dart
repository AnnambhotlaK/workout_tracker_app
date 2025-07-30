import 'dart:async';

import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/firestore_service.dart';
import '../models/workout.dart';
import '../models/set.dart';

class WorkoutDataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Workout> _workouts = [];
  StreamSubscription? _workoutSubscription;

  final String? _userId; // Passed from ChangeNotifierProxyProvider in main.dart
  String? get currentUserId => _userId; // Getter for external access

  bool _isLoading = false;
  String? _error;

  WorkoutDataProvider(this._userId) {
    print("WorkoutDataProvider initialized with userId: $_userId");
    if (_userId != null) {
      _listenToWorkouts();
    }
    else {
      _workouts = [];
    }
  }

  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _listenToWorkouts() {
    if (_userId == null) {
      _workouts = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    // Cancel any existing subscription before starting a new one
    _workoutSubscription?.cancel();
    _workoutSubscription = _firestoreService.getWorkouts(_userId!).listen(
          (workoutsData) {
        _workouts = workoutsData;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        print("WorkoutDataProvider: Error listening to workouts: $e");
        _isLoading = false;
        _error = "Failed to load workouts: $e";
        _workouts = [];
        notifyListeners();
      },
    );
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
    if (_userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at addWorkout(): User not logged in');
    }
    workout.userId = _userId;
    await _firestoreService.addWorkout(_userId!, workout);
  }

  Future<void> updateWorkout(Workout workout) async {
    if (_userId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at updateWorkout(): User not logged in');
    }
    await _firestoreService.updateWorkout(_userId!, workout);
  }

  Future<void> deleteWorkout(Workout workout) async {
    if (_userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at deleteWorkout(): User not logged in');
    }
    await _firestoreService.deleteWorkout(_userId!, workout.id);
  }

  // -- Exercise Methods --

  Future<void> addExercise(Workout workout, Exercise exercise) async {
    if (_userId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at addExercise(): User not logged in');
    }
    workout.exercises.add(exercise);
    await _firestoreService.updateWorkout(_userId!, workout);
  }

  Future<void> updateExercise(Workout workout, Exercise exercise) async {
    if (_userId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at updateExercise(): User not logged in');
    }
    final index = workout.exercises.indexWhere((ex) => ex.instanceId == exercise.instanceId);
    if (index != -1) {
      workout.exercises[index] = exercise;
      await _firestoreService.updateWorkout(_userId!, workout);
    } else {
      return Future.error(
          'Error in workout_data_provider.dart at updateExercise(): Exercise not found in workout');
    }
  }

  Future<void> deleteExercise(Workout workout, Exercise exercise) async {
    if (_userId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at deleteExercise(): User not logged in');
    }
    try {
      workout.exercises.remove(exercise);
    } catch (e) {
      return Future.error(
          'Error in workout_data_provider.dart at deleteExercise(): $e');
    }
    await _firestoreService.updateWorkout(_userId!, workout);
  }

  // -- Set Methods --
  Future<void> addSet(Workout workout, Exercise exercise, Set set) async {
    if (_userId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at addSet(): User not logged in');
    }
    final index = workout.exercises.indexWhere((ex) => ex.instanceId == exercise.instanceId);
    if (index != -1) {
      workout.exercises[index].sets.add(set);
      await _firestoreService.updateWorkout(_userId!, workout);
    } else {
      return Future.error(
          'Error in workout_data_provider.dart at addSet(): Exercise not found in workout');
    }
  }

  Future<void> updateSet(Workout workout, Exercise exercise, Set set) async {
    if (_userId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at updateSet(): User not logged in');
    }
    final exerciseIndex = workout.exercises.indexWhere((ex) => ex.instanceId == exercise.instanceId);
    if (exerciseIndex != -1) {
      final setIndex = exercise.sets.indexWhere((s) => s.id == set.id);
      if (setIndex != -1) {
        workout.exercises[exerciseIndex].sets[setIndex] = set;
        await _firestoreService.updateWorkout(_userId!, workout);
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
    if (_userId == null || workout.userId == null) {
      return Future.error(
          'Error in workout_data_provider.dart at deleteExercise(): User not logged in');
    }
    final exerciseIndex = workout.exercises.indexWhere((ex) => ex.instanceId == exercise.instanceId);
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
    await _firestoreService.updateWorkout(_userId!, workout);
  }

  // -- Subscription and Data Handling --
  void clearDataOnLogout() {
    print("WorkoutDataProvider: Clearing data on logout!");
    _workouts = [];
    _isLoading = false;
    _error = null;
    _workoutSubscription?.cancel();
  }

  @override
  void dispose() {
    print("WorkoutDataProvider: Disposing.");
    _workoutSubscription?.cancel();
    super.dispose();
  }
}
