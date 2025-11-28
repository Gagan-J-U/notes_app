import 'package:flutter/material.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/enums/menu_action.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/crud/notes_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late final NotesService _notesService;
  late final Future<void> _userFuture;

  String get userEmail =>
      AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    _userFuture = _notesService.createOrGetUser(
      email: userEmail,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.firebase().currentUser;

    if (user == null || !user.isEmailVerified) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, loginRoute);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes"),
        centerTitle: true,
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              if (value == MenuAction.logout) {
                final shouldLogout = await showLogoutDialog(
                  context,
                );
                if (shouldLogout) {
                  await AuthService.firebase().logOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      loginRoute,
                      (_) => false,
                    );
                  }
                }
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(
                    value: MenuAction.logout,
                    child: Text("Logout"),
                  ),
                ],
          ),
        ],
      ),

      body: FutureBuilder(
        future: _userFuture, // Future runs only ONCE
        builder: (context, snapshot) {
          if (snapshot.connectionState !=
              ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return StreamBuilder<List<DatabaseNotes>>(
            stream: _notesService.allNotes,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final notes = snapshot.data!;

              if (notes.isEmpty) {
                return const Center(
                  child: Text("No notes yet."),
                );
              }

              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(title: Text(note.text));
                },
              );
            },
          );
        },
      ),
    );
  }
}

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
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sign out"),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
