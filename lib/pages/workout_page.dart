import 'package:flutter/material.dart';
import 'package:main/components/exercise_tile.dart';
import 'package:main/data/workout_data.dart';
import 'package:provider/provider.dart';

class WorkoutPage extends StatefulWidget {
  final String workoutName;
  const WorkoutPage({super.key, required this.workoutName});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  // Checkbox was ticked
  void onCheckboxChanged(String workoutName, String exerciseName) {
    Provider.of<WorkoutData>(context, listen: false)
        .checkOffExercise(workoutName, exerciseName);
  }

  // Text controllers for creating new exercise
  final exerciseNameController = TextEditingController();
  final weightController = TextEditingController();
  final repsController = TextEditingController();
  final setsController = TextEditingController();

  // Creating a new exercise
  void createNewExercise() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add a New Exercise'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(label: Text('Name: ')),
                    controller: exerciseNameController,
                  ),
                  TextField(
                    decoration:
                        const InputDecoration(label: Text('Weight (kg): ')),
                    controller: weightController,
                  ),
                  TextField(
                    decoration: const InputDecoration(label: Text('Reps: ')),
                    controller: repsController,
                  ),
                  TextField(
                    decoration: const InputDecoration(label: Text('Sets: ')),
                    controller: setsController,
                  ),
                ],
              ),
              actions: [
                // Save button
                MaterialButton(
                  onPressed: save,
                  child: const Text('Save'),
                ),

                // Cancel button
                MaterialButton(
                  onPressed: cancel,
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  // Save exercise
  void save() {
    String newExerciseName = exerciseNameController.text;
    String weight = weightController.text;
    String reps = repsController.text;
    String sets = setsController.text;
    // If any are incorrect, create error message
    if ((newExerciseName.isEmpty || newExerciseName.trim().isEmpty) ||
        (weight.isEmpty || weight.trim().isEmpty) ||
        (reps.isEmpty || reps.trim().isEmpty) ||
        (sets.isEmpty || sets.trim().isEmpty)) {
      invalidExercisePopup();
    } else {
      // Add workout to workoutdata list
      Provider.of<WorkoutData>(context, listen: false)
          .addExercise(widget.workoutName, newExerciseName, weight, reps, sets);

      Navigator.pop(context);
      clear();
    }
  }

  // Cancel Workout
  void cancel() {
    // Pop dialog box
    Navigator.pop(context);
    clear();
  }

  // Clear controller
  void clear() {
    exerciseNameController.clear();
    weightController.clear();
    repsController.clear();
    setsController.clear();
  }

  // Create error popup for exercises
  void invalidExercisePopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Exercise'),
        content:
            const Text('Carefully review the exercise details you entered.'),
        actions: [
          // OK Button
          MaterialButton(onPressed: ok, child: const Text('OK')),
        ],
      ),
    );
  }

  // Close invalid exercise alert dialog
  void ok() {
    Navigator.pop(context);
    clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          title: Text(widget.workoutName),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          onPressed: createNewExercise,
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
            itemCount: value.numberOfExercisesInWorkout(widget.workoutName),
            itemBuilder: (context, index) {
              return Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          '${value.getRelevantWorkout(widget.workoutName).exercises[index].name} deleted')));
                  if (value
                      .getRelevantWorkout(widget.workoutName)
                      .exercises[index]
                      .isCompleted) {
                    !value
                        .getRelevantWorkout(widget.workoutName)
                        .exercises[index]
                        .isCompleted;
                  }
                  setState(() {
                    value.deleteExercise(
                        value.getRelevantWorkout(widget.workoutName).key,
                        value
                            .getRelevantWorkout(widget.workoutName)
                            .exercises[index]
                            .key);
                  });
                },
                // Show indicator of deleting workout
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                child: ExerciseTile(
                  exerciseName: value
                      .getRelevantWorkout(widget.workoutName)
                      .exercises[index]
                      .name,
                  weight: value
                      .getRelevantWorkout(widget.workoutName)
                      .exercises[index]
                      .weight,
                  reps: value
                      .getRelevantWorkout(widget.workoutName)
                      .exercises[index]
                      .reps,
                  sets: value
                      .getRelevantWorkout(widget.workoutName)
                      .exercises[index]
                      .sets,
                  isCompleted: value
                      .getRelevantWorkout(widget.workoutName)
                      .exercises[index]
                      .isCompleted,
                  onCheckboxChanged: (val) => onCheckboxChanged(
                      widget.workoutName,
                      value
                          .getRelevantWorkout(widget.workoutName)
                          .exercises[index]
                          .name),
                ),
              );
            }),
      ),
    );
  }
}
