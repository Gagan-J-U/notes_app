import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String email;
  final bool isEmailVerified;
  const AuthUser(this.id, this.email, this.isEmailVerified);
  factory AuthUser.fromFirebase(User user) =>
      AuthUser(user.uid, user.email!, user.emailVerified);
}
