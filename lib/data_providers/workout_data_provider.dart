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

  String? _userId; // Passed from ChangeNotifierProxyProvider in main.dart
  String? get currentUserId => _userId; // Getter for external access

  bool _isLoading = false;
  String? _error;

  WorkoutDataProvider(String? initialUserId) {
    updateUser(initialUserId);
  }

  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateUser(String? newUserId) {
    print(
        "WorkoutDataProvider: Updating user to $newUserId (previous: $_userId)");
    if (_userId == newUserId && _workouts.isNotEmpty && !_isLoading) {
      // Avoid unnecessary re-fetch if user is same and already loaded
      if (newUserId != null && _workoutSubscription == null) {
        // this means user is same, but subscription was lost (e.g. after logout then login of same user)
      } else {
        print(
            "WorkoutDataProvider: User is the same ($newUserId), no need to re-fetch if not empty and not loading.");
        // If already loaded for this user, no need to do much unless you want to force refresh.
        // If _sessionSubscription is null here despite having a newUserId, it means it was cancelled (e.g. logout)
        // and needs to be re-established.
        if (newUserId != null && _workoutSubscription == null) {
          // proceed to _listenToSessions
          _listenToWorkouts();
        }
        else if (newUserId == null) {
          // User logged out, clear data
          _clearData();
          notifyListeners(); // Notify UI that data is cleared
          return;
        }
        else {
          return; // Already good for this user
        }
      }
    }

    _userId = newUserId;
    _clearData(); // Clear old user's data before fetching for new user

    if (_userId != null) {
      _isLoading = true; // Set loading state for the new user
      // No need to notifyListeners() here for isLoading, _listenToSessions will handle it
      _listenToWorkouts();
    } else {
      // User is null (logged out)
      _isLoading = false; // Not loading if no user
      notifyListeners(); // Notify that data is cleared and not loading
    }

  }



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

  void _clearData() {
    print("WorkoutDataProvider: Calling _clearData");
    _workoutSubscription?.cancel();
    _workoutSubscription = null; // Important to nullify after cancel
    _workouts = [];
    _isLoading = true; // Set to true initially when clearing, will be set to false if no user or after load
    _error = null;
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
