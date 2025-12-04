import 'package:flutter/material.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/crud/notes_service.dart';
import 'package:my_app/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() =>
      _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState
    extends State<CreateUpdateNoteView> {
  DatabaseNotes? _note;
  late final Future<DatabaseNotes> _noteFuture; // ⭐ FIX
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void dispose() {
    _saveNoteIfNotEmpty(); // ⭐ correct order
    _deleteNoteIfEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _noteFuture = createOrGetExistingNote(context);
      });
    });
    super.initState();
  }

  // Create a new note in database ONCE
  Future<DatabaseNotes> createOrGetExistingNote(
    BuildContext context,
  ) async {
    final args = context.getArgument<DatabaseNotes?>();
    if (args != null) {
      _note = args;
      _textController.text = args.text;
      return args;
    }
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

    if (note != null && text.isEmpty) {
      _notesService.deleteNote(id: note.id);
    }
  }

  // Save note if user typed something
  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: FutureBuilder<DatabaseNotes>(
        future: _noteFuture, // ⭐ FIXED: use stored future
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.done) {
            print("snapshot.data = ${snapshot.data}");

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
                  print(
                    "onChanged fired with: $value | note: $_note",
                  );

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
