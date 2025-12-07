import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/services/cloud/cloud_note.dart';
import 'package:my_app/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  factory FirebaseCloudStorage() => _shared;

  FirebaseCloudStorage._sharedInstance();

  final notes = FirebaseFirestore.instance.collection(
    'notes',
  );

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  Future<List<CloudNote>> getAllNotes({
    required String ownerUserId,
  }) async {
    try {
      final allNotes =
          await notes
              .where('user_id', isEqualTo: ownerUserId)
              .get();
      return allNotes.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<void> createNewNote({
    required String ownerUserId,
    required String text,
  }) async {
    await notes.add({'user_id': ownerUserId, 'text': text});
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({'text': text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({
    required String documentId,
  }) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({
    required String ownerUserId,
  }) {
    return notes.snapshots().map(
      (event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId),
    );
  }
}
