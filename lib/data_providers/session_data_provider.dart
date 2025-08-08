import 'dart:async';

import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/session.dart';
import '../services/firestore_service.dart';
import '../models/set.dart';
import 'package:week_number/iso.dart';
import 'package:intl/intl.dart';

class SessionDataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Session> _sessions = [];
  StreamSubscription? _sessionSubscription;

  String? _userId;
  String? get currentUserId => _userId;

  bool _isLoading = false;
  String? _error;

  // Gives value for display on date
  Map<DateTime, int>? heatMapDataset = {};
  // Used to key datetimes to the list of sessions completed on date
  Map<DateTime, List<Session>> heatMapSessionDataset = {};
  // Used to key a week to a list of sessions completed in that week
  Map<int, List<Session>> heatMapWeekDataset = {};
  bool _isLoadingSessions = false;

  SessionDataProvider(String? initialUserId,) {
    updateUser(initialUserId);
  }

  List<Session> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateUser(String? newUserId) {
    print(
        "SessionDataProvider: Updating user to $newUserId (previous: $_userId)");
    if (_userId == newUserId && _sessions.isNotEmpty && !_isLoading) {
      // Avoid unnecessary re-fetch if user is same and already loaded
      if (newUserId != null && _sessionSubscription == null) {
        // this means user is same, but subscription was lost (e.g. after logout then login of same user)
      } else {
        print(
            "SessionDataProvider: User is the same ($newUserId), no need to re-fetch if not empty and not loading.");
        // If already loaded for this user, no need to do much unless you want to force refresh.
        // If _sessionSubscription is null here despite having a newUserId, it means it was cancelled (e.g. logout)
        // and needs to be re-established.
        if (newUserId != null && _sessionSubscription == null) {
          // proceed to _listenToSessions
          _listenToSessions();
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
      _listenToSessions();
    } else {
      // User is null (logged out)
      _isLoading = false; // Not loading if no user
      notifyListeners(); // Notify that data is cleared and not loading
    }

  }

  void _listenToSessions() {
    if (_userId == null) {
      _sessions = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    // Cancel any existing subscription before starting a new one
    _sessionSubscription?.cancel();
    _sessionSubscription = _firestoreService.getSessions(_userId!).listen(
      (sessionsData) {
        _sessions = sessionsData;
        _isLoading = false;
        _error = null;
        _calculateHeatMapData();
        notifyListeners();
      },
      onError: (Object e) {
        print("SessionDataProvider: Error listening to sessions: $e");
        _isLoading = false;
        _error = "Failed to load sessions: $e";
        _sessions = [];
        _calculateHeatMapData();
        notifyListeners();
      },
    );
  }

  void _clearData() {
    print("SessionDataProvider: Calling _clearData");
    _sessionSubscription?.cancel();
    _sessionSubscription = null; // Important to nullify after cancel
    _sessions = [];
    heatMapDataset!.clear();
    heatMapSessionDataset.clear();
    heatMapWeekDataset.clear();
    _isLoading = true; // Set to true initially when clearing, will be set to false if no user or after load
    _error = null;
  }

  // -- Session Methods --
  Future<void> addSession(Session session) async {
    if (_userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at addSession(): User not logged in');
    }
    session.userId = _userId;
    await _firestoreService.addSession(_userId!, session);
  }

  Future<void> updateSession(Session session) async {
    if (_userId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at updatesession(): User not logged in');
    }
    await _firestoreService.updateSession(_userId!, session);
  }

  Future<void> deleteSession(Session session) async {
    if (_userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at deletesession(): User not logged in');
    }
    await _firestoreService.deleteSession(_userId!, session.id);
  }

  // -- Exercise Methods --

  Future<void> addExercise(Session session, Exercise exercise) async {
    if (_userId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at addExercise(): User not logged in');
    }
    session.exercises.add(exercise);
    await _firestoreService.updateSession(_userId!, session);
  }

  Future<void> updateExercise(Session session, Exercise exercise) async {
    if (_userId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at updateExercise(): User not logged in');
    }
    final index = session.exercises
        .indexWhere((ex) => ex.instanceId == exercise.instanceId);
    if (index != -1) {
      session.exercises[index] = exercise;
      await _firestoreService.updateSession(_userId!, session);
    } else {
      return Future.error(
          'Error in session_data_provider.dart at updateExercise(): Exercise not found in session');
    }
  }

  Future<void> deleteExercise(Session session, Exercise exercise) async {
    if (_userId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at deleteExercise(): User not logged in');
    }
    try {
      session.exercises.remove(exercise);
    } catch (e) {
      return Future.error(
          'Error in session_data_provider.dart at deleteExercise(): $e');
    }
    await _firestoreService.updateSession(_userId!, session);
  }

  // -- Set Methods --
  Future<void> addSet(Session session, Exercise exercise, Set set) async {
    if (_userId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at addSet(): User not logged in');
    }
    final index = session.exercises
        .indexWhere((ex) => ex.instanceId == exercise.instanceId);
    if (index != -1) {
      session.exercises[index].sets.add(set);
      await _firestoreService.updateSession(_userId!, session);
    } else {
      return Future.error(
          'Error in session_data_provider.dart at addSet(): Exercise not found in session');
    }
  }

  Future<void> updateSet(Session session, Exercise exercise, Set set) async {
    if (_userId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at updateSet(): User not logged in');
    }
    final exerciseIndex = session.exercises
        .indexWhere((ex) => ex.instanceId == exercise.instanceId);
    if (exerciseIndex != -1) {
      final setIndex = exercise.sets.indexWhere((s) => s.id == set.id);
      if (setIndex != -1) {
        session.exercises[exerciseIndex].sets[setIndex] = set;
        await _firestoreService.updateSession(_userId!, session);
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
    if (_userId == null || session.userId == null) {
      return Future.error(
          'Error in session_data_provider.dart at deleteExercise(): User not logged in');
    }
    final exerciseIndex = session.exercises
        .indexWhere((ex) => ex.instanceId == exercise.instanceId);
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
    await _firestoreService.updateSession(_userId!, session);
  }

  // -- Activity Methods --
  // Calculate and populate all heatmap related datasets from _sessions list
  void _calculateHeatMapData() {
    // Clear existing data
    heatMapDataset!.clear();
    heatMapSessionDataset.clear();
    heatMapWeekDataset.clear();

    if (_sessions.isEmpty) {
      // No sessions, heatmaps will be empty
      // Can call notifyListeners(), or rely on _listenToSessions for that.
      return;
    }

    // Otherwise, go through sessions and populate all heatmap related datasets
    for (Session session in _sessions) {
      // Normalize DateTime
      DateTime sessionDate = session.dateCompleted;
      DateTime normalizedDateKey =
          DateTime(sessionDate.year, sessionDate.month, sessionDate.day);

      // 1: Populate heatMapDataset, which counts sessions completed on datetime <DateTime, int>
      // If already exists, update with +1
      // If not, set to value 1
      heatMapDataset!.update(
        normalizedDateKey,
        (value) => value + 1,
        ifAbsent: () => 1,
      );

      // 2: Populate heatMapSessionDataset, which maps a specific DateTime to a list of Sessions <DateTime, List<Session>>
      heatMapSessionDataset.update(
        normalizedDateKey,
        (existingSessions) {
          existingSessions.add(session);
          return existingSessions;
        },
        ifAbsent: () => [session],
      );

      // 3: Populate heatMapWeekDataset, which lists all sessions completed in week <int, List<Session>>
      final weekNumber = normalizedDateKey.weekNumber;
      heatMapWeekDataset.update(
        weekNumber,
        (existingSessions) {
          existingSessions.add(session);
          return existingSessions;
        },
        ifAbsent: () => [session],
      );
    }
    print("HeatMapDataset calculated ${heatMapDataset?.length} entries");
    print(
        "HeatMapSessionDataset calculated ${heatMapSessionDataset.length} entries");
    print("HeatMapWeekDataset calculated ${heatMapWeekDataset.length} entries");
  }

  DateTime getStartDateForHeatMap() {
    if (heatMapDataset == null) {
      print("getStartDateForHeatMap: heatMapDataset is null!");
      return DateTime.now();
    }
    else if (heatMapDataset!.isEmpty) {
      print("getStartDateForHeatMap: heatMapDataset is empty!");
      return DateTime.now();
    }
    print("getStartDateForHeatMap: heatMapDataset is not empty!");
    List<DateTime> daysWithActivity = heatMapDataset!.keys.toList();
    daysWithActivity.sort((a, b) => a.compareTo(b));
    print(
        "getStartDateForHeatMap: starting date is: ${daysWithActivity.first}");
    return daysWithActivity.first.subtract(const Duration(days: 1));
  }

  void showActivityOnDay(BuildContext context, DateTime date) {
    DateTime normalizedDateKey = DateTime(date.year, date.month, date.day);
    List<Session> activityList = heatMapSessionDataset[normalizedDateKey] ?? [];

    if (activityList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sessions completed on this day.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sessions on ${DateFormat('MMMM d, yyyy').format(date)}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: activityList.length,
              itemBuilder: (BuildContext context, int innerIndex) {
                // Renamed index to avoid conflict
                Session session = activityList[innerIndex];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          session.workoutName, // From WorkoutSession model
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        // Displaying exercises performed in THIS session
                        if (session.exercises.isNotEmpty)
                          ...session.exercises.map((exercisePerf) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '- ${exercisePerf.name} | ${exercisePerf.sets.length} sets performed',
                              ),
                            );
                          }).toList()
                        else
                          const Text(
                              'No specific exercises detailed for this session log.'),
                        if (session.notes != null &&
                            session.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8.0),
                          Text('Notes: ${session.notes}'),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // -- Subscription and Data Handling --

  // Method to be called on logout via ChangeNotifierProxyProvider
  void clearDataOnLogout() {
    _sessionSubscription?.cancel();
    _sessions = [];
    heatMapDataset!.clear();
    heatMapSessionDataset.clear();
    heatMapWeekDataset.clear();
    _isLoadingSessions = false;
    // notifyListeners(); // ProxyProvider will rebuild, often not needed here
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }
}
