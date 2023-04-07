part of 'note_bloc.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();
}

class NoteInitEvent extends NoteEvent {
  @override
  List<Object?> get props => [];
}

class NoteLoadEvent extends NoteEvent {
  final int id;

  const NoteLoadEvent({required this.id});

  @override
  List<Object?> get props => [];
}

class NoteAddEvent extends NoteEvent {
  final Note note;

  const NoteAddEvent({required this.note});

  @override
  List<Object?> get props => [];
}

class NoteDeleteEvent extends NoteEvent {
  final int id;

  const NoteDeleteEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class NoteEditEvent extends NoteEvent {
  final int id;
  final Note note;

  const NoteEditEvent({required this.note, required this.id});

  @override
  List<Object?> get props => [id, note];
}

class NoteSearchEvent extends NoteEvent {
  final String keyword;

  const NoteSearchEvent({required this.keyword});

  @override
  List<Object?> get props => [keyword];
}
