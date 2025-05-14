/*
  Used to store history of workouts completed
  Could be viewed by the user?
 */

import 'package:flutter/material.dart';
import 'package:main/data/hive_database.dart';
import 'package:main/datetime/date_time.dart';
import 'package:uuid/uuid.dart';

import '../models/workout.dart';
import 'package:main/models/exercise.dart';
import '../models/session.dart';