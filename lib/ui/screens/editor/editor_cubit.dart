import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:note_app/models/enums/editor_status.dart';

part 'editor_state.dart';

class EditorCubit extends Cubit<EditorState> {
  EditorCubit() : super(const EditorState());

  void disableEditor() {
    emit(state.copyOf(editorStatus: EditorStatus.disabled));
  }

  void activeEditor() {
    emit(state.copyOf(editorStatus: EditorStatus.active));
  }
}
