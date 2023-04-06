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

class NoteSaveEvent extends NoteEvent {
  final Note note;
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;

  const NoteSaveEvent({this.onSuccess, this.onFailure, required this.note});

  @override
  List<Object?> get props => [note, onSuccess, onFailure];
}

class NoteAddNewEvent extends NoteEvent {
  @override
  List<Object?> get props => [];

}

class NoteDeleteEvent extends NoteEvent {
  final int id;
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;

  const NoteDeleteEvent({this.onSuccess, this.onFailure, required this.id});

  @override
  List<Object?> get props => [id];
}

class NoteUpdateEvent extends NoteEvent {
  final int id;
  final Note note;
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;

  const NoteUpdateEvent({required this.note, required this.id, this.onSuccess, this.onFailure});

  @override
  List<Object?> get props => [id, onSuccess, onFailure];
}

class NoteSearchEvent extends NoteEvent {
  final String keyword;

  const NoteSearchEvent({required this.keyword});

  @override
  List<Object?> get props => [keyword];

}
