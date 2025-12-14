import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/services/auth/auth_provider.dart';
import 'package:my_app/services/auth/bloc/auth_event.dart';
import 'package:my_app/services/auth/bloc/auth_states.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
    : super(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ),
      ) {
    on<AuthEventInitialize>((event, emit) async {
      // Handle initialization event
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user: user));
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      // Handle login event
      emit(
        AuthStateLoggedOut(
          exception: null,
          isLoading: true,
        ),
      );
      try {
        final user = await provider.logIn(
          email: event.email,
          password: event.password,
        );
        if (user != null) {
          emit(
            AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
          if (user.isEmailVerified) {
            emit(AuthStateLoggedIn(user: user));
          } else {
            emit(const AuthStateNeedsVerification());
          }
        }
      } catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e as Exception,
            isLoading: false,
          ),
        );
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      // Handle logout event
      try {
        await provider.logOut();
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e as Exception,
            isLoading: false,
          ),
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
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      }
    });

    on<AuthEventRegister>((event, emit) async {
      try {
        await provider.createUser(
          email: event.email,
          password: event.password,
        );

        // Newly registered users are always NOT verified
        emit(const AuthStateNeedsVerification());
      } catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e as Exception,
            isLoading: false,
          ),
        );
      }
    });

    on<AuthEventShouldRegister>((event, emit) {
      // Handle should register event
      emit(const AuthStateRegister());
    });
  }
}
