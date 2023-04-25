import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/blocs/app/app_bloc.dart';
import 'package:note_app/blocs/note/note_bloc.dart';
import 'package:note_app/common/app_constants.dart';
import 'package:note_app/common/extensions.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/models/params/note_params.dart';
import 'package:note_app/ui/widgets/home/empty_notes.dart';
import 'package:note_app/ui/widgets/home/home_app_bar.dart';
import 'package:note_app/ui/widgets/note/note_item.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.notes}) : super(key: key);
  final List<Note> notes;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    context.read<AppBloc>().add(AppLoadNotesEvent());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      appBar: HomeAppBarWidget(
        onSearchClick: () => _navigateToSearch(context),
        onInfoClick: () => _openInfoDialog(context),
      ),
      body: SafeArea(
        child: BlocListener<AppBloc, AppState>(
          listener: (context, state) {
            if (state is AppLoadSuccessState) {
              setState(() {
                notes = state.notes;
              });
            }
          },
          child: notes.isEmpty
              ? _buildEmptyNotesWidget()
              : RefreshIndicator(
                  child: _buildNoteList(notes),
                  onRefresh: () async {
                    context.read<AppBloc>().add(AppRefreshEvent());
                  },
                ),
        ),
      ),
      floatingActionButton: _buildAddNoteButton(context),
    );
  }

  _buildAddNoteButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        context.read<NoteBloc>().add(NoteInitEvent());
        _openNoteEditor(context);
      },
      child: const Icon(Icons.add),
    );
  }

  _openNoteEditor(BuildContext context) {
    Navigator.of(context)
        .pushNamed("/detail", arguments: NoteParams(isNewNote: true))
        .then(
      (value) {
        context.read<AppBloc>().add(AppRefreshEvent());
      },
    );
  }

  _buildEmptyNotesWidget() {
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

  _buildNoteList(List<Note> notes) {
    return BlocListener<NoteBloc, NoteState>(
      listener: (context, state) {},
      listenWhen: (previous, current) {
        if (previous is NoteDeletingState &&
            current is NoteDeleteSuccessState) {
          context.read<AppBloc>().add(AppRefreshEvent());
          return true;
        }
        if (previous is NoteAddingState && current is NoteAddSuccessState) {
          context.read<AppBloc>().add(AppRefreshEvent());
        }
        if (previous is NoteEditingState && current is NoteEditSuccessState) {
          context.read<AppBloc>().add(AppRefreshEvent());
        }
        return false;
      },
      child: ListView.separated(
        padding:
            const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
        itemBuilder: (BuildContext context, int index) {
          return notes
              .map(
                (item) => NoteItemWidget(
                  note: item,
                  key: ValueKey(item.id),
                  onDelete: () {
                    _deleteNote(item.id!);
                    _showDeletingSnackBar();
                    _showUndoDeleteSnackBar(item);
                  },
                ),
              )
              .toList()[index];
        },
        itemCount: notes.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            height: 16,
          );
        },
      ),
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).pushNamed("/search").then((value) {
      context.read<AppBloc>().add(AppRefreshEvent());
    });
  }

  void _openInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HexColor.fromHexString("252525"),
        content: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: HexColor.fromHexString(
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
                      color: HexColor.fromHexString(
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

  void _showUndoDeleteSnackBar(Note note) {
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

  void _showDeletingSnackBar() {
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Note deleting ...",
            ),
          ],
        ),
      ),
    );
  }

  void _deleteNote(int id) {
    context.read<NoteBloc>().add(NoteDeleteEvent(id: id));
  }
}
