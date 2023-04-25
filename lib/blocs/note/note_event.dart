part of 'note_bloc.dart';

abstract class NoteEvent {}

class NoteInitEvent extends NoteEvent {
}

class NoteLoadEvent extends NoteEvent {
  final int id;

   NoteLoadEvent({required this.id});

}

class NoteAddEvent extends NoteEvent {
  final Note note;

   NoteAddEvent({required this.note});

}

class NoteDeleteEvent extends NoteEvent {
  final int id;

   NoteDeleteEvent({required this.id});


}

class NoteEditEvent extends NoteEvent {
  final int id;
  final Note note;

   NoteEditEvent({required this.note, required this.id});

}

class NoteSearchEvent extends NoteEvent {
  final String keyword;

   NoteSearchEvent({required this.keyword});


}
