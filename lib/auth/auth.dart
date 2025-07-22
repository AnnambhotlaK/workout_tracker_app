import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/login_page.dart';
import '../pages/main_page.dart';
import 'login_or_register.dart';

/*
  Listens to the auth stream
  If user is logged in, shows main page of app for ease of use
  If user is not logged in, prompt them with login page
*/

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user logged in
          if (snapshot.hasData) {
            return const MainPage();
          }
          // user not logged in
          else {
            return LoginOrRegister();
          }
        }
      )
    );
  }
}
