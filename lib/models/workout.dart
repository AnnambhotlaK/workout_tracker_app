// Represents complete workout sessions made up of exercises


import 'package:main/models/exercise.dart';

class Workout {
  final String name;
  final List<Exercise> exercises;

  Workout({required this.name, required this.exercises});
}