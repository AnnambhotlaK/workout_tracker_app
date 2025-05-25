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
  bool isEndSessionButtonActive = true;

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
                    decoration: const InputDecoration(label: Text('Name')),
                    controller: exerciseNameController,
                  ),
                  TextField(
                    decoration: const InputDecoration(label: Text('Weight')),
                    controller: weightController,
                  ),
                  TextField(
                    decoration: const InputDecoration(label: Text('Reps')),
                    controller: repsController,
                  ),
                  TextField(
                    decoration: const InputDecoration(label: Text('Sets')),
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
      // Add workout to workout data list
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
          MaterialButton(onPressed: closePopup, child: const Text('OK')),
        ],
      ),
    );
  }

  // Confirm the end of a workout session
  void confirmEndWorkoutPopup(String workoutName) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('End Session'),
                content: const Text('Would you like to end this session?'),
                actions: [
                  // Yes Button
                  /* TODO: On ending session, we should save this workout as a session
                      - Send user back to home and show details of workout
                      - Show activity completed on heatmap
                      - Call it something like saveSession
                    */
                  MaterialButton(
                      onPressed: /*closePopup*/ () => saveSession(workoutName),
                      child: const Text('Yes')),
                  // No Button
                  MaterialButton(
                      onPressed: closePopup, child: const Text('No')),
                ]));
  }

  // Close invalid exercise alert dialog
  void closePopup() {
    Navigator.pop(context);
    clear();
  }

  // Actions to save session to sessionData
  void saveSession(String workoutName) {
    // Send user back to home menu
    Navigator.pop(context);
    clear();
    //TODO: Show details of workout
    //For now, just say that session was completed
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text("Session Completed!"),
                content: const Text("Congrats on finishing a workout today!"),
                actions: [
                  MaterialButton(
                      onPressed: closePopup, child: const Text('Great!'))
                ]));
    Navigator.pop(context);
    clear();
    Navigator.pop(context);
    clear();
    // Last, check off workout completed on heat map
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Add Exercise button
              FloatingActionButton(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                onPressed: createNewExercise,
                child: const Icon(Icons.add),
              ),
              Expanded(child: Container()),
              // End Session button
              FloatingActionButton(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                onPressed:
                    //TODO: Can't end workout if no exercises are checked/none exist
                    (isEndSessionButtonActive
                        ? () => confirmEndWorkoutPopup(widget.workoutName)
                        : null),
                child: const Icon(Icons.check),
              )
            ],
          ),
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
                    Provider.of<WorkoutData>(context, listen: false)
                        .checkOffExercise(
                            widget.workoutName,
                            value
                                .getRelevantWorkout(widget.workoutName)
                                .exercises[index]
                                .name);
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
