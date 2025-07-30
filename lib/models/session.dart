import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise.dart';

class Session {
  String id; // Added by firestore
  String? userId;
  String workoutId; // "Foreign key" for Firestore
  String workoutName; // Denormalized
  DateTime dateCompleted;
  Duration? length;
  String? notes;
  List<Exercise> exercises;
  Timestamp? createdAt;

  Session({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.workoutName,
    required this.dateCompleted,
    this.length,
    this.notes,
    required this.exercises,
    required this.createdAt,
});

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'workoutId': workoutId,
    'workoutName': workoutName,
    'dateCompleted': Timestamp.fromDate(dateCompleted),
    'length': length, // All durations can get encoded/decoded as seconds
    'notes': notes,
    'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory Session.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    return Session(
      id: doc.id,
      userId: data['userId'] ?? '',
      workoutId: data['workoutId'] ?? '',
      workoutName: data['workoutName'] ?? '',
      dateCompleted: (data['dateCompleted'] as Timestamp).toDate() ?? Timestamp.now().toDate(),
      length: data['length'] != null ? Duration(seconds: data['length']) : null,
      notes: data['notes'] ?? '',
      exercises: (data['exercises'] as List<dynamic>? ?? [])
          .map((exData) => Exercise.fromJson(exData as Map<String, dynamic>))
          .toList(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}