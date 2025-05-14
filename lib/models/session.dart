// A running workout is an active exercise session
// Includes workout time, plus details on workout

import 'package:main/models/exercise.dart';
import 'dart:async';

class Session {
  final String workoutName; // workout name
  final List<Exercise> exercises; // exercises in workout
  final Stopwatch time = Stopwatch(); // time elapsed for workout

  Session({
    required this.workoutName,
    required this.exercises,
  });

}