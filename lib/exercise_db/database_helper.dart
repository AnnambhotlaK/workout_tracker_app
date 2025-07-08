import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart'; // For checking if DB is populated
import 'json_exercise.dart';

const String dbName = 'app_database.db';
const String exercisesTable = 'exercises';
const String workoutLogsTable = 'workout_logs'; // Example for PRs
const String dbPopulatedKey = 'isDatabasePopulated';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // TEXT for fields that can be long or are naturally strings
    // INTEGER for boolean flags (0 or 1)
    // REAL for floating-point numbers (like weight)
    // BLOB for raw binary data (not needed here for lists if using JSON strings)
    await db.execute('''
      CREATE TABLE $exercisesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        force TEXT,
        level TEXT NOT NULL,
        mechanic TEXT,
        equipment TEXT,
        primaryMuscles TEXT,   -- Store as JSON string
        secondaryMuscles TEXT, -- Store as JSON string
        instructions TEXT,     -- Store as JSON string
        category TEXT NOT NULL,
        images TEXT,           -- Store as JSON string (paths to assets)
        isCustom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $workoutLogsTable (
        logId TEXT PRIMARY KEY, -- Or INTEGER AUTOINCREMENT
        exerciseId TEXT NOT NULL,
        exerciseName TEXT NOT NULL, -- Denormalized for easier display
        date TEXT NOT NULL, -- Store as ISO8601 string
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        FOREIGN KEY (exerciseId) REFERENCES $exercisesTable (id) ON DELETE CASCADE
      )
    ''');

    // Populate after creating tables
    await _populateInitialExercises(db);
  }

  Future<void> _populateInitialExercises(Database db) async {
    final prefs = await SharedPreferences.getInstance();
    final bool isPopulated = prefs.getBool(dbPopulatedKey) ?? false;

    if (!isPopulated) {
      print("Database not populated. Populating now from data.json...");
      try {
        // 1. Ensure 'data.json' is in your assets folder
        // 2. Ensure 'data.json' is declared in your pubspec.yaml:
        //    flutter:
        //      assets:
        //        - assets/data.json
        //        - assets/exercise_images/ # If you have images
        String jsonString = await rootBundle.loadString('assets/data.json');

        // The root of your data.json is an array of exercise objects
        final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

        Batch batch = db.batch();
        for (var jsonObj in jsonList) {
          if (jsonObj is Map<String, dynamic>) {
            // isCustomOrigin: false because this is from the predefined dataset
            Exercise exercise =
                Exercise.fromJson(jsonObj, isCustomOrigin: false);
            batch.insert(exercisesTable,
                exercise.toMap()); // .toMap() serializes list fields
          } else {
            print("Skipping invalid item in JSON data: $jsonObj");
          }
        }
        await batch.commit(noResult: true);
        await prefs.setBool(dbPopulatedKey, true);
        print("Database populated successfully from data.json.");
      } catch (e) {
        print("Error populating database from data.json: $e");
        // Consider more robust error handling:
        // - Maybe delete the database file and retry on next launch if population fails mid-way.
        // - Inform the user if essential data can't be loaded.
      }
    } else {
      print("Database already populated.");
    }
  }

  // --- CRUD for Exercises ---
  Future<String> addExercise(Exercise exercise,
      {bool isCustomEntry = true}) async {
    final db = await instance.database;
    // Ensure the 'isCustom' flag is correctly set before saving
    Exercise exerciseToSave = Exercise(
        id: exercise
            .id, // Or generate a new one if it's truly custom and 'id' isn't user-provided
        name: exercise.name,
        force: exercise.force,
        level: exercise.level,
        mechanic: exercise.mechanic,
        equipment: exercise.equipment,
        primaryMuscles: exercise.primaryMuscles,
        secondaryMuscles: exercise.secondaryMuscles,
        instructions: exercise.instructions,
        category: exercise.category,
        images: exercise.images,
        isCustom: isCustomEntry);
    await db.insert(exercisesTable, exerciseToSave.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return exerciseToSave.id;
  }

  Future<Exercise?> getExercise(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      exercisesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Exercise.fromDbMap(
          maps.first); // Use fromDbMap for deserialization
    } else {
      return null;
    }
  }

  Future<List<Exercise>> getAllExercises({String? searchTerm}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result;

    if (searchTerm != null && searchTerm.isNotEmpty) {
      result = await db.query(exercisesTable,
          where: "name LIKE ?",
          whereArgs: [
            '%$searchTerm%'
          ], // Case-insensitive search might need LOWER() depending on SQLite version/config
          orderBy: 'name ASC');
    } else {
      result = await db.query(exercisesTable, orderBy: 'name ASC');
    }
    return result.map((json) => Exercise.fromDbMap(json)).toList();
  }

  Future<void> deleteExercise(String id) async {
    final db = await instance.database;
    await db.delete(
      exercisesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    // Also consider deleting related workout logs or handling them as needed
  }

  // --- CRUD for Workout Logs (Personal Records) ---
  Future<String> addWorkoutLog(WorkoutLogEntry logEntry) async {
    final db = await instance.database;
    // Assuming WorkoutLogEntry has a toMap() method similar to Exercise
    // And a unique id (e.g., generated using uuid package)
    // final String logId = Uuid().v4();
    // Map<String, dynamic> logMap = logEntry.toMap();
    // logMap['logId'] = logId; // If WorkoutLogEntry doesn't manage its own ID

    await db.insert(workoutLogsTable, logEntry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return logEntry.id; // Assuming logEntry has an id
  }

  Future<List<WorkoutLogEntry>> getWorkoutLogsForExercise(
      String exerciseId) async {
    final db = await instance.database;
    final result = await db.query(
      workoutLogsTable,
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
      orderBy: 'date ASC', // Important for progression charts
    );
    // Assuming WorkoutLogEntry has a fromMap factory
    return result.map((map) => WorkoutLogEntry.fromMap(map)).toList();
  }
}
