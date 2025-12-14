import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/services/auth/bloc/auth_bloc.dart';
import 'package:my_app/services/auth/bloc/auth_event.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  void initState() {
    super.initState();
    // Periodically check email verification status
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Email")),
      body: Column(
        children: [
          Text(
            'press the button below to send a verification email to your email address.',
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                AuthEventSendEmailVerification(),
              );
            },
            child: Text("Send verification email"),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                const AuthEventLogOut(),
              );
            },
            child: Text("Restart"),
          ),
        ],
      ),
    );
  }
}
