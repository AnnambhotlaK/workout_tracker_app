import 'package:flutter/material.dart';
import 'package:main/components/set_tile.dart';
import 'package:main/models/set.dart';
import 'package:provider/provider.dart';
import '../curr_workout_data/curr_workout_data.dart';

class ExerciseTile extends StatelessWidget {
  final String exerciseName;
  final bool isExerciseCompleted; // Assuming you might want to show this
  final List<Set> sets; // Your Set model
  final String workoutKey;
  final String exerciseKey;
  final Function(String setKey) onDeleteSet;
  final Function(String setKey) onToggleSetCompletion;
  final VoidCallback onDeleteExercise;

  ExerciseTile({
    super.key,
    required this.exerciseName,
    required this.isExerciseCompleted,
    required this.sets,
    required this.workoutKey,
    required this.exerciseKey,
    required this.onDeleteSet,
    required this.onToggleSetCompletion,
    required this.onDeleteExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // Keep Dismissible for the whole Exercise
      key: UniqueKey(), // Use exerciseKey for more stable keys if appropriate
      onDismissed: (direction) => onDeleteExercise(),
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white, size: 36),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Name and Controls (e.g., checkbox for whole exercise)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    exerciseName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Maybe an overall completion checkbox for the exercise?
                  // Checkbox(value: isExerciseCompleted, onChanged: (val) { /* ... */ })
                ],
              ),
              const SizedBox(height: 8),

              // Sets List (using Column, not ListView.builder)
              if (sets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("No sets yet. Add some!",
                      style: TextStyle(fontStyle: FontStyle.italic)),
                )
              else
                Column(
                  children: sets.map((set) {
                    // Each set is now directly part of the Column
                    return Dismissible(
                      // Dismissible for individual sets
                      key: ValueKey(set.key),
                      // Use the set's unique key
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => onDeleteSet(set.key),
                      background: Container(
                        color: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                      child: SetTile(
                        // Your existing SetTile
                        initialWeight: set.weight,
                        initialReps: set.reps,
                        isCompleted: set.isCompleted,
                        onCheckboxChanged: (val) {
                          onToggleSetCompletion(set.key);

                        },
                        onWeightChanged: (newWeight) {
                          Provider.of<WorkoutData>(context, listen: false).updateSetWeight(workoutKey, exerciseKey, set.key, newWeight);
                        },
                        onRepsChanged: (newReps) {
                          Provider.of<WorkoutData>(context, listen: false).updateSetReps(workoutKey, exerciseKey, set.key, newReps);
                        },
                      ),
                    );
                  }).toList(),
                ),
              // Maybe an "Add Set" button for this exercise
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  icon: Icon(Icons.add, size: 16),
                  label: Text("Add Set"),
                  onPressed: () {
                    // Call your function to add a new set to this specific exercise
                    // Provider.of<WorkoutData>(context, listen: false).addSetToExercise(workoutKey, exerciseKey, "0", "0");
                    Provider.of<WorkoutData>(context, listen: false).addSet(
                        workoutKey,
                        exerciseKey,
                        '0',
                        '0'); // Assuming you have such a method
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
