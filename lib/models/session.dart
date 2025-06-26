// A running workout is an active exercise session
// Includes workout time, plus details on workout

import 'package:main/models/exercise.dart';
import 'package:hive/hive.dart';
part 'session.g.dart';

@HiveType(typeId: 4)
class Session {
  @HiveField(0)
  final String key;
  @HiveField(1)
  final String workoutName; // workout name
  @HiveField(2)
  final DateTime dateCompleted; // date + time of completion
  @HiveField(3)
  final List<Exercise> exercises; // exercises in workout

  Session({
    required this.key,
    required this.workoutName,
    required this.exercises,
    required this.dateCompleted,
  });

}