import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/blocs/app/app_bloc.dart';
import 'package:note_app/blocs/note/note_bloc.dart';
import 'package:note_app/common/extensions.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/models/params/note_params.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
          onDismissed: () => onDelete!(),
        ),
        children: [
          SlidableAction(
            onPressed: (context) => onDelete!(),
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            borderRadius: BorderRadius.circular(10),
            label: 'Delete',
          ),
        ],
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
          onTap: () {
            log("passing note item id: ${note.id}");
            context.read<NoteBloc>().add(NoteLoadEvent(id: note.id!));
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
      ),
    );
  }
}
