import 'package:flutter/material.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/cloud/cloud_note.dart';
import 'package:my_app/services/cloud/firebase_cloud_storage.dart';
import 'package:my_app/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:my_app/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() =>
      _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState
    extends State<CreateUpdateNoteView> {
  // DatabaseNotes? _note;
  // late final Future<DatabaseNotes> _noteFuture; // ⭐ FIX
  // late final NotesService _notesService;
  // late final TextEditingController _textController;

  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;
  late final Future<CloudNote> _noteFuture;

  @override
  void dispose() {
    _saveNoteIfNotEmpty(); // ⭐ correct order
    _deleteNoteIfEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _noteFuture = createOrGetExistingNote(context);
      });
    });
    super.initState();
  }

  // Create a new note in database ONCE
  Future<CloudNote> createOrGetExistingNote(
    BuildContext context,
  ) async {
    final args = context.getArgument<CloudNote?>();
    if (args != null) {
      _note = args;
      _textController.text = args.text;
      return args;
    }
    if (_note != null) {
      return _note!;
    }

    final user = AuthService.firebase().currentUser!;
    // final email = user.email;
    // final owner = await _notesService.createOrGetUser(
    //   email: email,
    // );

    final newNote = await _notesService.createNewNote(
      ownerUserId: user.id,
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
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  // Save note if user typed something
  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(
                  context: context,
                );
              } else {
                await SharePlus.instance.share(
                  ShareParams(text: text),
                );
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder<CloudNote>(
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
                decoration: InputDecoration(
                  hintText: 'Start typing your note...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
                onChanged: (value) async {
                  final note = _note;

                  if (note != null) {
                    await _notesService.updateNote(
                      documentId: note.documentId,
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
