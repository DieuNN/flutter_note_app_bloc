part of 'app_bloc.dart';

@immutable
abstract class AppState {}

class AppInitialState extends AppState {}

class AppLoadingState extends AppState {}

class AppLoadSuccessState extends AppState {
  final List<Note> notes;

  AppLoadSuccessState({required this.notes});
}

class AppRefreshingState extends AppState {}

class AppLoadErrorState extends AppState {}
