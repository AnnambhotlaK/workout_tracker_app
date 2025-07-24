import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/session.dart';
import '../services/firestore_service.dart';
import '../models/set.dart';

// Assume you have a way to get current userId (e.g., from an AuthService)
String currentUserId = "test_id"; // Replace with actual user ID logic

class SessionDataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Session> _sessions = [];
  String? _currentUserId; // Example: set this after login

  List<Session> get sessions => _sessions;

  // Update _currentUserId
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
    // User logged in, listen to sessions
    if (_currentUserId != null) {
      _listenToSessions();
    }
    // User not logged in, initialize with 0 sessions
    else {
      _sessions = [];
      notifyListeners();
    }
  }

  void _listenToSessions() {
    if (_currentUserId == null) {
      return;
    }
    _firestoreService.getSessions(_currentUserId!).listen((sessionsData) {
      _sessions = sessionsData;
      notifyListeners();
    }).onError((error) {
      print(
          'Error in session_data_provider.dart at _listenToSessions(): $error');
    });
  }

  // -- Session Methods --
  Future<void> addSession(Session session) async {
    if (_currentUserId == null) {
      return Future.error(
          'Error in session_data_provider.dart at addSession(): User not logged in');
    }
    session.userId = _currentUserId;
    await _firestoreService.addSession(_currentUserId!, session);
  }

  Future<void> updateSession(Session session) async {
    if (_currentUserId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at updatesession(): User not logged in');
    }
    await _firestoreService.updateSession(_currentUserId!, session);
  }

  Future<void> deleteSession(Session session) async {
    if (_currentUserId == null) {
      return Future.error(
          'Error in session_data_provider.dart at deletesession(): User not logged in');
    }
    await _firestoreService.deleteSession(_currentUserId!, session.id);
  }

  // -- Exercise Methods --

  Future<void> addExercise(Session session, Exercise exercise) async {
    if (_currentUserId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at addExercise(): User not logged in');
    }
    session.exercises.add(exercise);
    await _firestoreService.updateSession(_currentUserId!, session);
  }

  Future<void> updateExercise(Session session, Exercise exercise) async {
    if (_currentUserId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at updateExercise(): User not logged in');
    }
    final index = session.exercises.indexWhere((ex) => ex.id == exercise.id);
    if (index != -1) {
      session.exercises[index] = exercise;
      await _firestoreService.updateSession(_currentUserId!, session);
    } else {
      return Future.error(
          'Error in session_data_provider.dart at updateExercise(): Exercise not found in session');
    }
  }

  Future<void> deleteExercise(Session session, Exercise exercise) async {
    if (_currentUserId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at deleteExercise(): User not logged in');
    }
    try {
      session.exercises.remove(exercise);
    } catch (e) {
      return Future.error(
          'Error in session_data_provider.dart at deleteExercise(): $e');
    }
    await _firestoreService.updateSession(_currentUserId!, session);
  }

  // -- Set Methods --
  Future<void> addSet(Session session, Exercise exercise, Set set) async {
    if (_currentUserId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at addSet(): User not logged in');
    }
    final index = session.exercises.indexWhere((ex) => ex.id == exercise.id);
    if (index != -1) {
      session.exercises[index].sets.add(set);
      await _firestoreService.updateSession(_currentUserId!, session);
    } else {
      return Future.error(
          'Error in session_data_provider.dart at addSet(): Exercise not found in session');
    }
  }

  Future<void> updateSet(Session session, Exercise exercise, Set set) async {
    if (_currentUserId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at updateSet(): User not logged in');
    }
    final exerciseIndex =
        session.exercises.indexWhere((ex) => ex.id == exercise.id);
    if (exerciseIndex != -1) {
      final setIndex = exercise.sets.indexWhere((s) => s.id == set.id);
      if (setIndex != -1) {
        session.exercises[exerciseIndex].sets[setIndex] = set;
        await _firestoreService.updateSession(_currentUserId!, session);
      } else {
        return Future.error(
            'Error in session_data_provider.dart at updateSet(): Set not found in exercise');
      }
    } else {
      return Future.error(
          'Error in session_data_provider.dart at updateSet(): Exercise not found in session');
    }
  }

  Future<void> deleteSet(Session session, Exercise exercise, Set set) async {
    if (_currentUserId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at deleteExercise(): User not logged in');
    }
    final exerciseIndex =
        session.exercises.indexWhere((ex) => ex.id == exercise.id);
    if (exerciseIndex != -1) {
      try {
        session.exercises[exerciseIndex].sets.remove(set);
      } catch (e) {
        return Future.error(
            'Error in session_data_provider.dart at deleteExercise(): $e');
      }
    } else {
      return Future.error(
          'Error in session_data_provider.dart at deleteExercise(): Exercise not found in session');
    }
    await _firestoreService.updateSession(_currentUserId!, session);
  }

}
