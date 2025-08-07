/*
  Displays popup allowing the user to
  define and add a new exercise to the database
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../exercise_db/json_exercise.dart';

const uuid = Uuid();

// --- Choices for exercise creation (user limited to properties in data.json ---
const List<String> exerciseForceOptions = [
  'pull',
  'push',
  'static',
  'hinge',
  'other'
];
const List<String> exerciseLevelOptions = [
  'beginner',
  'intermediate',
  'expert'
];
const List<String> exerciseMechanicOptions = [
  'compound',
  'isolation',
  'isometric',
  'other'
];
const List<String> exerciseEquipmentOptions = [
  'dumbbell',
  'barbell',
  'body only',
  'machine',
  'kettlebells',
  'bands',
  'cable',
  'other'
];
const List<String> primaryMuscleOptions = [
  // Example, expand this significantly
  'biceps', 'triceps', 'chest', 'back', 'shoulders', 'quadriceps', 'hamstrings',
  'glutes', 'calves', 'abdominals', 'forearms'
];
const List<String> secondaryMuscleOptions = [
  ...primaryMuscleOptions,
  'none'
]; // Can reuse primary or have 'none'
const List<String> exerciseCategoryOptions = [
  'strength',
  'powerlifting',
  'olympic weightlifting',
  'strongman',
  'cardio',
  'stretching'
];

class ExerciseAdder extends StatefulWidget {
  const ExerciseAdder({super.key});

  @override
  State<ExerciseAdder> createState() => _ExerciseAdderState();
}

class _ExerciseAdderState extends State<ExerciseAdder> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();

  // Selected values for dropdown menus
  String? _selectedForce;
  String? _selectedLevel;
  String? _selectedMechanic;
  String? _selectedEquipment;
  String? _selectedCategory;
  List<String> _selectedPrimaryMuscles = [];
  List<String> _selectedSecondaryMuscles = [];

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomExercise() async {
    // Save formfields if any valid
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
    // Basic validation for dropdowns/multi-selects
    if (_selectedLevel == null || _selectedPrimaryMuscles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please fill all required fields (Level, Category, Primary Muscles).')),
      );
      return;
    }

    final String newExerciseId = uuid.v4();

    // Construct new exercise
    final newExercise = JsonExercise(
      id: newExerciseId,
      name: _nameController.text.trim(),
      force: _selectedForce,
      level: _selectedLevel!, // Assumed required by validation
      mechanic: _selectedMechanic,
      equipment: _selectedEquipment,
      primaryMuscles: _selectedPrimaryMuscles,
      secondaryMuscles: _selectedSecondaryMuscles,
      instructions: _instructionsController.text
          .trim()
          .split('\n')
          .where((i) => i.isNotEmpty)
          .toList(), // Split by newline for list
      category: _selectedCategory!, // Assumed required by validation
      images: [], // Custom exercises won't have predefined images from your assets
      isCustom: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10)),
      child: const Padding(
        padding: EdgeInsets.all(20.0),
      ),
    );
  }
}
