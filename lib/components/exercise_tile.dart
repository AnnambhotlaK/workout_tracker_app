import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ExerciseTile extends StatelessWidget {
  final String exerciseName;
  final String weight;
  final String reps;
  final String sets;
  final bool isCompleted;
  void Function(bool?)? onCheckboxChanged;

  ExerciseTile({
    super.key,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.isCompleted,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        // Color changes upon checking off exercise
        color: isCompleted ? Colors.green : Colors.grey,
        child: ListTile(
            title: Text(exerciseName),
            subtitle: Row(
              children: [
                Chip(label: Text("${weight}kg")),
                Chip(label: Text("$reps reps")),
                Chip(label: Text("$sets sets")),
              ],
            ),
            trailing: Checkbox(
              value: isCompleted,
              onChanged: (value) => onCheckboxChanged!(value),
            )));
  }
}
