import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:note_app/repository/note_sqlite_repository.dart';

import '../../models/entity/note.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final NoteSqliteRepositoryImpl database = NoteSqliteRepositoryImpl();

  AppBloc() : super(AppInitialState()) {
    on<AppEvent>((event, emit) {});
    on<AppLoadNotesEvent>(
      (event, emit) async {
        List<Note>? notes = await database.getNotes();
        emit(AppReadyState(notes: notes ?? []));
      },
    );
  }
}
