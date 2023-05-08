import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/blocs/app_cubit.dart';
import 'package:note_app/blocs/settings/app_settings_cubit.dart';
import 'package:note_app/common/app_constants.dart';
import 'package:note_app/common/extensions.dart';
import 'package:note_app/main.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/models/enums/app_theme.dart';
import 'package:note_app/models/enums/crud_status.dart';
import 'package:note_app/models/enums/load_status.dart';
import 'package:note_app/models/params/note_params.dart';
import 'package:note_app/ui/screens/note/note_cubit.dart';
import 'package:note_app/ui/widgets/home/empty_notes.dart';
import 'package:note_app/ui/widgets/home/home_app_bar.dart';
import 'package:note_app/ui/widgets/home/note_item.dart';
import 'package:note_app/ui/widgets/theme_switcher.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key, required this.notes}) : super(key: key);
  final List<Note> notes;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> notes = [];
  List<String> databases = [
    "Sqlite",
    "Shared Preference",
    "Hive",
    "Secure Storage"
  ];
  late String currentDatabase;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    context.read<AppCubit>().refreshNote();
    currentDatabase = await getDatabaseName();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listener: (context, state) {
        if (state.loadStatus == LoadStatus.success) {
          setState(() {
            notes = state.notes ?? [];
          });
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: context.read<AppSettingsCubit>().isLightTheme ? Colors.white : Colors.black,
        appBar: HomeAppBarWidget(
          onSearchClick: () => _navigateToSearch(context),
          onInfoClick: () => _openInfoDialog(context),
        ),
        body: SafeArea(
          child: notes.isEmpty
              ? _buildEmptyNotesWidget()
              : RefreshIndicator(
                  child: _buildNoteList(notes),
                  onRefresh: () async {
                    context.read<AppCubit>().refreshNote();
                  },
                ),
        ),
        floatingActionButton: _buildAddNoteButton(context),
      ),
    );
  }

  _buildAddNoteButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        context.read<NoteCubit>().initialNote();
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
        context.read<AppCubit>().refreshNote();
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
    return ListView.separated(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
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
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).pushNamed("/search").then((value) {
      context.read<AppCubit>().refreshNote();
    });
  }

  void _openInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.read<AppSettingsCubit>().isLightTheme ? Colors.white : Colors.black,
        content: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Light theme: ", style: TextStyle(color: context.read<AppSettingsCubit>().isLightTheme ? Colors.black : Colors.white),),
                  ThemeSwitcher(
                    onChange: (_) {
                      context.read<AppSettingsCubit>().switchTheme();
                    },
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: context.read<AppSettingsCubit>().isLightTheme ? Colors.black : Colors.white,
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
                      color: context.read<AppSettingsCubit>().isLightTheme ? Colors.black : Colors.white,
                      fontSize: 15,
                      height: 2,
                      fontFamily: "Nunito"),
                ),
              ),
              Center(
                child: _buildDatabasePicker(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> changeDbAndRestartApp(String name) async {
    await setDatabaseName(name);
    exit(0);
  }

  Widget _buildDatabasePicker() {
    return DropdownButton(
      value: currentDatabase,
      items: databases
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: TextStyle(
                    color: context.read<AppSettingsCubit>().isLightTheme ? Colors.black : Colors.white),
              ),
            ),
          )
          .toList(),
      onChanged: (value) async {
        await changeDbAndRestartApp(value!);
      },
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
                    .read<NoteCubit>()
                    .addNote(note: note);
                scaffoldKey.currentContext!.read<AppCubit>().refreshNote();
                ScaffoldMessenger.of(scaffoldKey.currentContext!)
                    .removeCurrentSnackBar();
              },
              child: Text(
                "Undo",
                style: TextStyle(
                    color: context.read<AppSettingsCubit>().isLightTheme ? Colors.black : Colors.white,
                    fontFamily: AppConstants.defaultFont),
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
    context.read<NoteCubit>().deleteNote(noteId: id);
    context.read<AppCubit>().refreshNote();
  }
}
