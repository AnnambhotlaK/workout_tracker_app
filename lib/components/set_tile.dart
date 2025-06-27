import 'package:flutter/material.dart';

class SetTile extends StatelessWidget {
  final String weight;
  final String reps;
  final bool isCompleted;
  final ValueChanged<bool?> onCheckboxChanged;

  const SetTile({
    super.key,
    required this.weight,
    required this.reps,
    required this.isCompleted,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile( // ListTile is good for set rows
      tileColor: Colors.blueGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      leading: Checkbox(
        value: isCompleted,
        onChanged: onCheckboxChanged,
      ),
      title: Text('Weight: $weight', style: TextStyle(fontSize: 14)),
      subtitle: Text('Reps: $reps', style: TextStyle(fontSize: 14)),
      dense: true,
    );
  }
}
