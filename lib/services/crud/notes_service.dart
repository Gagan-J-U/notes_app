import 'dart:async';

import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show
        MissingPlatformDirectoryException,
        getApplicationDocumentsDirectory;
import 'package:sqflite/sqflite.dart';

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectoryException
    implements Exception {}

class DatabaseNotOpenException implements Exception {}

class CouldNotDeleteUserException implements Exception {}

class UserAlreadyExistsException implements Exception {}

class CouldNotFindUserException implements Exception {}

class CouldNotDeleteNoteException implements Exception {}

class CouldNotFindNoteException implements Exception {}

class NotesService {
  factory NotesService() => _shared;

  NotesService._sharedInstance() {
    _notesStreamController =
        StreamController<List<DatabaseNotes>>.broadcast(
          onListen: () {
            _notesStreamController.sink.add(_notes);
          },
        );
  }

  static final NotesService _shared =
      NotesService._sharedInstance();

  Database? _db;
  final List<DatabaseNotes> _notes = [];
  late final StreamController<List<DatabaseNotes>>
  _notesStreamController;

  // ignore: unused_element
  Future<Database> get _getDatabase async {
    _db ??= await _openDB('notes.db');
    return _db!;
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    }
    await db.close();
    _db = null;
  }

  Future<DatabaseUser> createUser({
    required String email,
  }) async {
    final db = await _getDatabase;
    final results = await db.query(
      'users',
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final userId = await db.insert('users', {
      'email': email.toLowerCase(),
    });
    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser?> getUser({
    required String email,
  }) async {
    final db = await _getDatabase;
    final results = await db.query(
      'users',
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    }
    return DatabaseUser.fromRow(results.first);
  }

  Future<void> deleteUser({required String email}) async {
    final db = await _getDatabase;
    final deletedCount = await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseNotes> createNote({
    required DatabaseUser owner,
    required String text,
  }) async {
    final dbUser = await getUser(email: owner.email);
    //make sure owner exists with correct id
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }
    final db = await _getDatabase;
    final noteId = await db.insert('notes', {
      'user_id': owner.id,
      'text': text,
      'is_synced_with_cloud': 1,
    });
    final note = DatabaseNotes(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: false,
    );
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<DatabaseNotes> updateNote({
    required DatabaseNotes note,
    required String text,
  }) async {
    final db = await _getDatabase;
    final updatedCount = await db.update(
      'notes',
      {'text': text, 'is_synced_with_cloud': 0},
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (updatedCount != 1) {
      throw CouldNotFindUserException();
    }
    final updatedNote = DatabaseNotes(
      id: note.id,
      userId: note.userId,
      text: text,
      isSyncedWithCloud: false,
    );
    _notes.removeWhere((n) => n.id == note.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    final db = await _getDatabase;
    final results = await db.query(
      'notes',
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw CouldNotFindNoteException();
    }
    return DatabaseNotes.fromRow(results.first);
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    final db = await _getDatabase;
    final notes = await db.query('notes');

    final results =
        notes.map((noteRow) {
          return DatabaseNotes.fromRow(noteRow);
        }).toList();
    _notes.clear();
    _notes.addAll(results);
    _notesStreamController.add(_notes);
    return results;
  }

  Future<void> deleteNote({required int id}) async {
    final db = await _getDatabase;
    final deletedCount = await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteNoteException();
    }
    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
  }

  Future<void> deleteAllNotes() async {
    final db = await _getDatabase;
    final deletedCount = await db.delete('notes');
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }
    _notes.clear();
    _notesStreamController.add(_notes);
  }

  Future<Database> _openDB(String dbName) async {
    try {
      final docsPath =
          await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE
          );
        ''');
          await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            text TEXT,
            is_synced_with_cloud INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (user_id) REFERENCES users(id)
          );
        ''');
        },
      );
      return db;
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }
}

class DatabaseUser {
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map['id'] as int,
      email = map['email'] as String;

  final String email;
  final int id;

  // Two users are considered equal if their database id is the same.
  @override
  bool operator ==(covariant DatabaseUser other) =>
      id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  // Convert this object to a Map suitable for inserting/updating with `sqflite`.
  Map<String, Object?> toMap() {
    return {'id': id, 'email': email};
  }
}

class DatabaseNotes {
  const DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    this.isSyncedWithCloud = false,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
    : id = map['id'] as int,
      userId = map['user_id'] as int,
      text = map['text'] as String,
      isSyncedWithCloud =
          (map['is_synced_with_cloud'] as int) == 1
              ? true
              : false;

  final int id;
  final bool isSyncedWithCloud;
  final String text;
  final int userId;

  @override
  bool operator ==(covariant DatabaseNotes other) =>
      id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, text = $text, isSyncedWithCloud = $isSyncedWithCloud';

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'text': text,
      'is_synced_with_cloud': isSyncedWithCloud,
    };
  }
}
