// Mandatory: Import Firebase and Flutter packages if using Firebase features
import 'package:flutter/material.dart'; // Mandatory for every Flutter project
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/services/auth/auth_service.dart';
import 'package:my_app/services/auth/bloc/auth_bloc.dart';
import 'package:my_app/services/auth/bloc/auth_event.dart';
import 'package:my_app/services/auth/bloc/auth_states.dart';
import 'package:my_app/services/auth/firebase_auth_provider.dart';
import 'package:my_app/views/login_view.dart';
import 'package:my_app/views/notes/create_update_note_view.dart';
import 'package:my_app/views/notes/notes_view.dart';
import 'package:my_app/views/register_view.dart';
import 'package:my_app/views/verifyemail_view.dart';

import 'constants/routes.dart';

// Mandatory: Main entry point for every Flutter app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.firebase().initialize();

  runApp(
    BlocProvider(
      create: (_) => AuthBloc(FirebaseAuthProvider()),
      child: MaterialApp(
        title: 'Flutter Demo',
        home: const HomePage(),
        routes: {
          createUpdateNoteRoute:
              (context) => const CreateUpdateNoteView(),
        },
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(
      const AuthEventInitialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmail();
        } else if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateRegister) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: Center(
              child: Text('Something went wrong!'),
            ),
          );
        }
      },
    );
  }
}

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CounterBloc(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Counter Bloc Example'),
//         ),
//         body: BlocConsumer<CounterBloc, CounterState>(
//           listener: (context, state) {
//             _controller.clear();
//           },
//           builder: (context, state) {
//             final invalidValue =
//                 (state is CounterStateInvalid)
//                     ? state.invalidValue
//                     : null;
//             return Column(
//               children: [
//                 Text('Current Value: ${state.value}'),
//                 Visibility(
//                   visible: state is CounterStateInvalid,
//                   child: Text(
//                     'Invalid input: $invalidValue',
//                   ),
//                 ),
//                 TextField(
//                   controller: _controller,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter a number',
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         final input = _controller.text;
//                         context.read<CounterBloc>().add(
//                           IncrementEvent(input),
//                         );
//                       },
//                       child: const Icon(Icons.add),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         final input = _controller.text;
//                         context.read<CounterBloc>().add(
//                           DecrementEvent(input),
//                         );
//                       },
//                       child: const Icon(Icons.remove),
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// @immutable
// abstract class CounterState {
//   final int value;
//   const CounterState(this.value);
// }

// class CounterStateValid extends CounterState {
//   const CounterStateValid(int value) : super(value);
// }

// class CounterStateInvalid extends CounterState {
//   final String invalidValue;
//   const CounterStateInvalid({
//     required this.invalidValue,
//     required int previousValue,
//   }) : super(previousValue);
// }

// abstract class CounterEvent {
//   final String value;
//   const CounterEvent(this.value);
// }

// class IncrementEvent extends CounterEvent {
//   const IncrementEvent(String value) : super(value);
// }

// class DecrementEvent extends CounterEvent {
//   const DecrementEvent(String value) : super(value);
// }

// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc() : super(const CounterStateValid(0)) {
//     on<IncrementEvent>((event, emit) {
//       final int? parsedValue = int.tryParse(event.value);
//       if (parsedValue != null) {
//         emit(CounterStateValid(state.value + parsedValue));
//       } else {
//         emit(
//           CounterStateInvalid(
//             invalidValue: event.value,
//             previousValue: state.value,
//           ),
//         );
//       }
//     });

//     on<DecrementEvent>((event, emit) {
//       final int? parsedValue = int.tryParse(event.value);
//       if (parsedValue != null) {
//         emit(CounterStateValid(state.value - parsedValue));
//       } else {
//         emit(
//           CounterStateInvalid(
//             invalidValue: event.value,
//             previousValue: state.value,
//           ),
//         );
//       }
//     });
//   }
// }
