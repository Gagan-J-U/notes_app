import 'auth_user.dart';

abstract class AuthProvider {
  Future<AuthUser?> createUser({
    required String email,
    required String password,
  });

  Future<AuthUser?> logIn({
    required String email,
    required String password,
  });

  AuthUser? get currentUser;

  Future<void> logOut();

  Future<void> sendEmailVerification();
}
