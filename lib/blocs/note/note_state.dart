part of 'note_bloc.dart';

abstract class NoteState extends Equatable {
  const NoteState();
}

class NoteInitialState extends NoteState {
  @override
  List<Object?> get props => [];
}

class NoteLoadingState extends NoteState {

  const NoteLoadingState();

  @override
  List<Object?> get props => [];
}

class NoteLoadSuccessState extends NoteState {
  final Note note;
  const NoteLoadSuccessState({required this.note});

  @override
  List<Object?> get props => [];
}

class NoteLoadErrorState extends NoteState {

  @override
  List<Object?> get props => throw UnimplementedError();

  const NoteLoadErrorState();
}



class NoteAddingState extends NoteState {
  @override
  List<Object?> get props => [];
}

class NoteAddSuccessState extends NoteState {
  @override
  List<Object?> get props => [];
}

class NoteAddErrorState extends NoteState {
  @override
  List<Object?> get props => [];
}

class NoteEditingState extends NoteState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class NoteEditSuccessState extends NoteState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class NoteEditErrorState extends NoteState {
  @override
  List<Object?> get props => throw UnimplementedError();
}




class NoteDeletingState extends NoteState {
  @override
  List<Object?> get props => [];
}

class NoteDeleteSuccessState extends NoteState {
  const NoteDeleteSuccessState();

  @override
  List<Object?> get props => [];
}

class NoteDeleteErrorState extends NoteState {
  const NoteDeleteErrorState();

  @override
  List<Object?> get props => [];
}


class NoteSearchingState extends NoteState {
  final String keyword;

  const NoteSearchingState({required this.keyword});

  @override
  List<Object?> get props => [keyword];
}

class NoteSearchedState extends NoteState {
  final List<Note> notes;

  const NoteSearchedState({required this.notes});

  @override
  List<Object?> get props => [notes];
}
