import 'package:main/models/set.dart';
import 'package:hive/hive.dart';
part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise {

  @HiveField(0)
  final String key;

  @HiveField(1)
  final String jsonId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  final List<Set> sets;

  Exercise({
    required this.key,
    required this.jsonId,
    required this.name,
    this.isCompleted = false,
    required this.sets,
  });
}
