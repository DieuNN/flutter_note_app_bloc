import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/blocs/editor/editor_bloc.dart';
import 'package:note_app/common/app_constants.dart';
import 'package:note_app/common/extensions.dart';

class NoteEditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onViewButtonClick;
  final VoidCallback? onSaveButtonClick;
  final VoidCallback? onEditButtonClick;

  const NoteEditorAppBar(
      {Key? key,
      this.onViewButtonClick,
      this.onSaveButtonClick,
      this.onEditButtonClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        log("State ${state.runtimeType}");
        if (state is EditorActiveState) {
          return AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              _actionButton(onViewButtonClick!, Icons.remove_red_eye),
              const SizedBox(
                width: 20,
              ),
              _actionButton(onSaveButtonClick!, Icons.save),
              const SizedBox(
                width: 25,
              ),
            ],
          );
        }
        return AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            _actionButton(onEditButtonClick!, Icons.edit),
            const SizedBox(
              width: 20,
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget _actionButton(VoidCallback onItemClick, IconData icon) {
    return Wrap(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: HexColor.fromHex("3B3B3B")),
          child: IconButton(
            onPressed: onItemClick,
            icon: Icon(
              icon,
              color: Colors.white,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
