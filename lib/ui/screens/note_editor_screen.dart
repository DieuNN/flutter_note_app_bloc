import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:note_app/blocs/app/app_bloc.dart';
import 'package:note_app/blocs/editor/editor_bloc.dart';
import 'package:note_app/blocs/note/note_bloc.dart';
import 'package:note_app/common/extensions.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/models/params/note_params.dart';

import '../widgets/note/note_editor_app_bar.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({Key? key}) : super(key: key);

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final quill.QuillController _quillController = quill.QuillController.basic();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleEditController = TextEditingController();
  late quill.Document _document;
  late NoteParams? _noteParams;
  final FocusNode _focusNode = FocusNode();
  bool isViewOnly = true;

  @override
  void dispose() {
    _quillController.dispose();
    _titleEditController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _noteParams = (ModalRoute.of(context)?.settings.arguments as NoteParams?);
      _noteParams?.id == null
          ? () {
              context.read<NoteBloc>().add(NoteInitEvent());
            }()
          : () {
              context.read<NoteBloc>().add(NoteLoadEvent(id: _noteParams!.id!));
            }();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_titleEditController.text.isEmpty) {
          return Future.value(true);
        }
        Future<bool> shouldDiscard = _showConfirmDiscard(context);
        return shouldDiscard;
      },
      child: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NoteLoadingState) {
            log("State is $state");
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                backgroundColor: Colors.white,
              ),
            );
          }
          if (state is NewNoteState) {
            _editorScreen();
          }
          return _editorScreen();
        },
      ),
    );
  }

  Future<bool> _showConfirmDiscard(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "Save changes?",
          style: TextStyle(color: Colors.white, fontFamily: "Nunito"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _saveNote();
              BlocProvider.of<AppBloc>(context).add(AppLoadNotesEvent());
              _backToHomeScreen(context);
            },
            child: const Text(
              "Yes",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Nunito",
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _hideKeyboard();
              _backToHomeScreen(context);
            },
            child: const Text(
              "Discard",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Nunito",
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "No",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Nunito",
              ),
            ),
          ),
        ],
      ),
    );
    return Future.value(true);
  }

  Widget _editorScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBar(context),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NoteLoadedState) {
            _document = quill.Document.fromJson(jsonDecode(state.note.content));
            return SafeArea(
              child: Column(
                children: [
                  _titleInput(_titleEditController..text = state.note.title),
                  const SizedBox(
                    height: 8,
                  ),
                  _contentEditor(_document),
                  _editorToolBar(),
                ],
              ),
            );
          }
          if (state is NoteInitialState) {
            _document = quill.Document();
            return SafeArea(
              child: Column(
                children: [
                  _titleInput(_titleEditController),
                  const SizedBox(
                    height: 8,
                  ),
                  _contentEditor(_document),
                  _editorToolBar(),
                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
              color: Colors.black,
            ),
          );
        },
      ),
    );
  }

  void _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  NoteEvent _addNote() {
    String randomHexColor =
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
            .withOpacity(1.0)
            .toHex();
    return NoteSaveEvent(
      onSuccess: () {
        _backToHomeScreen(context);
      }(),
      note: Note(
        id: null,
        title: _titleEditController.text,
        content: jsonEncode(_quillController.document.toDelta().toJson()),
        color: randomHexColor,
      ),
    );
  }

  NoteEvent _updateNote(int id) {
    return NoteUpdateEvent(
      id: id,
      onSuccess: () {
        Navigator.pop(context);
      }(),
      note: Note(
        id: null,
        title: _titleEditController.text,
        content: jsonEncode(_quillController.document.toDelta().toJson()),
        color: "#FFFFFF",
      ),
    );
  }

  void _saveNote() {
    _titleEditController.text.isNotEmpty
        ? () {
            log(jsonEncode(_quillController.document.toDelta().toJson()));
            context.read<NoteBloc>().add(
                  _noteParams!.isNewNote!
                      ? _addNote()
                      : _updateNote(
                          _noteParams!.id!,
                        ),
                );
          }()
        : () {
            Fluttertoast.showToast(msg: "Title cannot be empty");
          }();
  }

  void _backToHomeScreen(context) {
    Navigator.popUntil(context, ModalRoute.withName("/"));
  }

  void _resetAndUpdateNoteState() {
    context.read<AppBloc>().add(AppLoadNotesEvent());
    context.read<NoteBloc>().add(NoteInitEvent());
  }

  NoteEditorAppBarWidget _appBar(BuildContext context) {
    return NoteEditorAppBarWidget(
      onViewButtonClick: () {
        context.read<EditorBloc>().add(DisableEditor());
      },
      onSaveButtonClick: () {
        _saveNote();
        _resetAndUpdateNoteState();
      },
      onEditButtonClick: () {
        context.read<EditorBloc>().add(ActiveEditor());
      },
    );
  }

  _contentEditor(quill.Document document) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        var isEditable = state is EditorActiveState;
        return Expanded(
          child: quill.QuillEditor(
            padding: const EdgeInsets.only(left: 8, right: 8),
            controller: _quillController..document = document,
            focusNode: FocusNode(),
            embedBuilders: FlutterQuillEmbeds.builders(),
            scrollController: _scrollController,
            scrollable: true,
            autoFocus: false,
            expands: true,
            showCursor: isEditable,
            readOnly: !isEditable,
            customStyles: quill.DefaultStyles(
              color: Colors.white,
              paragraph: quill.DefaultListBlockStyle(
                const TextStyle(
                    color: Colors.white, fontFamily: "Nunito", fontSize: 23),
                const quill.VerticalSpacing(6, 0),
                const quill.VerticalSpacing(8, 8),
                null,
                null,
              ),
            ),
            placeholder: "Enter your note here ...",
          ),
        );
      },
    );
  }

  _titleInput(TextEditingController controller) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        bool isEnabled = (state is EditorActiveState);
        return TextField(
          controller: controller,
          enabled: isEnabled,
          decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.only(left: 28, right: 28, bottom: 16),
              border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red)),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              disabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              focusedBorder: const UnderlineInputBorder(),
              hintText: "Title",
              hintStyle: TextStyle(color: HexColor.fromHex("9A9A9A"))),
          maxLines: null,
          keyboardType: TextInputType.multiline,
          cursorColor: Colors.white,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "Nunito",
            fontSize: 35,
          ),
          scrollPadding: const EdgeInsets.all(8),
        );
      },
    );
  }

  _editorToolBar() {
    return quill.QuillToolbar.basic(
      controller: _quillController,
      multiRowsDisplay: false,
      embedButtons: FlutterQuillEmbeds.buttons(),
    );
  }
}
