import 'package:flutter/material.dart';

class SetTile extends StatefulWidget {
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
  State<SetTile> createState() => _SetTileState();
}

class _SetTileState extends State<SetTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
        // Color changes upon checking off exercise
        color: widget.isCompleted ? Colors.green : Colors.grey,
        child: ListTile(
            //title: Text(exerciseName),
            subtitle: Row(
              children: [
                Chip(label: Text("${widget.weight}kg")),
                Chip(label: Text("${widget.reps} reps")),
                Checkbox(
                  value: widget.isCompleted,
                  onChanged: (value) => widget.onCheckboxChanged!(value),
                )
              ],
            ),
            trailing: Checkbox(
              value: widget.isCompleted,
              onChanged: (value) => widget.onCheckboxChanged!(value),
            )));
  }
}
