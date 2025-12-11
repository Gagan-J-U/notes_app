import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/constants/routes.dart';
import 'package:my_app/enums/menu_action.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/auth/auth_user.dart';
import 'package:my_app/services/auth/bloc/auth_bloc.dart';
import 'package:my_app/services/auth/bloc/auth_event.dart';
import 'package:my_app/services/cloud/cloud_note.dart';
import 'package:my_app/services/cloud/firebase_cloud_storage.dart';
import 'package:my_app/utilities/dialogs/logout_dialog.dart';
import 'package:my_app/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);
  @override
  NotesViewState createState() => NotesViewState();
}

class NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;

  AuthUser get userEmail =>
      AuthService.firebase().currentUser!;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
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
                  context.read<AuthBloc>().add(
                    AuthEventLogOut(),
                  );
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

      body: StreamBuilder(
        stream: _notesService.allNotes(
          ownerUserId: userEmail.id,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final notes =
              snapshot.data as Iterable<CloudNote>;

          if (notes.isEmpty) {
            return const Center(
              child: Text("No notes yet."),
            );
          }

          return NotesListView(
            notes: notes,
            onDeleteNote: (note) async {
              await _notesService.deleteNote(
                documentId: note.documentId,
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
      ),
    );
  }
}
