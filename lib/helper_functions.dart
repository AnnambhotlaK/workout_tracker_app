import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options_dev.dart' as dev;
import 'firebase_options_prod.dart' as prod;

final devOptions = dev.DefaultFirebaseOptions.currentPlatform;
final prodOptions = prod.DefaultFirebaseOptions.currentPlatform;

Future<void> initializeFirebase({required bool isProd}) async {
  if (isProd) {
    await Firebase.initializeApp(
      options: prodOptions,
    );
  } else {
    await Firebase.initializeApp(
      options: devOptions,
    );
  }
}

void displayMessageToUser(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
