/* Database for saved workout sessions */
import 'package:hive_flutter/hive_flutter.dart';
import 'package:main/datetime/date_time.dart';
import 'package:main/models/exercise.dart';
import 'package:main/models/session.dart';
import 'package:main/models/set.dart';

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
    final setList = convertObjectToSetList(sessions);

    // for each session, add completion status on that day
    for (int i = 0; i < sessions.length; i++) {
      DateTime dateCompleted = sessions[i].dateCompleted;
      String yyyymmddCompleted = convertDateTimeToYYYYMMDD(dateCompleted);
      _myBox.put("COMPLETION_STATUS_$yyyymmddCompleted", 1);
    }

    // Save into hive
    _myBox.put("SESSIONS", sessionList);
    _myBox.put("EXERCISES", exerciseList);
    _myBox.put("SETS", setList);
  }

  // Read data, return list of workouts
  List<Session> readFromDatabase() {
    List<Session> mySavedSessions = [];

    List<List<String>> sessions =
        List<List<String>>.from(_myBox.get("SESSIONS"));
    final exerciseDetails = _myBox.get("EXERCISES");
    final setDetails = _myBox.get("SETS");

    // Create session objects
    for (int i = 0; i < sessions.length; i++) {
      // Each session has exercises
      List<Exercise> exercisesInSession = [];

      for (int j = 0; j < exerciseDetails[i].length; j++) {
        // Each exercise can have multiple sets
        List<Set> setsInEachExercise = [];

        for (int k = 0; k < setDetails[i][j].length; k++) {
          setsInEachExercise.add(
            Set(
                key: setDetails[i][j][k][0],
                weight: setDetails[i][j][k][1],
                reps: setDetails[i][j][k][2],
                isCompleted: setDetails[i][j][k][3] == 'true' ? true : false),
          );
        }

        exercisesInSession.add(
          Exercise(
              key: exerciseDetails[i][j][0],
              name: exerciseDetails[i][j][1],
              isCompleted: exerciseDetails[i][j][2] == 'true' ? true : false,
              //weight: exerciseDetails[i][j][2],
              //reps: exerciseDetails[i][j][3],
              sets: setsInEachExercise,
              ),
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
      [ [ ['biceps', 10kg, 10 reps, []], [another exercise] ], [ [lower body], [lower body] ] ]
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
          //exercisesInSession[j].weight,
          //exercisesInSession[j].reps,
          //exercisesInSession[j].sets,
          exercisesInSession[j].isCompleted.toString(),
        ],
      );
      individualSession.add(individualExercise);
    }
    exerciseList.add(individualSession);
  }
  return exerciseList;
}

// Convert sessions into list of all strings
// List of sessions (1d)
// Each workout is its own list (2d)
// Each exercise in each workout is its own list (3d)
// Each set in each exercise is its own list (4d)
// Example:
// Sessions: [ [key1, 'Push'], [key2, 'Pull'], []... ]
// Exercises: [ [ ['Bench', 10 reps, 100 lbs, 3 sets], []
// Sets: [ [ [[set1], [set2]], ] ]
List<List<List<List<String>>>> convertObjectToSetList(List<Session> sessions) {
  List<List<List<List<String>>>> setList = [];

  // Iterate over each Workout
  for (int i = 0; i < sessions.length; i++) {
    // In workout, iterate over each Exercise
    List<Exercise> exercisesInSession = sessions[i].exercises;
    List<List<List<String>>> individualSession = [];

    for (int j = 0; j < exercisesInSession.length; j++) {
      // In each exercise, iterate over the sets
      List<Set> setsInExercise = exercisesInSession[j].sets;
      List<List<String>> individualExercise = [];

      for (int k = 0; k < setsInExercise.length; k++) {
        List<String> individualSet = [];
        individualSet.addAll([
          setsInExercise[k].key,
          setsInExercise[k].weight,
          setsInExercise[k].reps,
          setsInExercise[k].isCompleted.toString(),
        ]);
        individualExercise.add(individualSet);
      }

      individualSession.add(individualExercise);
    }

    setList.add(individualSession);
  }
  return setList;
}
