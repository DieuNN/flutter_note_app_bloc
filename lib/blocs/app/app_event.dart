part of 'app_bloc.dart';

@immutable
abstract class AppEvent {}

class AppInitialEvent extends AppEvent {}

class AppLoadNotesEvent extends AppEvent {}

class AppRefreshEvent extends AppEvent{}
