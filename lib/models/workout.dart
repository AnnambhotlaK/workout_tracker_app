import 'package:main/models/exercise.dart';
import 'package:hive/hive.dart';
part 'workout.g.dart';
@HiveType(typeId: 0)
class Workout {

  @HiveField(0)
  final String key;

  @HiveField(1)
  final String name;
  // isActive is set to true when a workout is started
  @HiveField(2)
  bool isActive;

  @HiveField(3)
  final List<Exercise> exercises;

  Workout({
    required this.key,
    required this.name,
    this.isActive = false,
    required this.exercises,
  });
}
