/*
  Exercise objects as stored/read from data.json
  Only select data from these objects will be included in
  workout/session data
*/
import 'dart:convert'; // for jsonEncode/Decode

class Exercise {
  final String id; // "Pushups"
  final String name; // "Pushups"
  final String? force; // "push"
  final String level; // "beginner"
  final String? mechanic; // "compound"
  final String? equipment; // "body only"
  final List<String> primaryMuscles; // ["chest"]
  final List<String> secondaryMuscles; // ["triceps"]
  final List<String> instructions; // Strings separated by lines
  final String category; // "strength"
  final List<String> images; // Paths to images in your assets
  final bool isCustom; // In this case, false

  Exercise({
    required this.id,
    required this.name,
    this.force,
    required this.level,
    this.mechanic,
    this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.category,
    required this.images,
    this.isCustom = false,
  });

  // Factory to get an Exercise from JSON
  factory Exercise.fromJson(Map<String, dynamic> json, {bool isCustomOrigin = false}) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      force: json['force'] as String?,
      level: json['level'] as String,
      mechanic: json['mechanic'] as String?,
      equipment: json['equipment'] as String?,
      primaryMuscles: List<String>.from(json['primaryMuscles'] as List),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] as List),
      instructions: List<String>.from(json['instructions'] as List),
      category: json['category'] as String,
      images: List<String>.from(json['images'] as List),
      isCustom: (json['isCustom'] as int? ?? (isCustomOrigin ? 1 : 0)) == 1, // Handle if 'isCustom' comes from DB or initial JSON
    );
  }

  // Function to map JSON fields to SQLite column names
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'force': force,
      'level': level,
      'mechanic': mechanic,
      'equipment': equipment,
      // SQLite doesn't directly store lists. You'll need to serialize them.
      // Common practice is to store them as JSON strings.
      'primaryMuscles': jsonEncode(primaryMuscles),
      'secondaryMuscles': jsonEncode(secondaryMuscles),
      'instructions': jsonEncode(instructions),
      'category': category,
      'images': jsonEncode(images),
      'isCustom': isCustom ? 1 : 0,
    };
  }

  // Factory to create an Exercise from a database map (SQLite row)
  factory Exercise.fromDbMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      force: map['force'] as String?,
      level: map['level'] as String,
      mechanic: map['mechanic'] as String?,
      equipment: map['equipment'] as String?,
      primaryMuscles: List<String>.from(jsonDecode(map['primaryMuscles'] as String)),
      secondaryMuscles: List<String>.from(jsonDecode(map['secondaryMuscles'] as String)),
      instructions: List<String>.from(jsonDecode(map['instructions'] as String)),
      category: map['category'] as String,
      images: List<String>.from(jsonDecode(map['images'] as String)),
      isCustom: (map['isCustom'] as int? ?? 0) == 1,
    );
  }
}