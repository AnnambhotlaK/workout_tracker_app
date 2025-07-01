/*
  Each exercise includes a list of sets
  Each set has a key, weight, number of reps, completed or not
 */
import 'package:hive/hive.dart';
part 'set.g.dart'; // Will be generated

@HiveType(typeId: 2)
class Set {
  @HiveField(0)
  final String key;

  @HiveField(1)
  String weight;

  @HiveField(2)
  String reps;

  @HiveField(3)
  bool isCompleted;

  Set({
    required this.key,
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });
}
