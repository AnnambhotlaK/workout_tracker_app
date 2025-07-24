import 'package:flutter/material.dart';
import 'package:main/components/exercise_tile.dart';
import 'package:main/curr_workout_data/curr_workout_data.dart';
import 'package:provider/provider.dart';
import '../components/exercise_selector.dart';
import '../curr_workout_data/workout_data_provider.dart';
import '../exercise_db/json_exercise.dart';
import '../models/session.dart';
import '../models/set.dart';
import '../components/exercise_tile.dart';
import '../components/set_tile.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../session_data/session_data.dart';
import '../session_data/session_data_provider.dart';

class WorkoutPage extends StatefulWidget {
  final Workout workout;
  const WorkoutPage({super.key, required this.workout});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  bool isEndSessionButtonActive = true;

  // Checkbox was ticked
  void onCheckboxChanged(Workout workout, Exercise exercise, Set set) {
    setState(() {
      set.isCompleted = !set.isCompleted;
    });

    Provider.of<WorkoutDataProvider>(context, listen: false)
        .updateSet(workout, exercise, set);
  }

  // Text controllers for creating new exercise
  final exerciseNameController = TextEditingController();
  final weightController = TextEditingController();
  final repsController = TextEditingController();
  final setsController = TextEditingController();

  // Creating a new exercise
  void _showExerciseSelector(BuildContext context) async {
    final JsonExercise? selectedExercise = await showDialog<JsonExercise>(
        context: context,
        builder: (BuildContext context) {
          return const ExerciseSelector();
        });
    if (selectedExercise != null) {
      // User selected an exercise
      print('Selected Exercise ID: ${selectedExercise.id}');
      print('Selected Exercise Name: ${selectedExercise.name}');
      // Now you can use this 'selectedExercise' object
      Exercise newExercise = Exercise(
          id: selectedExercise.id, name: selectedExercise.name, sets: []);
      Provider.of<WorkoutDataProvider>(context, listen: false)
          .addExercise(widget.workout, newExercise);
    } else {
      // User canceled the dialog (tapped outside or pressed Cancel)
      print('Exercise selection canceled.');
    }
  }

  // Save exercise
  void save() {
    String newExerciseName = exerciseNameController.text;
    //String weight = weightController.text;
    //String reps = repsController.text;
    //String sets = setsController.text;
    // If any are incorrect, create error message
    if ((newExerciseName.isEmpty || newExerciseName.trim().isEmpty)) {
      invalidExercisePopup();
    } else {
      // Add workout to workout data list
      //Provider.of<WorkoutData>(context, listen: false)
      //    .addExercise(widget.workoutName, newExerciseName);

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
  void confirmEndWorkoutPopup(Workout workout) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('End Session'),
                content: const Text('Would you like to end this session?'),
                actions: [
                  // Save Session Button
                  MaterialButton(
                      onPressed: () => saveSession(workout),
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
  Future<void> saveSession(Workout workout) async {
    // Get current datetime (useful for later)
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    // Deactivate current workout
    print("WORKOUT ID: ${workout.id}");
    workout.isActive = false;
    Provider.of<WorkoutDataProvider>(context, listen: false)
        .updateWorkout(workout);

    // Pop dialog confirming session end
    Navigator.pop(context);
    clear();

    //TODO: Fix to only save completed sets
    // Next, uncheck all checked exercises in the workout
    // Also add completed exercises to list of exercises
    List<Exercise> completedExercises = [];
    bool setWasCompleted = false;
    for (Exercise exercise in workout.exercises) {
      for (Set set in exercise.sets) {
        if (set.isCompleted) {
          setWasCompleted = true;
          setState(() {
            set.isCompleted = !set.isCompleted;
          });
          Provider.of<WorkoutDataProvider>(context, listen: false)
              .updateSet(workout, exercise, set);
        }
      }
      if (setWasCompleted) {
        completedExercises.add(exercise);

        setWasCompleted = false;
        setState(() {
          exercise.isCompleted = true;
        });
        Provider.of<WorkoutDataProvider>(context, listen: false)
            .updateExercise(workout, exercise);
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
                  widget.workout.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
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
                              ('${exercise.name} | ${exercise.sets.length} sets'),
                              style: const TextStyle(),
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
    //TODO: Construct session with only completed sets from correct exercises.
    // Figure out efficient way to do this.
    Session newSession = Session();
    Provider.of<SessionDataProvider>(context, listen: false)
        .addSession(newSession);
  }

  // Special helper for closing "congrats" popup
  void closeCongratulatoryPopup() {
    Navigator.pop(context); // close popup itself
    clear();
    Navigator.pop(context); // return to home page
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutDataProvider>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          title: Text(widget.workout.name),
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
                onPressed: () => _showExerciseSelector(context),
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
                  bool readyToFinish = false;
                  //Workout relevantWorkout = value.getRelevantWorkout(widget.workout);
                  for (Exercise exercise in widget.workout.exercises) {
                    for (Set set in exercise.sets) {
                      if (set.isCompleted) {
                        readyToFinish = true;
                      }
                    }
                  }
                  if (!readyToFinish) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Please complete at least one set before ending the session.')));
                  } else {
                    confirmEndWorkoutPopup(widget.workout);
                  }
                },
                child: const Icon(Icons.check),
              )
            ],
          ),
        ),
        body: ListView.builder(
            // OUTER ListView for Exercises
            itemCount: widget.workout.exercises.length,
            itemBuilder: (context, exerciseIndex) {
              Exercise currentExercise =
                  widget.workout.exercises[exerciseIndex];
              return ExerciseTile(
                  workout: widget.workout,
                  exercise: currentExercise,
                  isExerciseCompleted: currentExercise.isCompleted,
                  sets: currentExercise.sets,
                  onDeleteSet: (set) {
                    setState(() {
                      set.isCompleted = false;
                    });
                    value.updateSet(widget.workout, currentExercise, set);
                    setState(() {
                      value.deleteSet(widget.workout, currentExercise, set);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Set deleted from ${currentExercise.name}')));
                  },
                  onToggleSetCompletion: (set) {
                    setState(() {
                      set.isCompleted = !set.isCompleted;
                    });
                    value.updateSet(widget.workout, currentExercise, set);
                  },
                  // Add similar callbacks for deleting the whole exercise if needed
                  onDeleteExercise: () {
                    setState(() {
                      currentExercise.isCompleted = false;
                    });
                    value.updateExercise(widget.workout, currentExercise);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${currentExercise.name} deleted')));
                    setState(() {
                      value.deleteExercise(widget.workout, currentExercise);
                    });
                  });
            }),
      ),
    );
  }
}
