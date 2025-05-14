import 'package:main/models/exercise.dart';

class Workout {
  final String key;
  final String name;
  final List<Exercise> exercises;
  // isActive is set to true when a workout is started
  bool isActive;

  Workout({
    required this.key,
    required this.name,
    required this.exercises,
    this.isActive = false,
  });
}
