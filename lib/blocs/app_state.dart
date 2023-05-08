part of 'app_cubit.dart';

class AppState extends Equatable {
  final LoadStatus loadStatus;
  final List<Note>? notes;
  final String? errorMessage;

  const AppState(
      {this.loadStatus = LoadStatus.initial, this.notes, this.errorMessage});

  AppState copyWith({LoadStatus? loadStatus, List<Note>? notes, String? errorMessage}) => AppState(
        loadStatus: loadStatus ?? this.loadStatus,
        notes: notes ?? this.notes,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [loadStatus, notes];
}
