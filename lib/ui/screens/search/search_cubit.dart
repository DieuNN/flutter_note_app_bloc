import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/models/enums/search_status.dart';
import 'package:note_app/repository/note_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required this.repository}) : super(const SearchState());
  final NoteRepository repository;

  void search({required String keyword}) async {
    try {
      emit(state.copyOf(searchStatus: SearchStatus.searching));
      final result = await repository.searchNote(keyword: keyword);
      emit(state.copyOf(notes: result, searchStatus: SearchStatus.success));
    } catch (e) {
      emit(state.copyOf(searchStatus: SearchStatus.failure, notes: []));
    }
  }
}
