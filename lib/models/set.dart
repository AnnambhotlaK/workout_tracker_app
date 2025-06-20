/*
  Each exercise includes a list of sets
  Each set has a key, weight, number of reps, completed or not
 */
class Set {
  final String key;
  final String weight;
  final String reps;
  bool isCompleted;

  Set({
    required this.key,
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });
}
