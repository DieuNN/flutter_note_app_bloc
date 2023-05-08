import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/models/enums/load_status.dart';
import 'package:note_app/repository/note_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  final NoteRepository noteRepository;

  AppCubit({required this.noteRepository}) : super(const AppState());

  void initialApp() {
    emit(state.copyWith(loadStatus: LoadStatus.initial));
  }

  void loadNotes() async {
    try {
      emit(state.copyWith(loadStatus: LoadStatus.loading));
      final notes = await noteRepository.getNotes();
      emit(state.copyWith(notes: notes, loadStatus: LoadStatus.success));
    } catch (e) {
      emit(state.copyWith(
          loadStatus: LoadStatus.failure, errorMessage: e.toString()));
    }
  }

  void refreshNote() async {
    try {
      emit(state.copyWith(loadStatus: LoadStatus.refreshing));
      final notes = await noteRepository.getNotes();
      emit(state.copyWith(loadStatus: LoadStatus.success, notes: notes));
    } catch (e) {
      emit(state.copyWith(
          loadStatus: LoadStatus.failure, errorMessage: e.toString()));
    }
  }
}
