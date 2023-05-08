import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/settings/app_settings_cubit.dart';
import '../../models/enums/app_theme.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({Key? key, required this.onChange}) : super(key: key);
  final Function(bool) onChange;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, state) {
        return Switch(
          value: state.isLightTheme,
          onChanged: onChange,
        );
      },
    );
  }
}
