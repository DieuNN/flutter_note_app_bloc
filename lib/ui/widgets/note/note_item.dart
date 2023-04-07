import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/blocs/app/app_bloc.dart';
import 'package:note_app/blocs/note/note_bloc.dart';
import 'package:note_app/common/app_constants.dart';
import 'package:note_app/common/extensions.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/models/params/note_params.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:note_app/ui/screens/home_screen.dart';

class NoteItemWidget extends StatelessWidget {
  final Note note;
  final VoidCallback? onDelete;
  final VoidCallback? onUndo;

  const NoteItemWidget(
      {Key? key, required this.note, this.onDelete, this.onUndo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: UniqueKey(),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            _deleteNote(context);
          },
        ),
        children: [
          SlidableAction(
            onPressed: (context) {
              _deleteNote(context);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            borderRadius: BorderRadius.circular(10),
            label: 'Delete',
          ),
        ],
      ),
      child: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          return SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: GestureDetector(
              onTap: () {
                log("Note item param id is: ${note.id}");
                Navigator.of(context)
                    .pushNamed(
                  "/detail",
                  arguments: NoteParams(id: note.id),
                )
                    .then(
                      (value) {
                    context.read<AppBloc>().add(AppRefreshEvent());
                  },
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: HexColor.fromHex(note.color),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 45, top: 28, right: 45, bottom: 28),
                  child: Wrap(
                    children: [
                      Text(
                        note.title,
                        style: const TextStyle(
                            color: Colors.black,
                            fontFamily: "Nunito",
                            fontSize: 25),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteNote(BuildContext context) {
    context.read<NoteBloc>().add(NoteDeleteEvent(id: note.id!));
    context.read<AppBloc>().add(AppRefreshEvent());
    context.read<AppBloc>().add(AppRefreshEvent());
    context.read<AppBloc>().add(AppRefreshEvent());
    _showUndoDeleteSnackBar(context);
  }

  void _showUndoDeleteSnackBar(context) {
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Note deleted",
            ),
            TextButton(
              onPressed: () {
                // When widget is dismissed (removed from widget tree), context will be removed too
                // So we must use parent's context
                scaffoldKey.currentContext!
                    .read<NoteBloc>()
                    .add(NoteAddEvent(note: note));
                scaffoldKey.currentContext!
                    .read<AppBloc>()
                    .add(AppRefreshEvent());
                scaffoldKey.currentContext!
                    .read<AppBloc>()
                    .add(AppRefreshEvent());
                scaffoldKey.currentContext!
                    .read<AppBloc>()
                    .add(AppRefreshEvent());
                ScaffoldMessenger.of(scaffoldKey.currentContext!)
                    .removeCurrentSnackBar();
              },
              child: const Text(
                "Undo",
                style: TextStyle(
                    color: Colors.white, fontFamily: AppConstants.defaultFont),
              ),
            )
          ],
        ),
      ),
    );
  }
}
