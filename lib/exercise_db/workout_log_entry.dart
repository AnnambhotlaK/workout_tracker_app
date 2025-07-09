import 'package:uuid/uuid.dart'; // For generating unique IDs

const _uuid = Uuid();

class WorkoutLogEntry {
  final String id; // Unique log entry ID
  final String exerciseId; // Foreign key to the JSONExercise table
  final String exerciseName; // Denormalized for easier chart/list display
  final DateTime date; // The date and time the set/exercise was performed
  final double weight; // Weight lifted for this entry
  final int reps; // Repetitions performed
  // Optional: You could add more fields here if needed, e.g.:
  // final int? sets; // If logging a summary of all sets for an exercise in one entry
  // final String? notes;
  // final int? rpe; // Rate of Perceived Exertion

  WorkoutLogEntry({
    String? id, // Allow providing an ID, otherwise generate one
    required this.exerciseId,
    required this.exerciseName,
    required this.date,
    required this.weight,
    required this.reps,
  }) : id = id ?? _uuid.v4(); // Generate a v4 UUID if no ID is provided

  // Method to convert a WorkoutLogEntry instance to a Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'logId': id, // Using 'logId' as the column name in the DB example
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'date': date.toIso8601String(), // Store dates as ISO 8601 strings
      'weight': weight,
      'reps': reps,
    };
  }

  // Factory constructor to create a WorkoutLogEntry from a Map (from SQLite)
  factory WorkoutLogEntry.fromMap(Map<String, dynamic> map) {
    return WorkoutLogEntry(
      id: map['logId'] as String, // Assuming 'logId' is the column name
      exerciseId: map['exerciseId'] as String,
      exerciseName: map['exerciseName'] as String,
      date: DateTime.parse(map['date'] as String), // Parse ISO 8601 string back to DateTime
      weight: map['weight'] as double,
      reps: map['reps'] as int,
    );
  }

  // Optional: For easier debugging or logging
  @override
  String toString() {
    return 'WorkoutLogEntry(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, date: $date, weight: $weight, reps: $reps)';
  }

  // Optional: Implement equality and hashCode if you plan to store these in Sets or use them as Map keys
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkoutLogEntry &&
        other.id == id &&
        other.exerciseId == exerciseId &&
        other.exerciseName == exerciseName &&
        other.date == date &&
        other.weight == weight &&
        other.reps == reps;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    exerciseId.hashCode ^
    exerciseName.hashCode ^
    date.hashCode ^
    weight.hashCode ^
    reps.hashCode;
  }
}
