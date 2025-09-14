import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController =
      TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My first app"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: 'enter your password',
              ),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
            TextButton(
              onPressed: () async {
                final email = _emailController.text;
                final password = _passwordController.text;
                try {
                  await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                  final user =
                      FirebaseAuth.instance.currentUser;
                  if (user != null && user.emailVerified) {
                    await Navigator.of(
                      context,
                    ).pushReplacementNamed('/home');
                  } else if (user != null &&
                      !user.emailVerified) {
                    await Navigator.of(
                      context,
                    ).pushNamed('/verify-email');
                  }
                } on FirebaseAuthException catch (e) {
                  // Handle Firebase specific errors
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error: ${e.message}',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  // Handle other errors
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text('An error occurred'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed('/register');
              },
              child: const Text(
                'Not registered yet? Register here!',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
