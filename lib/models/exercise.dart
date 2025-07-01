import 'package:main/models/set.dart';
import 'package:hive/hive.dart';
part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise {

  @HiveField(0)
  final String key;

  @HiveField(1)
  final String name;
  //final String weight;
  //final String reps;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  final List<Set> sets;

  Exercise({
    required this.key,
    required this.name,
    //required this.weight,
    //required this.reps
    this.isCompleted = false,
    required this.sets,
  });
}
