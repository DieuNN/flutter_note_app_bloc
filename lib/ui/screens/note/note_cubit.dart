import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/models/enums/crud_status.dart';
import 'package:note_app/repository/note_repository.dart';

part 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  NoteCubit({required NoteRepository repository}) : _repository = repository, super(const NoteState());
  final NoteRepository _repository;

  void initialNote() {
    emit(state.copyWith(curdStatus: CrudStatus.initial));
  }

  void loadNote({required int noteId}) async {
    try {
      emit(state.copyWith(
        curdStatus: CrudStatus.loading,
      ));
      final note = await _repository.getNote(noteId: noteId);
      emit(state.copyWith(
        note: note,
        curdStatus: CrudStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
          curdStatus: CrudStatus.failure, errorMessage: e.toString()));
    }
  }

  void addNote({required Note note}) async {
    try {
      emit(state.copyWith(curdStatus: CrudStatus.loading));
      await _repository.addNote(note: note);
      emit(state.copyWith(curdStatus: CrudStatus.success));
    } catch (e) {
      log(e.toString());
      emit(state.copyWith(
          curdStatus: CrudStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> deleteNote({required int noteId}) async {
    try {
      emit(state.copyWith(curdStatus: CrudStatus.deleting));
      await _repository.deleteNote(id: noteId);
      emit(state.copyWith(curdStatus: CrudStatus.success));
    } catch (e) {
      emit(state.copyWith(
          curdStatus: CrudStatus.failure, errorMessage: e.toString()));
    }
  }

  void updateNote({required Note newNote, required int id}) async {
    try {
      emit(state.copyWith(curdStatus: CrudStatus.deleting));
      await _repository.updateNote(id: id, newNote: newNote);
      emit(state.copyWith(curdStatus: CrudStatus.success));
    } catch (e) {
      emit(state.copyWith(
          curdStatus: CrudStatus.failure, errorMessage: e.toString()));
    }
  }
}
