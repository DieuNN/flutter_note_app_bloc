import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_app/blocs/app_cubit.dart';
import 'package:note_app/blocs/editor/editor_bloc.dart';
import 'package:note_app/blocs/note/note_bloc.dart';
import 'package:note_app/models/enums/database_type.dart';
import 'package:note_app/models/enums/load_status.dart';
import 'package:note_app/repository/implements/note_hive_impl.dart';
import 'package:note_app/repository/implements/note_secure_storage_impl.dart';
import 'package:note_app/repository/implements/note_shared_prefs_impl.dart';
import 'package:note_app/repository/implements/note_sqlite_impl.dart';
import 'package:note_app/repository/note_repository.dart';
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
    final NoteRepository database;
    switch (databaseType) {
      case DatabaseType.sqlite:
        database = NoteSqliteRepositoryImpl();
        break;
      case DatabaseType.sharedPreferences:
        database = NoteSharedPreferencesRepositoryImpl();
        break;
      case DatabaseType.hive:
        database = NoteHiveRepositoryImpl();
        break;
      case DatabaseType.secureStorage:
        database = NoteSecureStorageImpl();
        break;
    }
    return MultiRepositoryProvider(
      providers: [
        BlocProvider(
          create: (context) => AppCubit(noteRepository: database)..loadNotes(),
        ),
        BlocProvider(
          create: (context) => NoteBloc()..add(NoteInitEvent()),
        ),
        BlocProvider(
          create: (context) => EditorBloc()..add(InitialEditor()),
        ),
      ],
      child: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
          if (state.loadStatus == LoadStatus.success) {
            FlutterNativeSplash.remove();
          }
        },
        buildWhen: (previous, current) {
          if (previous.loadStatus == LoadStatus.loading &&
              current.loadStatus == LoadStatus.success) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          log("Main state: ${state.loadStatus}");
          if (state.loadStatus == LoadStatus.success) {
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
              themeMode: ThemeMode.dark,
              routes: {
                "/": (context) => HomeScreen(notes: state.notes ?? []),
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
