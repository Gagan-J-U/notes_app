import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/constants/routes.dart';

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
    ) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        if (mounted) {
          _timer?.cancel();
          Navigator.of(
            context,
          ).pushReplacementNamed(homeRoute);
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
          Text("Please verify your email"),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.currentUser
                  ?.sendEmailVerification();
            },
            child: Text("Send verification email"),
          ),
        ],
      ),
    );
  }
}
