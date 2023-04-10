import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_app/blocs/app/app_bloc.dart';
import 'package:note_app/blocs/editor/editor_bloc.dart';
import 'package:note_app/blocs/note/note_bloc.dart';
import 'package:note_app/models/enums/database_type.dart';
import 'package:note_app/ui/screens/search_screen.dart';
import 'package:note_app/ui/screens/note_editor_screen.dart';

import 'ui/screens/home_screen.dart';

late WidgetsBinding binding;
late DatabaseType databaseType;

void main() async {
  binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  databaseType = DatabaseType.sqlite;

  if (databaseType == DatabaseType.hive) {
    await Hive.initFlutter();
  }

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
          create: (context) => AppBloc()..add(AppInitialEvent()),
        ),
        BlocProvider(
          create: (context) => NoteBloc()..add(NoteInitEvent()),
        ),
        BlocProvider(
          create: (context) => EditorBloc()..add(InitialEditor()),
        ),
      ],
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          FlutterNativeSplash.remove();
          log("Current app state is: ${state.runtimeType}");
          if (state is AppInitialState || state is AppLoadingState) {
            if (state is AppInitialState) {
              context.read<AppBloc>().add(AppLoadNotesEvent());
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                backgroundColor: Colors.white,
              ),
            );
          }
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
            themeMode: ThemeMode.dark,
            routes: {
              "/": (context) =>
                  HomeScreen(notes: (state as AppLoadSuccessState).notes),
              "/search": (context) => SearchScreen(),
              "/detail": (context) => const NoteEditor(),
            },
            initialRoute: "/",
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
