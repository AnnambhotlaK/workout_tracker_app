import 'package:flutter/material.dart';
import 'package:main/components/set_tile.dart';
import 'package:main/models/set.dart';
import 'package:provider/provider.dart';
import '../data_providers/workout_data_provider.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import 'package:uuid/uuid.dart';

Uuid uuid = const Uuid();

class ExerciseTile extends StatelessWidget {
  final Workout workout;
  final Exercise exercise;
  final List<Set> sets; // Your Set model
  //final bool isExerciseCompleted; // Assuming you might want to show this
  final Function(Set set) onDeleteSet;
  final Function(Set set) onToggleSetCompletion;
  final VoidCallback onDeleteExercise;

  ExerciseTile({
    super.key,
    required this.workout,
    required this.exercise,
    required this.sets,
    //required this.isExerciseCompleted,
    required this.onDeleteSet,
    required this.onToggleSetCompletion,
    required this.onDeleteExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // Keep Dismissible for the whole Exercise
      key: ValueKey('dismissible_exercise_${exercise.instanceId}'),
      onDismissed: (direction) => onDeleteExercise(),
      background: Container(
        color: Colors.redAccent,
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
              // Exercise Name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      exercise.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Weight and Reps headers
              if (sets.isNotEmpty) // Only show headers if there are sets
                Padding(
                  padding: const EdgeInsets.only(
                      left: 80.0, right: 8.0, bottom: 4.0),
                  child: Row(
                    children: [
                      // "Weight" Header
                      Expanded(
                        child: Text(
                          "Weight",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.0),
                      ),

                      // "Reps" Header
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      ),
                      Expanded(
                        child: Text(
                          "Reps",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ],
                  ),
                ),

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
                      key: ValueKey('dismissible_set_${exercise.instanceId}_${set.id}'),
                      // Use the set's unique key
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => onDeleteSet(set),
                      background: Container(
                        color: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                      child: SetTile(
                        // Your existing SetTile
                        key: ValueKey('${exercise.instanceId}_${set.id}'),
                        initialWeight: set.weight,
                        initialReps: set.reps,
                        isCompleted: set.isCompleted,
                        onCheckboxChanged: (val) {
                          onToggleSetCompletion(set);
                        },
                        onWeightChanged: (newWeight) {
                          set.weight = newWeight;
                          Provider.of<WorkoutDataProvider>(context,
                                  listen: false)
                              .updateSet(workout, exercise, set);
                        },
                        onRepsChanged: (newReps) {
                          set.reps = newReps;
                          Provider.of<WorkoutDataProvider>(context,
                                  listen: false)
                              .updateSet(workout, exercise, set);
                        },
                      ),
                    );
                  }).toList(),
                ),
              // Maybe an "Add Set" button for this exercise
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  child: Text("+ Add Set"),
                  onPressed: () {
                    // Call your function to add a new set to this specific exercise
                    // Provider.of<WorkoutDataProvider>(context, listen: false).addSetToExercise(workoutKey, exerciseKey, "0", "0");
                    Provider.of<WorkoutDataProvider>(context, listen: false)
                        .addSet(
                            workout,
                            exercise,
                            Set(
                                id: uuid.v4(),
                                weight: '0',
                                reps: '0',
                                isCompleted:
                                    false));
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
