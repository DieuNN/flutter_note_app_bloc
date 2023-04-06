part of 'note_bloc.dart';

abstract class NoteState extends Equatable {
  const NoteState();
}

class NoteInitialState extends NoteState {
  @override
  List<Object?> get props => [];
}

class NewNoteState extends NoteState {
  @override
  List<Object?> get props => [];
}

class NoteLoadingState extends NoteState {
  final int id;

  const NoteLoadingState({required this.id});

  @override
  List<Object?> get props => [];
}

class NoteLoadedState extends NoteState {
  final Note note;

  const NoteLoadedState({required this.note});

  @override
  List<Object?> get props => [];
}

class NoteSavingState extends NoteState {
  @override
  List<Object?> get props => [];
}

class NoteSavedState extends NoteState {
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;

  const NoteSavedState({this.onSuccess, this.onFailure});

  @override
  List<Object?> get props => [];
}

class NoteEditingState extends NoteState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class NoteDeletingState extends NoteState {
  @override
  List<Object?> get props => [];
}

class NoteDeletedState extends NoteState {
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;

  const NoteDeletedState({this.onSuccess, this.onFailure});

  @override
  List<Object?> get props => [onSuccess, onFailure];
}

class NoteUpdatingState extends NoteState {
  @override
  List<Object?> get props => [];
}

class NoteUpdatedState extends NoteState {
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;

  const NoteUpdatedState({this.onSuccess, this.onFailure});

  @override
  List<Object?> get props => [onSuccess, onFailure];
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
