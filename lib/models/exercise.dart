// exercise.dart (simplified)
import 'set.dart'; // Your updated Set model

class Exercise {
  String id; // Could be generated or use a predefined ID if from a master list
  String name;
  bool isCompleted; // This might be session-specific, consider if it belongs here or in WorkoutSession
  List<Set> sets;

  Exercise({
    required this.id,
    required this.name,
    this.isCompleted = false,
    required this.sets,
  });

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Often not stored as a field if it's the document ID in a subcollection
      'name': name,
      'isCompleted': isCompleted, // Again, consider if this is session-specific
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '', // Handle how ID is managed
      name: json['name'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      sets: (json['sets'] as List<dynamic>? ?? [])
          .map((setData) => Set.fromJson(setData as Map<String, dynamic>))
          .toList(),
    );
  }
}


/*
import 'package:main/models/set.dart';
import 'package:hive/hive.dart';

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
*/