import 'package:main/models/exercise.dart';

class Workout {
  final String key;
  final String name;
  // isActive is set to true when a workout is started
  bool isActive;
  final List<Exercise> exercises;

  Workout({
    required this.key,
    required this.name,
    this.isActive = false,
    required this.exercises,
  });
}
