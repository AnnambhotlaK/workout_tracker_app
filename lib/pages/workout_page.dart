import 'package:flutter/material.dart';
import 'package:main/components/exercise_tile.dart';
import 'package:main/workout_data/curr_workout_data.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../session_data/session_data.dart';

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
                  // Save Session Button
                  MaterialButton(
                      onPressed: () => saveSession(workoutName),
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
  Future<void> saveSession(String workoutName) async {
    // Get current datetime (useful for later)
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    // Deactivate current workout
    Provider.of<WorkoutData>(context, listen: false)
        .getRelevantWorkout(workoutName)
        .isActive = false;

    // Pop dialog confirming session end
    Navigator.pop(context);
    clear();

    // Next, uncheck all checked exercises in the workout
    // Also add completed exercises to list of exercises
    List<Exercise> completedExercises = [];
    for (Exercise exercise in Provider.of<WorkoutData>(context, listen: false)
        .getRelevantWorkout(workoutName)
        .exercises) {
      if (exercise.isCompleted) {
        completedExercises.add(exercise);
        Provider.of<WorkoutData>(context, listen: false)
            .checkOffExercise(workoutName, exercise.name);
      }
    }

    //TODO: Show details of workout with completed message
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                const Text('Congrats on the workout!'), // Display date nicely
            content: SingleChildScrollView(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // WORKOUT NAME
                Text(
                  workoutName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor),
                ),
                // EXERCISES LIST
                const Text(
                  "Exercises Completed:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: completedExercises.map((exercise) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '- ', // Bullet point
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ('${exercise.name} | ${exercise.sets}x${exercise.reps} | ${exercise.weight} kg'),
                              style: const TextStyle(
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            )),
            actions: [
              MaterialButton(
                onPressed: closeCongratulatoryPopup,
                child: const Text('Great!'),
              ),
            ],
          );
        });

    // Save session in sessionList
    Provider.of<SessionData>(context, listen: false).addSession(
      workoutName,
      completedExercises,
      date,
    );
  }

  // Special helper for closing "congrats" popup
  void closeCongratulatoryPopup() {
    Navigator.pop(context); // close popup itself
    clear();
    Navigator.pop(context); // return to home page
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
                heroTag: "addBtn",
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                onPressed: createNewExercise,
                child: const Icon(Icons.add),
              ),
              Expanded(child: Container()),
              // End Session button
              FloatingActionButton(
                heroTag: "endSessionBtn",
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                //TODO: Make it so button is greyed if workout is invalid
                onPressed: () {
                  // if no exercises done in workout
                  if (value.getNumCompletedExercises(
                          value.getRelevantWorkout(widget.workoutName)) ==
                      0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Please complete at least one exercise before ending the session.')));
                  } else {
                    confirmEndWorkoutPopup(widget.workoutName);
                  }
                },
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
