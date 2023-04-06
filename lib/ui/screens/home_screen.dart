import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/blocs/app/app_bloc.dart';
import 'package:note_app/blocs/note/note_bloc.dart';
import 'package:note_app/common/extensions.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/models/params/note_params.dart';
import 'package:note_app/ui/widgets/home/empty_notes.dart';
import 'package:note_app/ui/widgets/home/home_app_bar.dart';
import 'package:note_app/ui/widgets/note/note_item.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key, required this.notes}) : super(key: key);
  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      appBar: HomeAppBarWidget(
        onSearchClick: () => navigateToSearch(context),
        onInfoClick: () => openInfoDialog(context),
      ),
      body: SafeArea(
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state is AppLoadingState) {
              return _emptyNotes();
            }
            if (state is AppReadyState) {
              return state.notes.isEmpty
                  ? _emptyNotes()
                  : _noteList(state.notes);
            }
            return _emptyNotes();
          },
        ),
      ),
      floatingActionButton: _addNoteButton(context),
    );
  }

  _addNoteButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _openNoteEditor(context);
      },
      child: const Icon(Icons.add),
    );
  }

  _openNoteEditor(context) {
    BlocProvider.of<NoteBloc>(context).add(NoteAddNewEvent());
    Navigator.of(context)
        .pushNamed("/detail", arguments: NoteParams(isNewNote: true));
  }

  _emptyNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Center(
          child: EmptyNotesWidget(),
        ),
      ],
    );
  }

  _noteList(List<Note> notes) {
    return ListView.separated(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
      itemBuilder: (BuildContext context, int index) {
        return notes
            .map((item) => NoteItemWidget(
                  note: item,
                  key: ValueKey(item.id),
                ))
            .toList()[index];
      },
      itemCount: notes.length,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: 16,
        );
      },
    );
  }

  void navigateToSearch(BuildContext context) {
    Navigator.of(context).pushNamed("/search");
  }

  void openInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HexColor.fromHex("252525"),
        content: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: HexColor.fromHex(
                      "CFCFCF",
                    ),
                    fontSize: 15,
                    height: 2,
                    fontFamily: "Nunito",
                  ),
                  children: const [
                    TextSpan(text: "Design by Dieu \n"),
                    TextSpan(text: "Redesign by Dieu \n"),
                    TextSpan(text: "Illustrations by Dieu \n"),
                    TextSpan(text: "Icons by Dieu \n"),
                    TextSpan(text: "Font by Dieu \n"),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Center(
                child: Text(
                  "Made by Dieu",
                  style: TextStyle(
                      color: HexColor.fromHex(
                        "CFCFCF",
                      ),
                      fontSize: 15,
                      height: 2,
                      fontFamily: "Nunito"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
