import 'package:flutter/material.dart';

class SetTile extends StatelessWidget {
  //final String exerciseName;
  final String weight;
  final String reps;

  //final String sets;
  final bool isCompleted;
  void Function(bool?)? onCheckboxChanged;

  SetTile({
    super.key,
    //required this.exerciseName,
    required this.weight,
    required this.reps,
    //required this.sets,
    required this.isCompleted,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        // Color changes upon checking off exercise
        color: isCompleted ? Colors.green : Colors.grey,
        child: ListTile(
            //title: Text(exerciseName),
            subtitle: Row(
              children: [
                Chip(label: Text("${weight}kg")),
                Chip(label: Text("$reps reps")),
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) => onCheckboxChanged!(value),
                )
              ],
            ),
            trailing: Checkbox(
              value: isCompleted,
              onChanged: (value) => onCheckboxChanged!(value),
            )));
  }
}
