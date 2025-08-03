/*
  Constructs a ListView popup to scroll through exercises
  from the exercise_db and add one to a workout
*/
import 'package:flutter/material.dart';
import 'package:main/exercise_db/json_exercise.dart';
import '../exercise_db/database_helper.dart';
import 'exercise_adder.dart';

class ExerciseSelector extends StatefulWidget {
  const ExerciseSelector({super.key});

  @override
  State<ExerciseSelector> createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<ExerciseSelector> {
  late Future<List<JsonExercise>> _exercisesFuture;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    // Get all exercises, or all exercises matching the search term
    _exercisesFuture = DatabaseHelper.instance.getAllJsonExercises(
        searchTerm: _searchTerm.isEmpty ? null : _searchTerm);
  }

  // Reload search results upon changing query
  void _onSearchChanged(String query) {
    setState(() {
      _searchTerm = query;
      _loadExercises(); // Reload exercises with the new search term
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Title
              const Text(
                'Add Exercise',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),

              // Search Bar
              TextField(
                onChanged: _onSearchChanged,
              ),

              // Gap
              const SizedBox(height: 16),

              // Scrollable ListView
              Expanded(
                  child: FutureBuilder<List<JsonExercise>>(
                future: _exercisesFuture,
                builder: (context, snapshot) {
                  // Show loading circle if waiting
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Show error if there's an issue
                  else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  // Empty list of exercises (Shouldn't happen)
                  else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No exercises found.'));
                  }
                  // No errors = display listview
                  else {
                    final exercises = snapshot.data!;
                    return ListView.builder(
                        itemCount: exercises.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];
                          return Container(
                            child: ListTile(
                              title: Text(exercise.name),
                              subtitle:
                                  Text(exercise.primaryMuscles.join(', ')),
                              onTap: () {
                                //TODO: On tap, add the exercise to the workout.
                                Navigator.of(context).pop(exercise);
                              },
                            ),
                          );
                        });
                  }
                },
              )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                height: 50,
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //TODO: Button for custom exercise addition
                    Expanded(
                      child: Container(
                        height: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ExerciseAdder()));
                            Navigator.of(context).pop();
                          },
                          child: const Text('Add Custom'),
                        ),
                      ),
                    ),
                    // Close popup
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 5),
                        height: 100,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
