import 'package:flutter/material.dart';
import 'package:main/data/workout_data.dart';
import 'package:provider/provider.dart';

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

      ]
      ),
    );
  }

  // Save Workout
  void save() {
    // Get workout name from text controller
    String newWorkoutName = newWorkoutNameController.text;
    // Add workout to workoutdata list
    Provider.of<WorkoutData>(context, listen: false).addWorkout(newWorkoutName);
  }

  // Cancel Workout
  void cancel() {

  }


  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
      appBar: AppBar(title: const Text('Workout Tracker'), 
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewWorkout,
        child: const Icon(Icons.add),
        ),
      body: ListView.builder(
        itemCount: value.getWorkoutList().length,
        itemBuilder: (context, index) => ListTile(
          title: Text(value.getWorkoutList()[index].name),
          ),
        )
      ),
    );
  }
}