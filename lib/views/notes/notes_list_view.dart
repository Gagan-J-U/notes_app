import 'package:flutter/material.dart';
import 'package:my_app/services/crud/notes_service.dart';
import 'package:my_app/utilities/dialogs/delete_dialog.dart';

class NotesListView extends StatelessWidget {
  final List<DatabaseNotes> notes;
  final void Function(DatabaseNotes) onDeleteNote;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(
                context: context,
                title: 'Delete Note',
                content:
                    'Are you sure you want to delete this note?',
              );
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
          ),
        );
      },
    );
  }
}
