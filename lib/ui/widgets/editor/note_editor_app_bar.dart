import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/common/extensions.dart';
import 'package:note_app/models/enums/editor_status.dart';
import 'package:note_app/ui/screens/editor/editor_cubit.dart';

class NoteEditorAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onViewButtonClick;
  final VoidCallback? onSaveButtonClick;
  final VoidCallback? onEditButtonClick;
  final VoidCallback? onOpenColorPickerDialogClick;
  final Color backgroundColor;

  const NoteEditorAppBarWidget({
    Key? key,
    this.onViewButtonClick,
    this.onSaveButtonClick,
    this.onEditButtonClick,
    this.onOpenColorPickerDialogClick,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, state) {
        log("Appbar state: ${state.editorStatus}");
        if (state.editorStatus == EditorStatus.active) {
          return AppBar(
            backgroundColor: backgroundColor,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              _buildActionButton(onOpenColorPickerDialogClick!, Icons.colorize),
              const SizedBox(
                width: 25,
              ),
              _buildActionButton(onViewButtonClick!, Icons.remove_red_eye),
              const SizedBox(
                width: 20,
              ),
              _buildActionButton(onSaveButtonClick!, Icons.save),
              const SizedBox(
                width: 25,
              ),
            ],
          );
        }
        return AppBar(
          backgroundColor: backgroundColor,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            _buildActionButton(onEditButtonClick!, Icons.edit),
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

  Widget _buildActionButton(VoidCallback onItemClick, IconData icon) {
    return Wrap(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: HexColor.fromHexString("3B3B3B")),
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
