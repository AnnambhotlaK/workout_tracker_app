import 'package:flutter/material.dart';
import 'package:main/data/workout_data.dart';
import 'package:provider/provider.dart';

class WorkoutPage extends StatefulWidget {
  final String workoutName;
  const WorkoutPage({super.key, required this.workoutName});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
          appBar: AppBar(title: Text(widget.workoutName)),
          body: ListView.builder(
              itemCount: value.numberOfExercisesInWorkout(widget.workoutName),
              itemBuilder: (context, index) => ListTile(
                    title: Text(value
                        .getRelevantWorkout(widget.workoutName)
                        .exercises[index]
                        .name),
                  ))),
    );
  }
}
