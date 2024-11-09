import 'package:main/models/exercise.dart';

class Workout {
  final String key;
  final String name;
  final List<Exercise> exercises;

  Workout({required this.key, required this.name, required this.exercises});
}
