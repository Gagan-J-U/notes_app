import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/services/auth/auth_exceptions.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/auth/bloc/auth_bloc.dart';
import 'package:my_app/services/auth/bloc/auth_event.dart';
import 'package:my_app/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _isLoading = false; // <-- Loading state

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
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      context.read<AuthBloc>().add(
        AuthEventLogIn(email: email, password: password),
      );
    } on UserNotFoundAuthException {
      await showErrorDialog(
        context: context,
        title: 'Error',
        message: 'User not found.',
      );
    } on WrongPasswordAuthException {
      await showErrorDialog(
        context: context,
        title: 'Error',
        message: 'Incorrect password.',
      );
    } on InvalidEmailAuthException {
      await showErrorDialog(
        context: context,
        title: 'Error',
        message: 'Invalid email.',
      );
    } on GenericAuthException {
      await showErrorDialog(
        context: context,
        title: 'Error',
        message: 'Authentication failed.',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            // EMAIL FIELD
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              enabled:
                  !_isLoading, // Disable during loading
            ),
            const SizedBox(height: 12),

            // PASSWORD FIELD
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              ),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              enabled:
                  !_isLoading, // Disable during loading
            ),
            const SizedBox(height: 20),

            // LOGIN BUTTON OR LOADER
            _isLoading
                ? const CircularProgressIndicator()
                : TextButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),

            const SizedBox(height: 8),

            // REGISTER BUTTON (Disabled when loading)
            if (!_isLoading)
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
