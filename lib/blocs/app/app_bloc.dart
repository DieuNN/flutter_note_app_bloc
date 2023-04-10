import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:note_app/main.dart';
import 'package:note_app/models/enums/database_type.dart';
import 'package:note_app/repository/implements/note_hive_impl.dart';
import 'package:note_app/repository/implements/note_secure_storage_impl.dart';
import 'package:note_app/repository/implements/note_shared_prefs_impl.dart';
import 'package:note_app/repository/implements/note_sqlite_impl.dart';
import 'package:note_app/repository/note_repository.dart';

import '../../models/entity/note.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitialState()) {
    // Database type decided when run main function

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
    on<AppEvent>((event, emit) async {}, transformer: sequential());

    on<AppLoadNotesEvent>(
      (event, emit) async {
        emit(AppLoadingState());
        List<Note> notes = await database.getNotes();
        emit(AppLoadSuccessState(notes: notes));
      },
      transformer: sequential(),
    );
    on<AppRefreshEvent>(
      (event, emit) async {
        log("Refreshing ...");
        emit(AppRefreshingState());
        List<Note> notes = await database.getNotes();
        // await Future.delayed(const Duration(seconds: 10));
        emit(AppLoadSuccessState(notes: notes));
        log("Refresh completed!");
      },
      // transformer: sequential(),
    );
  }
}
