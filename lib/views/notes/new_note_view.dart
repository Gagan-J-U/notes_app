import 'package:flutter/material.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/crud/notes_service.dart';

class NewNotesView extends StatefulWidget {
  const NewNotesView({super.key});

  @override
  State<NewNotesView> createState() => _NewNotesViewState();
}

class _NewNotesViewState extends State<NewNotesView> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;
  late final Future<DatabaseNotes> _noteFuture; // ⭐ FIX

  // Create a new note in database ONCE
  Future<DatabaseNotes> createNewNote() async {
    if (_note != null) {
      return _note!;
    }

    final user = AuthService.firebase().currentUser!;
    final email = user.email!;
    final owner = await _notesService.createOrGetUser(
      email: email,
    );

    final newNote = await _notesService.createNote(
      owner: owner,
      text: '',
    );

    _note = newNote;
    return newNote;
  }

  // Delete note if user leaves it empty
  void _deleteNoteIfEmpty() {
    final note = _note;
    final text = _textController.text;

    print("DELETE CHECK: $text");

    if (note != null && text.isEmpty) {
      _notesService.deleteNote(id: note.id);
    }
  }

  // Save note if user typed something
  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;

    print("SAVE CHECK: $text");

    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();

    // ⭐ FIX: Future created only once
    _noteFuture = createNewNote();

    super.initState();
  }

  @override
  void dispose() {
    _saveNoteIfNotEmpty(); // ⭐ correct order
    _deleteNoteIfEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: FutureBuilder(
        future: _noteFuture, // ⭐ FIXED: use stored future
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note...',
                ),
                onChanged: (value) async {
                  final note = _note;
                  if (note != null) {
                    await _notesService.updateNote(
                      note: note,
                      text: value,
                    );
                  }
                },
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
