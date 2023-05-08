part of 'app_settings_cubit.dart';

class AppSettingsState extends Equatable {
  final bool isLightTheme;

  const AppSettingsState({required this.isLightTheme});

  AppSettingsState copyWith({required bool isLightTheme}) {
    return AppSettingsState(isLightTheme: isLightTheme);
  }

  @override
  List<Object?> get props => [isLightTheme];
}
