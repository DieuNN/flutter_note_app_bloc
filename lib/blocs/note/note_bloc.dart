import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/repository/note_sqlite_repository.dart';

part 'note_event.dart';

part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc() : super(NoteInitialState()) {
    log("${state.runtimeType}");
    final NoteSqliteRepositoryImpl noteSqlRepository =
        NoteSqliteRepositoryImpl();
    on<NoteEvent>((event, emit) {});
    on<NoteInitEvent>(
      (event, emit) {
        emit(NoteInitialState());
      },
    );
    on<NoteLoadEvent>(
      (event, emit) async {
        var id = event.id;
        emit(NoteLoadingState(id: id));
        var note = await noteSqlRepository.getNote(noteId: id);
        emit(NoteLoadedState(note: note!));
      },
    );
    on<NoteAddNewEvent>((event, emit) {
      emit(NewNoteState());
    },);
    on<NoteSaveEvent>(
      (event, emit) async {
        emit(NoteSavingState());
        var note = event.note;
        bool isSuccess = await noteSqlRepository.addNote(note: note);
        if (isSuccess) {
          emit(NoteSavedState(onSuccess: event.onSuccess));
        }
        emit(NoteSavedState(onFailure: event.onFailure));
        emit(NoteInitialState());
      },
    );
    on<NoteDeleteEvent>(
      (event, emit) async {
        emit(NoteDeletingState());
        bool isSuccess = await noteSqlRepository.deleteNote(id: event.id);
        if (isSuccess) {
          emit(NoteDeletedState(onSuccess: event.onSuccess));
        }
        emit(NoteDeletedState(onFailure: event.onFailure));
      },
    );
    on<NoteUpdateEvent>((event, emit) async {
      emit(NoteUpdatingState());
      bool isSuccess =
          await noteSqlRepository.updateNote(id: event.id, note: event.note);
      if (isSuccess) {
        emit(NoteUpdatedState(onSuccess: event.onSuccess));
      }
      emit(NoteUpdatedState(onFailure: event.onFailure));
    });
  }
}
