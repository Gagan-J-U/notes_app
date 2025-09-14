// Mandatory: Import Firebase and Flutter packages if using Firebase features
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; // Mandatory for every Flutter project
import 'package:my_app/firebase_options.dart';
import 'package:my_app/views/homePage.dart';
import 'package:my_app/views/login_view.dart';
import 'package:my_app/views/register_view.dart';
import 'package:my_app/views/verifyemail_view.dart';

// Mandatory: Main entry point for every Flutter app
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Mandatory if you use async code before runApp (e.g., Firebase)

  // Initialize Firebase once for the entire app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      title: 'Flutter Demo', // Optional: App title
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor:
              Colors.deepPurple, // Optional: Custom theme
        ),
      ),
      home:
          const AuthGate(), // This starts the app from HomePage
      routes: {
        '/login': (context) => LoginView(),
        '/register': (context) => RegisterView(),
        '/home': (context) => HomePage(),
        '/verify-email': (context) => VerifyEmail(),
      },
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null || !user.emailVerified) {
          return const LoginView();
        } else {
          return const HomePage();
        }
      },
    );
  }
}
