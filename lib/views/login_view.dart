import 'package:flutter/material.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/services/auth/auth_exceptions.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await AuthService.firebase().logIn(
        email: email,
        password: password,
      );

      final user = AuthService.firebase().currentUser;

      if (user != null) {
        if (user.isEmailVerified) {
          if (mounted) {
            Navigator.of(
              context,
            ).pushReplacementNamed(homeRoute);
          }
        } else {
          if (mounted) {
            Navigator.of(
              context,
            ).pushReplacementNamed(verifyEmailRoute);
          }
        }
      }
    } on UserNotFoundAuthException {
      await showErrorDialog(
        context,
        'No user found with this email.',
      );
    } on WrongPasswordAuthException {
      await showErrorDialog(context, 'Incorrect password.');
    } on InvalidEmailAuthException {
      await showErrorDialog(
        context,
        'Invalid email format.',
      );
    } on GenericAuthException {
      await showErrorDialog(
        context,
        'Authentication failed.',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              ),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed(registerRoute);
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
