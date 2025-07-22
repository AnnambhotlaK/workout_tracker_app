// set.dart (simplified)
class Set {
  String id; // Could be generated
  String weight;
  String reps;
  bool isCompleted;

  Set({
    required this.id,
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'weight': weight,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }

  factory Set.fromJson(Map<String, dynamic> json) {
    return Set(
      id: json['id'] ?? '', // Handle how ID is managed
      weight: json['weight'] ?? '0',
      reps: json['reps'] ?? '0',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

/*
  Each exercise includes a list of sets
  Each set has a key, weight, number of reps, completed or not
import 'package:hive/hive.dart';

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
*/
