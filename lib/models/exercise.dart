// exercise.dart (simplified)
import 'set.dart'; // Your updated Set model

class Exercise {
  String instanceId; // instanceId is the specific id for this exercise
  String jsonId; // jsonId is the id that ties this exercise to an exercise from data.json
  String name;
  //bool isCompleted; // This might be session-specific, consider if it belongs here or in WorkoutSession
  List<Set> sets;

  Exercise({
    required this.instanceId,
    required this.jsonId,
    required this.name,
    //this.isCompleted = false,
    required this.sets,
  });

  Map<String, dynamic> toJson() {
    return {
      'instanceId' : instanceId,
      'jsonId': jsonId,
      'name': name,
      //'isCompleted': isCompleted, // Again, consider if this is session-specific
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      instanceId: json['instanceId'] ?? '',
      jsonId: json['jsonId'] ?? '',
      name: json['name'] ?? '',
      //isCompleted: json['isCompleted'] ?? false,
      sets: (json['sets'] as List<dynamic>? ?? [])
          .map((setData) => Set.fromJson(setData as Map<String, dynamic>))
          .toList(),
    );
  }
}