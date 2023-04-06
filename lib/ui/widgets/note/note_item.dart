import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/blocs/app/app_bloc.dart';
import 'package:note_app/blocs/note/note_bloc.dart';
import 'package:note_app/common/extensions.dart';
import 'package:note_app/models/params/note_params.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NoteItemWidget extends StatelessWidget {
  final String title;
  final String hexColor;
  final int id;

  const NoteItemWidget(
      {Key? key, required this.title, required this.hexColor, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: UniqueKey(),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {
          context.read<NoteBloc>().add(NoteDeleteEvent(id: id));
          context.read<AppBloc>().add(AppLoadNotesEvent());
        },),
        children: [
          SlidableAction(
            onPressed: (context) {
              context.read<NoteBloc>().add(NoteDeleteEvent(id: id));
              context.read<AppBloc>().add(AppLoadNotesEvent());
            },
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
            Navigator.of(context).pushNamed(
              "/detail",
              arguments: NoteParams(id: id),
            );
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: HexColor.fromHex(hexColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 45, top: 28, right: 45, bottom: 28),
              child: Wrap(
                children: [
                  Text(
                    title,
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
