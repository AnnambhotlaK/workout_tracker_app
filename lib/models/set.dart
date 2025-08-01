// set.dart (simplified)
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Set {
  final String id; // Could be generated
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
      'id': id,
      'weight': weight,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }

  factory Set.fromJson(Map<String, dynamic> json) {
    return Set(
      id: json['id'] ?? uuid.v4(), // Handle how ID is managed
      weight: json['weight'] ?? '0',
      reps: json['reps'] ?? '0',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
