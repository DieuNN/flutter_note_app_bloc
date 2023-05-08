part of 'editor_cubit.dart';

class EditorState extends Equatable {
  final EditorStatus editorStatus;

  const EditorState({this.editorStatus = EditorStatus.disabled});

  EditorState copyOf({EditorStatus? editorStatus}) =>
      EditorState(editorStatus: editorStatus ?? this.editorStatus);

  @override
  List<Object?> get props => [editorStatus];
}
