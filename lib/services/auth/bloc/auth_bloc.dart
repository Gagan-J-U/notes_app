import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/services/auth/auth_provider.dart';
import 'package:my_app/services/auth/bloc/auth_event.dart';
import 'package:my_app/services/auth/bloc/auth_states.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
    : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventInitialize>((event, emit) async {
      // Handle initialization event
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
            loadingText: '',
          ),
        );
      } else if (!user.isEmailVerified) {
        emit(
          const AuthStateNeedsVerification(
            isLoading: false,
          ),
        );
      } else {
        emit(
          AuthStateLoggedIn(user: user, isLoading: false),
        );
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      // Handle login event
      emit(
        AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while we log you in.',
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
            emit(
              AuthStateLoggedIn(
                user: user,
                isLoading: false,
              ),
            );
          } else {
            emit(
              const AuthStateNeedsVerification(
                isLoading: false,
              ),
            );
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
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Logging out...',
        ),
      );
      // Handle logout event
      try {
        await provider.logOut();
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
            loadingText: 'Logging out...',
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
        emit(
          const AuthStateNeedsVerification(
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
        emit(
          const AuthStateNeedsVerification(
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

    on<AuthEventShouldRegister>((event, emit) {
      // Handle should register event
      emit(const AuthStateRegister(isLoading: false));
    });

    on<AuthEventForgotPassword>((event, emit) async {
      emit(
        AuthStateForgotPassword(
          hasSentEmail: false,
          exception: null,
          isLoading: false,
        ),
      );
      if (event.email != null) {
        // User has provided an email, send reset email
        emit(
          AuthStateForgotPassword(
            hasSentEmail: false,
            exception: null,
            isLoading: true,
          ),
        );
        try {
          await provider.sendPasswordResetEmail(
            toEmail: event.email!,
          );
          emit(
            AuthStateForgotPassword(
              hasSentEmail: true,
              exception: null,
              isLoading: false,
            ),
          );
        } catch (e) {
          emit(
            AuthStateForgotPassword(
              hasSentEmail: false,
              exception: e as Exception,
              isLoading: false,
            ),
          );
        }
      } else {
        return;
      }
    });
  }
}
