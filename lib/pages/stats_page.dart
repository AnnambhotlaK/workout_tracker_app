import 'package:flutter/material.dart';
import 'package:main/workout_data/curr_workout_data.dart';
import 'package:main/session_data/session_data.dart';
import 'package:main/models/session.dart';
import 'package:main/pages/workout_page.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
    );
  }
}