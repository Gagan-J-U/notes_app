import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'please wait a moment',
  });
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({
    required this.user,
    required super.isLoading,
  });
}

class AuthStateLoggedOut extends AuthState
    with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required super.isLoading,
    super.loadingText,
  });

  @override
  List<Object?> get props => [isLoading, exception];
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({
    required super.isLoading,
  });
}

class AuthStateRegister extends AuthState {
  const AuthStateRegister({required super.isLoading});
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});
}

class AuthStateForgotPassword extends AuthState {
  final bool hasSentEmail;
  final Exception? exception;
  const AuthStateForgotPassword({
    required this.hasSentEmail,
    required this.exception,
    required super.isLoading,
  });
}
