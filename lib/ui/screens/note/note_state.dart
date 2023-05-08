part of 'note_cubit.dart';

class NoteState extends Equatable {
  final Note? note;
  final CrudStatus crudStatus;
  final String? errorMessage;

  const NoteState(
      {this.note, this.crudStatus = CrudStatus.initial, this.errorMessage});

  NoteState copyWith({
    Note? note,
    CrudStatus? curdStatus,
    String? errorMessage,
  }) =>
      NoteState(
          note: note ?? this.note,
          crudStatus: curdStatus ?? crudStatus,
          errorMessage: errorMessage ?? this.errorMessage);

  @override
  List<Object?> get props => [note, crudStatus, errorMessage];
}
