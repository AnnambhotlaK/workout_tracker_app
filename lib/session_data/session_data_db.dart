/* Database for saved workout sessions */
import 'package:hive_flutter/hive_flutter.dart';
import 'package:main/datetime/date_time.dart';
import 'package:main/models/exercise.dart';
import 'package:main/models/workout.dart';
import 'package:main/models/session.dart';

class HiveDatabase {
  final _myBox = Hive.box('session_database');

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

  // Save a session to the database
  void saveToDatabase(List<Session> sessions) {
    // convert workout objects to String lists
    final sessionList = convertObjectToSessionList(sessions);
    final exerciseList = convertObjectToExerciseList(sessions);

    // for each session, add completion status on that day
    for (int i = 0; i < sessions.length; i++) {
      DateTime dateCompleted = sessions[i].dateCompleted;
      String yyyymmddCompleted = convertDateTimeToYYYYMMDD(dateCompleted);
      _myBox.put("COMPLETION_STATUS_$yyyymmddCompleted", 1);
    }

    // Save into hive
    _myBox.put("SESSIONS", sessionList);
    _myBox.put("EXERCISES", exerciseList);
  }

  // Read data, return list of workouts
  List<Session> readFromDatabase() {
    List<Session> mySavedSessions = [];

    List<List<String>> sessions =
    List<List<String>>.from(_myBox.get("SESSIONS"));
    final exerciseDetails = _myBox.get("EXERCISES");

    // Create session objects
    for (int i = 0; i < sessions.length; i++) {
      // Each session has exercises
      List<Exercise> exercisesInSession = [];

      for (int j = 0; j < exerciseDetails[i].length; j++) {
        exercisesInSession.add(
          Exercise(
              key: exerciseDetails[i][j][0],
              name: exerciseDetails[i][j][1],
              weight: exerciseDetails[i][j][2],
              reps: exerciseDetails[i][j][3],
              sets: exerciseDetails[i][j][4],
              isCompleted: exerciseDetails[i][j][5] == 'true' ? true : false),
        );
      }

      // Create individual workout
      Session session = Session(
          key: sessions[i][0],
          workoutName: sessions[i][1],
          exercises: exercisesInSession,
          dateCompleted: DateTime.parse(sessions[i][2]),
      );

      // Add session to list
      mySavedSessions.add(session);
    }
    // return final list of saved workouts
    return mySavedSessions;
  }

  // Return workout completion status on date yyyymmdd
  int getCompletionStatus(String yyyymmdd) {
    // returns 0 or 1, if null then return 0
    int completionStatus = _myBox.get("COMPLETION_STATUS_$yyyymmdd") ?? 0;
    return completionStatus;
  }

} // end class

  // Convert session list into list of list of strings
  // [ upperBody, lowerBody ]
  List<List<String>> convertObjectToSessionList(List<Session> sessions) {
    List<List<String>> sessionList = [
      // [upperbody, lowerbody]
    ];

    // Includes all elements of session EXCEPT exercises
    for (int i = 0; i < sessions.length; i++) {
      sessionList.add([
        sessions[i].key,
        sessions[i].workoutName,
        convertDateTimeToYYYYMMDD(sessions[i].dateCompleted)
      ]);
    }

    return sessionList;
  }

// Convert exercise objects in each session object into lists
// List of sessions (1d)
// Each session includes a list of exercises (2d)
// Each exercise is a list of exercise features (3d)
  List<List<List<String>>> convertObjectToExerciseList(List<Session> sessions) {
    List<List<List<String>>> exerciseList = [
      /*
        [upperBody, lowerBody]
        [ [ ['biceps', 10kg, 10 reps, 3 sets], [another exercise] ], [ [lower body], [lower body] ] ]
      */
    ];

    // Go through each workout
    for (int i = 0; i < sessions.length; i++) {
      List<Exercise> exercisesInSession = sessions[i].exercises;

      List<List<String>> individualSession = [
        // [ ['biceps', 10 kg, 10 reps, 3 sets] ]
      ];

      // Go through each exercise in exerciseList
      for (int j = 0; j < exercisesInSession.length; j++) {
        List<String> individualExercise = [
          // ['biceps', 10 kg, 10 reps, 3 sets]
        ];
        individualExercise.addAll(
          [
            exercisesInSession[j].key,
            exercisesInSession[j].name,
            exercisesInSession[j].weight,
            exercisesInSession[j].reps,
            exercisesInSession[j].sets,
            exercisesInSession[j].isCompleted.toString(),
          ],
        );
        individualSession.add(individualExercise);
      }
      exerciseList.add(individualSession);
    }
    return exerciseList;
  }