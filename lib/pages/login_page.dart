import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:main/components/login_text_field.dart';
import 'package:main/components/signin_button.dart';

import '../helper_functions.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  // login via firebase
  Future<void> login() async {
    // show loading
    setState(() {
      _isLoading = true;
    });

    // try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    }
    // Catch error
    on FirebaseAuthException {
      // show error
      displayMessageToUser("We couldn't find an account with those credentials!", context);
    }
    finally {
      // hide loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // logo
          Icon(
            Icons.person,
            size: 80,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          const SizedBox(height: 25),

          // app name
          const Text('Onfinity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
              )),
          const SizedBox(height: 25),

          // email textfield
          LoginTextField(
              hintText: "Email",
              obscureText: false,
              controller: emailController),
          const SizedBox(height: 10),

          // password textfield
          LoginTextField(
              hintText: "Password",
              obscureText: true,
              controller: passwordController),
          const SizedBox(height: 10),

          // forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // sign in button
          SigninButton(text: "Login", onTap: _isLoading ? null : login),
          const SizedBox(height: 10),

          // don't have account? Register button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              GestureDetector(
                onTap: widget.onTap,
                child: const Text(" Register Here",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          //
        ],
      ),
    )));
  }
}
