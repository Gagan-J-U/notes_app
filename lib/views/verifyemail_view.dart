import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/auth/bloc/auth_bloc.dart';
import 'package:my_app/services/auth/bloc/auth_event.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Periodically check email verification status
    _timer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) {
      AuthService.firebase().reload;
      final user = AuthService.firebase().currentUser;
      if (user != null && user.isEmailVerified) {
        if (mounted) {
          _timer?.cancel();
          Navigator.of(
            context,
          ).pushReplacementNamed(notesRoute);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Email")),
      body: Column(
        children: [
          Text(
            "We have sent you an email verification. Please open it to verify your account.",
          ),
          Text(
            'If you have not received a verification email yet, press the button below.',
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                AuthEventSendEmailVerification(),
              );
            },
            child: Text("Send verification email"),
          ),
        ],
      ),
    );
  }
}
