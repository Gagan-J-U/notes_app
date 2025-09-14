import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in → show login
      Future.microtask(() {
        Navigator.of(context).pushNamed('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My first app"),
          centerTitle: true,
        ),
        body: Center(
          child: Text("Logged in as ${user.email}"),
        ),
      );
    }
  }
}
