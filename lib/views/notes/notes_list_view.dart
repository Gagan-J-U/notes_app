import 'package:flutter/material.dart';
import 'package:my_app/services/cloud/cloud_note.dart';
import 'package:my_app/utilities/dialogs/delete_dialog.dart';

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final void Function(CloudNote) onDeleteNote;
  final void Function(CloudNote) onTapNote;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTapNote,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: ListTile(
            onTap: () {
              onTapNote(note);
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              note.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, size: 20),
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
          ),
        );
      },
    );
  }
}
