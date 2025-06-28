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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        // ListTile is good for set rows
        tileColor: (isCompleted) ? Colors.green: Colors.grey[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        leading: Checkbox(
          checkColor: Colors.white,
          //activeColor: Colors.green,
          value: isCompleted,
          onChanged: onCheckboxChanged,
        ),
        title: Text('Weight: $weight', style: TextStyle(fontSize: 14, color: (isCompleted) ? Colors.white : Colors.black)),
        subtitle: Text('Reps: $reps', style: TextStyle(fontSize: 14, color: (isCompleted) ? Colors.white : Colors.black)),
        dense: true,
      ),
    );
  }
}
