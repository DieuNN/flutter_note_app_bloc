import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit({this.isLightTheme = true})
      : super(AppSettingsState(isLightTheme: isLightTheme));
  bool isLightTheme = true;

  void switchTheme() {
    log("Switch");
    if (isLightTheme) {
      emit(state.copyWith(isLightTheme: false));

    } else {
      emit(state.copyWith(isLightTheme: true));
    }
    isLightTheme = !isLightTheme;
  }
}
