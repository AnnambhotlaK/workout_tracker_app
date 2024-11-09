import 'package:flutter/material.dart';
import 'package:main/components/heat_map.dart';
import 'package:main/data/workout_data.dart';
import 'package:main/pages/workout_page.dart';
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

  // Go to the workout page after clicking on it
  void goToWorkoutPage(String workoutName) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutPage(workoutName: workoutName),
        ));
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

  // Show error message for not filling out workout name
  void invalidWorkoutNamePopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Workout'),
        content: const Text('Please enter a valid workout name.'),
        actions: [
          // OK Button
          MaterialButton(onPressed: ok, child: const Text('OK')),
        ],
      ),
    );
  }

  // Closes invalid workout alert dialog
  void ok() {
    Navigator.pop(context);
    clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
        builder: (context, value, child) => Scaffold(
              appBar: AppBar(
                title: const Text('My Workout Journal'),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: createNewWorkout,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              ),
              body: ListView(
                children: [
                  // Activity heat map
                  MyHeatMap(
                      datasets: value.heatMapDataset,
                      startDateYYYYMMDD: value.getStartDate()),
                  // List of workouts
                  Material(
                    type: MaterialType.transparency,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: value.getWorkoutList().length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    '${value.getWorkoutList()[index].name} deleted')));
                            setState(() {
                              value.deleteWorkout(value.getWorkoutList()[index].key);
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
                            title: Text(value.getWorkoutList()[index].name),
                            onTap: () => goToWorkoutPage(
                                value.getWorkoutList()[index].name),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ));
  }
}
