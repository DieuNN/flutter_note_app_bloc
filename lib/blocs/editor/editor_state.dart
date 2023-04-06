part of 'editor_bloc.dart';

@immutable
abstract class EditorState {}

class EditorInitial extends EditorState {}

class EditorDisabledState extends EditorState {}

class EditorActiveState extends EditorState {}
