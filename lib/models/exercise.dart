import 'package:main/models/set.dart';

class Exercise {
  final String key;
  final String name;
  //final String weight;
  //final String reps;
  bool isCompleted;
  final List<Set> sets;

  Exercise({
    required this.key,
    required this.name,
    //required this.weight,
    //required this.reps,
    required this.sets,
    this.isCompleted = false,
  });
}
