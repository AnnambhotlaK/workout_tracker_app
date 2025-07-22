import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise.dart';

class Workout {
  // Note: When defining a Workout, id is irrelevant. Firestore will generate this
  // field with the document ID. On reading it from DB, id is the Firestore doc ID.
  String id;
  String name;
  bool isActive;
  List<Exercise> exercises;
  String? userId;

  Workout({
    required this.id,
    required this.name,
    this.isActive = false,
    required this.exercises,
    this.userId,
    Timestamp? createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isActive': isActive,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create a Workout object from a Firestore DocumentSnapshot
  factory Workout.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      name: data['name'] ?? '',
      isActive: data['isActive'] ?? false,
      exercises: (data['exercises'] as List<dynamic>? ?? [])
          .map((exData) => Exercise.fromJson(exData as Map<String, dynamic>))
          .toList(),
      userId: data['userId'],
      createdAt: data['createdAt'] as Timestamp?
    );
  }
}

// OLD WORKOUT.DART
/*
import 'package:main/models/exercise.dart';
import 'package:hive/hive.dart';
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

*/
