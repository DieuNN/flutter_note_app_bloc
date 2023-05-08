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
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/screens/home_screen.dart';

late WidgetsBinding binding;
late DatabaseType databaseType;

Future<void> initDefaultDatabase() async {
  final instance = await SharedPreferences.getInstance();
  if (instance.getString("database_name") == null) {
    await instance.setString("database_name", "Sqlite");
  }
}

Future<String> getDatabaseName() async {
  final instance = await SharedPreferences.getInstance();
  return instance.getString("database_name") ?? "Sqlite";
}

Future<void> setDatabaseName(String name) async {
  final instance = await SharedPreferences.getInstance();
  await instance.setString("database_name", name);
}

Future<void> setDatabaseType() async {
  final instance = await SharedPreferences.getInstance();
  switch (instance.getString("database_name")) {
    case "Sqlite":
      databaseType = DatabaseType.sqlite;
      break;
    case "Shared Preference":
      databaseType = DatabaseType.sharedPreferences;
      break;
    case "Hive":
      databaseType = DatabaseType.hive;
      break;
    case "Secure Storage":
      databaseType = DatabaseType.secureStorage;
      break;
    default:
      databaseType = DatabaseType.sqlite;
      break;
  }
  log("Database type selected: ${databaseType.name}");
}

void main() async {
  binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await initDefaultDatabase();
  await setDatabaseType();

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
          create: (context) => AppBloc()..add(AppLoadNotesEvent()),
        ),
        BlocProvider(
          create: (context) => NoteBloc()..add(NoteInitEvent()),
        ),
        BlocProvider(
          create: (context) => EditorBloc()..add(InitialEditor()),
        ),
      ],
      child: BlocConsumer<AppBloc, AppState>(
        listener: (context, state) {
          if (state is AppLoadSuccessState) {
            FlutterNativeSplash.remove();
          }
        },
        buildWhen: (previous, current) {
          if (previous is AppLoadingState && current is AppLoadSuccessState) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          if (state is AppLoadSuccessState) {
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
              themeMode: ThemeMode.dark,
              routes: {
                "/": (context) => HomeScreen(notes: state.notes),
                "/search": (context) => const SearchScreen(),
                "/detail": (context) => const NoteEditor(),
              },
              initialRoute: "/",
              debugShowCheckedModeBanner: false,
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
              backgroundColor: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
