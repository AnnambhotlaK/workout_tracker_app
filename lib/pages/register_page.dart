import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:main/components/login_text_field.dart';
import 'package:main/components/signin_button.dart';
import '../helper_functions.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // login via firebase
  Future<void> registerUser() async {
    setState(() {
      _isLoading = true;
    });

    // if password don't match, pop and show error
    if (passwordController.text != confirmPasswordController.text) {
      // pop loading circle
      Navigator.pop(context);
      // show error message
      displayMessageToUser("Passwords do not match!", context);
    }
    // Otherwise, try creating user
    else {
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);
        if (context.mounted) Navigator.pop(context);
      }
      on FirebaseAuthException catch (e) {
        // pop loading
        //if (context.mounted) Navigator.pop(context);
        displayMessageToUser(e.message.toString(), context);
      }
      finally {
        // hide loading
        setState(() {
          _isLoading = false;
        });
      }
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
          const Text('Join Onfinity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
              )),
          const SizedBox(height: 25),

          // username textfield
          LoginTextField(
              hintText: "Username",
              obscureText: false,
              controller: usernameController),
          const SizedBox(height: 10),

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

          // password textfield
          LoginTextField(
              hintText: "Confirm Password",
              obscureText: true,
              controller: confirmPasswordController),
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
          SigninButton(text: "Register", onTap: _isLoading ? null : registerUser),
          const SizedBox(height: 10),

          // don't have account? Register button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account?"),
              GestureDetector(
                onTap: widget.onTap,
                child: const Text(" Login Here",
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
