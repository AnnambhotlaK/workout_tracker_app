// A running workout is an active exercise session
// Includes workout time, plus details on workout

import 'package:main/models/exercise.dart';

class Session {
  final String key;
  final String workoutName; // workout name
  final List<Exercise> exercises; // exercises in workout
  final DateTime dateCompleted; // date + time of completion

  Session({
    required this.key,
    required this.workoutName,
    required this.exercises,
    required this.dateCompleted,
  });

}