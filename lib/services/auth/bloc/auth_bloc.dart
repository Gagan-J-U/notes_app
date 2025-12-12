import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/services/auth/auth_provider.dart';
import 'package:my_app/services/auth/bloc/auth_event.dart';
import 'package:my_app/services/auth/bloc/auth_states.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
    : super(const AuthStateLoading()) {
    on<AuthEventInitialize>((event, emit) async {
      // Handle initialization event
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut());
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user: user));
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      // Handle login event
      try {
        final user = await provider.logIn(
          email: event.email,
          password: event.password,
        );
        if (user != null) {
          if (user.isEmailVerified) {
            emit(AuthStateLoggedIn(user: user));
          } else {
            emit(const AuthStateNeedsVerification());
          }
        }
      } catch (e) {
        emit(AuthStateLoggedOut(exception: e as Exception));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      // Handle logout event
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut());
      } catch (e) {
        emit(
          AuthStateLogoutFailure(exception: e as Exception),
        );
      }
    });

    on<AuthEventSendEmailVerification>((event, emit) {
      // Handle send email verification event
      provider.sendEmailVerification();
      final user = provider.currentUser;
      if (user != null && !user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(const AuthStateLoggedOut());
      }
    });

    on<AuthEventRegister>((event, emit) {
      // Handle register event
      try {
        provider
            .createUser(
              email: event.email,
              password: event.password,
            )
            .then((user) {
              if (user != null) {
                emit(const AuthStateNeedsVerification());
              } else {
                emit(const AuthStateLoggedOut());
              }
            });
      } catch (e) {
        emit(AuthStateLoggedOut(exception: e as Exception));
      }
    });
  }
}
