import 'package:flutter/material.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/enums/menu_action.dart';
import 'package:my_app/services/auth/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.firebase().currentUser;

    // If user is null or not verified → redirect to login
    if (user == null || !user.isEmailVerified) {
      Future.microtask(() {
        Navigator.of(
          context,
        ).pushReplacementNamed(loginRoute);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My First App"),
        centerTitle: true,
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout =
                      await showLogoutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    }
                  }
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text("Logout"),
                  ),
                ],
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Logged in as ${user.isEmailVerified ? user : 'Unknown'}",
        ),
      ),
    );
  }
}

/// Shows a logout confirmation dialog
Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Sign out"),
        content: const Text(
          "Are you sure you want to sign out?",
        ),
        actions: [
          TextButton(
            onPressed:
                () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed:
                () => Navigator.of(context).pop(true),
            child: const Text("Sign out"),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
