part of 'search_cubit.dart';

class SearchState extends Equatable {
  final List<Note>? notes;
  final SearchStatus searchStatus;

  const SearchState({this.notes, this.searchStatus = SearchStatus.initial});

  SearchState copyOf({List<Note>? notes, SearchStatus? searchStatus}) =>
      SearchState(
        notes: notes ?? this.notes,
        searchStatus: searchStatus ?? this.searchStatus,
      );

  @override
  List<Object?> get props => [notes, searchStatus];
}
