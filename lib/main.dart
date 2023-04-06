import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:note_app/blocs/app/app_bloc.dart';
import 'package:note_app/blocs/editor/editor_bloc.dart';
import 'package:note_app/blocs/note/note_bloc.dart';
import 'package:note_app/ui/screens/search_screen.dart';
import 'package:note_app/ui/screens/note_editor_screen.dart';

import 'ui/screens/home_screen.dart';

late WidgetsBinding binding;

void main() async {
  binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        BlocProvider(
          create: (context) => AppBloc()..add(AppLoadNotesEvent()),
        ),
        BlocProvider(
          create: (context) => NoteBloc()..add(NoteInitEvent()),
        ),
        BlocProvider(create: (context) => EditorBloc()..add(InitialEditor()),),
      ],
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state is AppLoadingState || state is AppInitialState) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                backgroundColor: Colors.white,
              ),
            );
          } else {
            FlutterNativeSplash.remove();
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
              themeMode: ThemeMode.dark,
              routes: {
                "/": (context) =>
                    HomeScreen(notes: (state as AppReadyState).notes),
                "/search": (context) =>  SearchScreen(),
                "/detail": (context) => const NoteEditor(),
              },
              initialRoute: "/",
              debugShowCheckedModeBanner: false,
            );
          }
        },
      ),
    );
  }
}
