part of 'app_bloc.dart';

@immutable
abstract class AppState {}

class AppInitialState extends AppState {}

class AppLoadingState extends AppState {}

class AppReadyState extends AppState {
  final List<Note> notes;

  AppReadyState({required this.notes});
}
