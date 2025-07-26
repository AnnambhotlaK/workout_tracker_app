import 'package:flutter/material.dart';
import 'package:main/components/heat_map.dart';
import 'package:main/pages/workout_page.dart';
import '../curr_workout_data/workout_data_provider.dart';
import '../models/session.dart';
import '../session_data/session_data_provider.dart';
import '../models/exercise.dart';
import 'package:provider/provider.dart';

import '../models/workout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Text controller for saving user text
  final newWorkoutNameController = TextEditingController();

  // Creating new workout
  void createNewWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Create New Workout'),
          content: TextField(
            decoration: const InputDecoration(label: Text('Name')),
            controller: newWorkoutNameController,
          ),
          actions: [
            // Save button
            MaterialButton(
              onPressed: save,
              child: const Text('Save'),
            ),
            // Cancel button
            MaterialButton(
              onPressed: closePopup,
              child: const Text('Cancel'),
            ),
          ]),
    );
  }

  // Save Workout
  void save() {
    // Get workout name from text controller
    String newWorkoutName = newWorkoutNameController.text;
    // If text box is blank, send notification and make user try again
    if (newWorkoutName.isEmpty || newWorkoutName.trim().isEmpty) {
      invalidWorkoutNamePopup();
    } else {
      // Add workout to workoutdata list
      Workout newWorkout = Workout(
        // Note: id is irrelevant, firestore overrules it
        id: '',
        name: newWorkoutName,
        isActive: false,
        exercises: [],
      );
      Provider.of<WorkoutDataProvider>(context, listen: false).addWorkout(newWorkout);

      // Pop dialog box
      Navigator.pop(context);
      clear();
    }
  }

  // Clear workout name controller
  void clear() {
    newWorkoutNameController.clear();
  }

  // Go to the workout page after clicking on it
  void goToWorkoutPage(Workout workout) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WorkoutPage(workout: workout),
        ));
  }

  // Start a new workout session
  void startSession(Workout workout) {
    closePopup();
    goToWorkoutPage(workout);
    // set relevant workout to active
    workout.isActive = true;
    Provider.of<WorkoutDataProvider>(context, listen: false).updateWorkout(workout);
  }

  // Show error message for not filling out workout name
  void invalidWorkoutNamePopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Workout'),
        content: const Text('Please enter a valid workout name.'),
        actions: [
          // OK Button
          MaterialButton(onPressed: closePopup, child: const Text('OK')),
        ],
      ),
    );
  }

  // Show popup to confirm or deny starting a new workout
  void confirmStartWorkoutPopup(
      Workout workout) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Confirm Workout'),
              content: const Text('Would you like to start this workout?'),
              actions: [
                // Yes, to initiate workout
                // implement startWorkout, which initiates a "workout"
                MaterialButton(
                    onPressed: () =>
                        startSession(workout),
                    child: const Text('Yes')),
                // No, to return to home page
                MaterialButton(onPressed: closePopup, child: const Text('No')),
              ],
            ));
  }

  // Closes invalid workout alert dialog
  void closePopup() {
    Navigator.pop(context);
    clear();
  }

  @override
  Widget build(BuildContext context) {

    final workoutProvider = context.watch<WorkoutDataProvider>();
    if (workoutProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (workoutProvider.error != null) {
      return Scaffold(body: Center(child: Text("Error: ${workoutProvider.error}")));
    }
    if (workoutProvider.currentUserId == null) {
      // Should not occur, but need to check still
      // AuthWrapper will ideally handle this
      return const Scaffold(body: Center(child: Text("Error: User not logged in")));
    }
    List<Workout> workouts = workoutProvider.workouts;

    final sessionProvider = context.watch<SessionDataProvider>();
    if (sessionProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (sessionProvider.error != null) {
      return Scaffold(body: Center(child: Text("Error: ${sessionProvider.error}")));
    }
    if (sessionProvider.currentUserId == null) {
      // Should not occur, but need to check still
      // AuthWrapper will ideally handle this
      return const Scaffold(body: Center(child: Text("Error: User not logged in")));
    }
    List<Session> sessions = sessionProvider.sessions;



    return Consumer2<WorkoutDataProvider, SessionDataProvider>(
      builder: (context, workoutProvider, sessionProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            actions: <Widget>[
              //TODO: Get a good fire icon for streak
              Text(
                '🔥 ${sessionProvider.getCurrentStreak()}',
                style: const TextStyle(color: Colors.orange, fontSize: 20),
              ),
              const Padding(padding: EdgeInsets.only(right: 15)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: createNewWorkout,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          body: ListView(
            children: [
              // Activity heat map for sessions completed
              MyHeatMap(
                  datasets: sessionProvider.heatMapDataset,
                  startDate: sessionProvider.getStartDateForHeatMap()
              ),
              // List of workouts
              Material(
                type: MaterialType.transparency,
                // Child: show message if empty, show workouts if not
                child: (workouts.isEmpty)
                    ? const Center(
                        child: Text("No workouts yet. Add some!",
                            style: TextStyle(fontStyle: FontStyle.italic)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      '${workouts[index].name} deleted')));
                              setState(() {
                                workoutProvider.deleteWorkout(
                                    workouts[index]);
                              });
                            },
                            // Red "delete" background with trash symbol
                            background: Container(
                              color: Colors.red,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                  workouts[index].name),
                              onTap: () {
                                // If tapping on active workout: go to page
                                if (workoutProvider
                                    .workouts[index]
                                    .isActive) {
                                  goToWorkoutPage(
                                    workouts[index]
                                  );
                                }
                                // If tapping on inactive workout + none others active: go to popup
                                if (!workoutProvider
                                        .workouts[index]
                                        .isActive &&
                                    (workoutProvider.getActiveWorkout() == null)) {
                                  confirmStartWorkoutPopup(
                                    workouts[index]
                                  );
                                }
                                // If tapping on inactive workout + one other active: send notification
                                if (!workouts[index]
                                        .isActive &&
                                    (workoutProvider.getActiveWorkout() != null)) {
                                  String name = workoutProvider.getActiveWorkout()!.name;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Can\'t start with $name already active!')));
                                }
                              },
                              trailing: const Icon(Icons.arrow_forward_ios),
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        );
      },
    );
  }
}
