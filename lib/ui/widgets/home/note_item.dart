
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/blocs/app_cubit.dart';
import 'package:note_app/blocs/settings/app_settings_cubit.dart';
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
    bool isLightTheme = context.read<AppSettingsCubit>().isLightTheme;
    return Slidable(
      key: UniqueKey(),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            onDelete!();
          },
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
            // Refresh after push back
            Navigator.of(context)
                .pushNamed("/detail", arguments: NoteParams(id: note.id))
                .then((value) {
              context.read<AppCubit>().refreshNote();
            });
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: HexColor.fromHexString(note.color),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 45, top: 28, right: 45, bottom: 28),
              child: Wrap(
                children: [
                  Text(
                    note.title,
                    style: TextStyle(
                      color: isLightTheme ? Colors.white : Colors.black,
                      fontFamily: "Nunito",
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
