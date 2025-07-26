import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/login_page.dart';
import '../pages/main_page.dart';
import '../services/auth_service.dart';
import 'login_or_register.dart';

/*
  Listens to the auth stream
  If user is logged in, shows main page of app for ease of use
  If user is not logged in, prompt them with login/register page
*/

// Widget to decide which page to show based on auth state
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    if (authService.isAuthenticated) {
      return const MainPage(); // Or your main app screen
    } else {
      return const LoginOrRegister(); // Or your login/signup screen
    }
  }
}
