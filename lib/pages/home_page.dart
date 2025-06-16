import 'package:flutter/material.dart';
import 'package:main/components/heat_map.dart';
import 'package:main/workout_data/curr_workout_data.dart';
import 'package:main/session_data/session_data.dart';
import 'package:main/pages/workout_page.dart';
import '../models/exercise.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Provider.of<WorkoutData>(context, listen: false).initializeWorkoutList();
    Provider.of<SessionData>(context, listen: false).initializeSessionList();
  }

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
              onPressed: cancel,
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
      Provider.of<WorkoutData>(context, listen: false)
          .addWorkout(newWorkoutName);

      // Pop dialog box
      Navigator.pop(context);
      clear();
    }
  }

  // Cancel adding a workout
  void cancel() {
    Navigator.pop(context);
    clear();
  }

  // Clear workout name controller
  void clear() {
    newWorkoutNameController.clear();
  }

  // Go to the workout page after clicking on it
  void goToWorkoutPage(String workoutName) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutPage(workoutName: workoutName),
        ));
  }

  // Start a new workout session
  void startSession(String workoutName, List<Exercise> exercises) {
    closePopup();
    goToWorkoutPage(workoutName);
    // set relevant workout to active
    Provider.of<WorkoutData>(context, listen: false)
        .getRelevantWorkout(workoutName)
        .isActive = true;
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
  void confirmStartWorkoutPopup(String workoutName, List<Exercise> exercises) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Confirm Workout'),
              content: const Text('Would you like to start this workout?'),
              actions: [
                // Yes, to initiate workout
                // implement startWorkout, which initiates a "workout"
                MaterialButton(
                    onPressed: () => startSession(workoutName, exercises),
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
    return Consumer2<WorkoutData, SessionData>(
      builder: (context, workoutValue, sessionValue, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            actions: <Widget>[
              //TODO: Get a good fire icon for streak
              Text(
                '🔥 ${sessionValue.getCurrentStreak()}',
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
                  datasets: sessionValue.heatMapDataset,
                  startDateYYYYMMDD: sessionValue.getStartDate()),
              // List of workouts
              Material(
                type: MaterialType.transparency,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workoutValue.getWorkoutList().length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '${workoutValue.getWorkoutList()[index].name} deleted')));
                        setState(() {
                          workoutValue.deleteWorkout(
                              workoutValue.getWorkoutList()[index].key);
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
                        title: Text(workoutValue.getWorkoutList()[index].name),
                        onTap: () {
                          // If tapping on active workout: go to page
                          if (workoutValue.getWorkoutList()[index].isActive) {
                            goToWorkoutPage(
                              workoutValue.getWorkoutList()[index].name,
                            );
                          }
                          // If tapping on inactive workout + none others active: go to popup
                          if (!workoutValue.getWorkoutList()[index].isActive &&
                              !workoutValue.isWorkoutActive()) {
                            confirmStartWorkoutPopup(
                              workoutValue.getWorkoutList()[index].name,
                              workoutValue.getWorkoutList()[index].exercises,
                            );
                          }
                          // If tapping on inactive workout + one other active: send notification
                          if (!workoutValue.getWorkoutList()[index].isActive &&
                              workoutValue.isWorkoutActive()) {
                            String name = workoutValue.getActiveWorkout();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
