part of 'editor_bloc.dart';

@immutable
abstract class EditorEvent {}

class InitialEditor extends EditorEvent {}

class ActiveEditor extends EditorEvent {}

class DisableEditor extends EditorEvent {}
