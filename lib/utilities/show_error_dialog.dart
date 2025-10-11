import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String e,
) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      String errorMessage;
      switch (e) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage =
              'This user account has been disabled.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found for that email.';
          break;
        case 'invalid-credential':
          errorMessage =
              'Incorrect password. Please try again.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Too many login attempts. Try again later.';
          break;
        case 'network-request-failed':
          errorMessage =
              'Network error. Check your internet connection.';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }
      return AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
