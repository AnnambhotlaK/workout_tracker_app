import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart'; // For checking if DB is populated
import 'json_exercise.dart';
import 'workout_log_entry.dart';

const String dbName = 'app_database.db';
const String JsonExercisesTable = 'JsonExercises';
const String workoutLogsTable = 'workout_logs'; // Example for PRs
const String dbPopulatedKey = 'isDatabasePopulated';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!; // Returns immediately if already initialized
    // THIS IS THE INITIALIZATION BLOCK
    print("Database getter: _database is null, calling _initDB."); // Add this log
    _database = await _initDB(dbName);
    print("Database getter: _initDB completed, _database is now set."); // Add this log
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    print("_initDB called."); // Add this log
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);
    print("_initDB: Opening database at $path"); // Add this log
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    print("_createDB called.");
    // TEXT for fields that can be long or are naturally strings
    // INTEGER for boolean flags (0 or 1)
    // REAL for floating-point numbers (like weight)
    // BLOB for raw binary data (not needed here for lists if using JSON strings)
    await db.execute('''
      CREATE TABLE $JsonExercisesTable (
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
        JsonExerciseId TEXT NOT NULL,
        JsonExerciseName TEXT NOT NULL, -- Denormalized for easier display
        date TEXT NOT NULL, -- Store as ISO8601 string
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        FOREIGN KEY (JsonExerciseId) REFERENCES $JsonExercisesTable (id) ON DELETE CASCADE
      )
    ''');

    // Populate after creating tables
    await _populateInitialJsonExercises(db);
  }

  Future<void> _populateInitialJsonExercises(Database db) async {
    print("_populateInitialJsonExercises called.");
    final prefs = await SharedPreferences.getInstance();
    final bool isPopulated = prefs.getBool(dbPopulatedKey) ?? false;

    if (!isPopulated) {
      print("Database not populated. Populating now from data.json...");
      try {
        String jsonString = await rootBundle.loadString('assets/data.json');
        print("Successfully loaded data.json string."); // <--- ADD THIS
        final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
        print("Successfully decoded JSON. Number of items: ${jsonList.length}"); // <--- ADD THIS

        Batch batch = db.batch();
        int count = 0;
        for (var jsonObj in jsonList) {
          print("Processing item ${count++}: $jsonObj"); // <--- ADD THIS
          if (jsonObj is Map<String, dynamic>) {
            JsonExercise newJsonExercise = JsonExercise.fromJson(jsonObj, isCustomOrigin: false);
            print("Converted to JsonExercise: ${newJsonExercise.name}"); // <--- ADD THIS
            batch.insert(JsonExercisesTable, newJsonExercise.toMap());
          } else {
            print("Skipping invalid item in JSON data: $jsonObj");
          }
        }
        print("Batch prepared. Committing..."); // <--- ADD THIS
        await batch.commit(noResult: true);
        await prefs.setBool(dbPopulatedKey, true);
        print("Database populated successfully from data.json.");
      } catch (e, s) { // Also print stack trace
        print("Error populating database from data.json: $e");
        print("Stack trace: $s"); // <--- ADD STACK TRACE
      }
    } else {
      print("Database already populated.");
    }
  }

  // --- CRUD for JsonExercises ---
  Future<String> addJsonExercise(JsonExercise newJsonExercise,
      {bool isCustomEntry = true}) async {
    final db = await instance.database;
    // Ensure the 'isCustom' flag is correctly set before saving
    JsonExercise newJsonExerciseToSave = JsonExercise(
        id: newJsonExercise
            .id, // Or generate a new one if it's truly custom and 'id' isn't user-provided
        name: newJsonExercise.name,
        force: newJsonExercise.force,
        level: newJsonExercise.level,
        mechanic: newJsonExercise.mechanic,
        equipment: newJsonExercise.equipment,
        primaryMuscles: newJsonExercise.primaryMuscles,
        secondaryMuscles: newJsonExercise.secondaryMuscles,
        instructions: newJsonExercise.instructions,
        category: newJsonExercise.category,
        images: newJsonExercise.images,
        isCustom: isCustomEntry);
    await db.insert(JsonExercisesTable, newJsonExerciseToSave.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return newJsonExerciseToSave.id;
  }

  Future<JsonExercise?> getJsonExercise(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      JsonExercisesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return JsonExercise.fromDbMap(
          maps.first); // Use fromDbMap for deserialization
    } else {
      return null;
    }
  }

  /*
  Future<List<JsonExercise>> getAllJsonExercises({String? searchTerm}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result;
    print("Search term null?: ${searchTerm == null}");
    if (searchTerm != null && searchTerm.isNotEmpty) {
      result = await db.query(JsonExercisesTable,
          where: "name LIKE ?",
          whereArgs: [
            '%$searchTerm%'
          ], // Case-insensitive search might need LOWER() depending on SQLite version/config
          orderBy: 'name ASC');
    } else {
      result = await db.query(JsonExercisesTable, orderBy: 'name ASC');
    }
    return result.map((json) => JsonExercise.fromDbMap(json)).toList();
  }

   */

  Future<List<JsonExercise>> getAllJsonExercises({String? searchTerm}) async {
    try {
      print("DB_HELPER: Attempting to load JSON asset...");
      // Your existing JSON loading logic (e.g., from 'assets/data.json')
      final String response = await rootBundle.loadString('assets/data.json'); // Make sure path is correct!
      print("DB_HELPER: JSON String loaded (first 500 chars): ${response.substring(0, response.length > 500 ? 500 : response.length)}");

      final List<dynamic> data = json.decode(response) as List<dynamic>;
      print("DB_HELPER: JSON Decoded. Number of items: ${data.length}");

      List<JsonExercise> exercises = data.map((item) => JsonExercise.fromJson(item as Map<String, dynamic>)).toList();
      print("DB_HELPER: Parsed exercises. First exercise name (if any): ${exercises.isNotEmpty ? exercises.first.name : 'N/A'}");

      if (searchTerm != null && searchTerm.isNotEmpty) {
        exercises = exercises.where((ex) => ex.name.toLowerCase().contains(searchTerm.toLowerCase())).toList();
        print("DB_HELPER: Filtered by '$searchTerm'. Found: ${exercises.length}");
      }
      return exercises;
    } catch (e) {
      print('DB_HELPER: Error in getAllJsonExercises: $e');
      return []; // Return empty on error
    }
  }

  Future<void> deleteJsonExercise(String id) async {
    final db = await instance.database;
    await db.delete(
      JsonExercisesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    // Also consider deleting related workout logs or handling them as needed
  }

  // --- CRUD for Workout Logs (Personal Records) ---
  Future<String> addWorkoutLog(WorkoutLogEntry logEntry) async {
    final db = await instance.database;
    // Assuming WorkoutLogEntry has a toMap() method similar to JsonExercise
    // And a unique id (e.g., generated using uuid package)
    // final String logId = Uuid().v4();
    // Map<String, dynamic> logMap = logEntry.toMap();
    // logMap['logId'] = logId; // If WorkoutLogEntry doesn't manage its own ID

    await db.insert(workoutLogsTable, logEntry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return logEntry.id; // Assuming logEntry has an id
  }

  Future<List<WorkoutLogEntry>> getWorkoutLogsForJsonExercise(
      String JsonExerciseId) async {
    final db = await instance.database;
    final result = await db.query(
      workoutLogsTable,
      where: 'JsonExerciseId = ?',
      whereArgs: [JsonExerciseId],
      orderBy: 'date ASC', // Important for progression charts
    );
    // Assuming WorkoutLogEntry has a fromMap factory
    return result.map((map) => WorkoutLogEntry.fromMap(map)).toList();
  }
}
