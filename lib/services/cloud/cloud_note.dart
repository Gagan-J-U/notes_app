import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/services/cloud/cloud_storage_constants.dart';

class CloudNote {
  final String ownerUserId;
  final String text;
  final String documentId;
  CloudNote({
    required this.ownerUserId,
    required this.text,
    required this.documentId,
  });

  factory CloudNote.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final ownerUserId =
        snapshot.data()[ownerUserIdFeildName] as String;
    final documentId = snapshot.id;
    final text = snapshot.data()[textFieldName] as String;
    return CloudNote(
      ownerUserId: ownerUserId,
      text: text,
      documentId: documentId,
    );
  }
}
