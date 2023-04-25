part of 'note_bloc.dart';

abstract class NoteState {
  const NoteState();
}

class NoteInitialState extends NoteState {

}

class NoteLoadingState extends NoteState {
}

class NoteLoadSuccessState extends NoteState {
  final Note note;

  const NoteLoadSuccessState({required this.note});
}

class NoteLoadErrorState extends NoteState {

  const NoteLoadErrorState();
}

class NoteAddingState extends NoteState {

}

class NoteAddSuccessState extends NoteState {
}

class NoteAddErrorState extends NoteState {

}

class NoteEditingState extends NoteState {

}

class NoteEditSuccessState extends NoteState {

}

class NoteEditErrorState extends NoteState {

}

class NoteDeletingState extends NoteState {

}

class NoteDeleteSuccessState extends NoteState {
  const NoteDeleteSuccessState();

}

class NoteDeleteErrorState extends NoteState {
  const NoteDeleteErrorState();

}

class NoteSearchingState extends NoteState {
  final String keyword;

  const NoteSearchingState({required this.keyword});
}

class NoteSearchedState extends NoteState {
  final List<Note> notes;

  const NoteSearchedState({required this.notes});

}
