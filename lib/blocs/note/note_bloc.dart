import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:note_app/main.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/models/enums/database_type.dart';
import 'package:note_app/repository/implements/note_hive_impl.dart';
import 'package:note_app/repository/implements/note_secure_storage_impl.dart';
import 'package:note_app/repository/implements/note_shared_prefs_impl.dart';
import 'package:note_app/repository/note_repository.dart';

import '../../repository/implements/note_sqlite_impl.dart';

part 'note_event.dart';

part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc() : super(NoteInitialState()) {
    log("${state.runtimeType}");
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
    on<NoteEvent>((event, emit) {});
    on<NoteInitEvent>((event, emit) {
      emit(NoteInitialState());
    }, transformer: sequential());
    on<NoteLoadEvent>(
      (event, emit) async {
        emit(NoteLoadingState());
        var note = await database.getNote(noteId: event.id);
        if (note != null) {
          emit(NoteLoadSuccessState(note: note));
        } else {
          emit(const NoteLoadErrorState());
        }
      },
      transformer: sequential(),
    );
    on<NoteDeleteEvent>(
      (event, emit) async {
        emit(NoteDeletingState());
        int id = event.id;
        bool isSuccess = await database.deleteNote(id: id);
        if (isSuccess) {
          emit(const NoteDeleteSuccessState());
        } else {
          emit(const NoteDeleteErrorState());
        }
      },
      transformer: sequential(),
    );
    on<NoteAddEvent>(
      (event, emit) async {
        emit(NoteInitialState());
        emit(NoteAddingState());
        var note = event.note;
        bool isSuccess = await database.addNote(note: note);
        if (isSuccess) {
          emit(NoteAddSuccessState());
        } else {
          emit(NoteAddErrorState());
        }
      },
      transformer: sequential(),
    );
    on<NoteEditEvent>(
      (event, emit) async {
        log("Note edit");
        emit(NoteEditingState());
        bool isSuccess =
            await database.updateNote(newNote: event.note, id: event.id);
        log("In NoteEditEvent, color is: ${event.note.color}");
        if (isSuccess) {
          log("Note edit success");
          emit(NoteEditSuccessState());
        } else {
          log("Note edit error");
          emit(NoteEditErrorState());
        }
      },
      transformer: sequential(),
    );
    on<NoteSearchEvent>(
      (event, emit) async {
        emit(NoteSearchingState(keyword: event.keyword));
        var notes = await database.searchNote(keyword: event.keyword);
        emit(NoteSearchedState(notes: notes));
      },
      transformer: sequential(),
    );
  }
}
