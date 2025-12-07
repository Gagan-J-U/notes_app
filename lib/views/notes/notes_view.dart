import 'package:flutter/material.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/enums/menu_action.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/crud/notes_service.dart';
import 'package:my_app/utilities/dialogs/logout_dialog.dart';
import 'package:my_app/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);
  @override
  NotesViewState createState() => NotesViewState();
}

class NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  late Future<void> _userFuture;

  String get userEmail =>
      AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _notesService = NotesService();

    // ⭐ FIX 1: load user THEN load notes from SQLite
    _userFuture = _notesService
        .createOrGetUser(email: userEmail)
        .then((_) async {
          await _notesService.getAllNotesForUser();
        });

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
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                createUpdateNoteRoute,
              );
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              if (value == MenuAction.logout) {
                final shouldLogout = await showLogoutDialog(
                  context: context,
                  title: 'Logout',
                  content:
                      'Are you sure you want to log out?',
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

          return StreamBuilder(
            stream: _notesService.allNotes,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final notes =
                  snapshot.data as List<DatabaseNotes>;

              if (notes.isEmpty) {
                return const Center(
                  child: Text("No notes yet."),
                );
              }

              return NotesListView(
                notes: notes,
                onDeleteNote: (note) async {
                  await _notesService.deleteNote(
                    id: note.id,
                  );
                },
                onTapNote: (note) async {
                  await Navigator.pushNamed(
                    context,
                    createUpdateNoteRoute,
                    arguments: note,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
