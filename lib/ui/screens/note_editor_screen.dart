import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  quill.QuillController? _quillController;
  final ScrollController _scrollController = ScrollController();
  TextEditingController? _titleEditController;

  @override
  void dispose() {
    _titleEditController!.dispose();
    _scrollController.dispose();
    _quillController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
              // _saveNote();
              // _backToHomeScreen(context);
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
              // _hideKeyboard();
              // _backToHomeScreen(context);
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
              Navigator.popUntil(context, ModalRoute.withName("/"));
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

  Widget _buildEditorScreen(quill.QuillController quillController,
      TextEditingController titleController) {
    return Column(
      children: [
        _titleInput(titleController),
        const SizedBox(
          height: 8,
        ),
        _contentEditor(quillController),
        _editorToolBar(quillController),
      ],
    );
  }

  void _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _backToHomeScreen(context) {
    Navigator.popUntil(context, ModalRoute.withName("/"));
  }

  _contentEditor(quill.QuillController controller) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        var isEditable = state is EditorActiveState;
        return Expanded(
          child: quill.QuillEditor(
            padding: const EdgeInsets.only(left: 8, right: 8),
            controller: (controller),
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

  _editorToolBar(quill.QuillController controller) {
    return quill.QuillToolbar.basic(
      controller: controller,
      multiRowsDisplay: false,
      embedButtons: FlutterQuillEmbeds.buttons(),
    );
  }

  void _saveNote(String randomHexColor) {
    context.read<NoteBloc>().add(
          NoteAddEvent(
            note: Note(
              id: null,
              title: _titleEditController!.text,
              content:
                  jsonEncode(_quillController!.document.toDelta().toJson()),
              color: randomHexColor,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<NoteBloc>().add(NoteInitEvent());
        return _showConfirmDiscard(context);
      },
      child: BlocListener<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteAddSuccessState || state is NoteEditSuccessState) {
            _hideKeyboard();
            _backToHomeScreen(context);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: NoteEditorAppBarWidget(
            onEditButtonClick: () {
              context.read<EditorBloc>().add(ActiveEditor());
            },
            onSaveButtonClick: () {
              bool? isNewNote =
                  (ModalRoute.of(context)!.settings.arguments as NoteParams)
                      .isNewNote!;
              String randomHexColor =
                  Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                      .withOpacity(1.0)
                      .toHex();
              int? id =
                  (ModalRoute.of(context)!.settings.arguments as NoteParams).id;

              if (_titleEditController!.text.trim().isEmpty) {
                Fluttertoast.showToast(msg: "Title cannot be empty!");
                return;
              }

              if (isNewNote) {
                _saveNote(randomHexColor);
              } else {
                _updateNote(id, randomHexColor);
              }
            },
            onViewButtonClick: () {
              context.read<EditorBloc>().add(DisableEditor());
            },
          ),
          body: BlocConsumer<NoteBloc, NoteState>(
            builder: (context, state) {
              log("Current note state is: ${state.runtimeType}");
              if (state is NoteAddingState) {
                _quillController = quill.QuillController.basic();
                _titleEditController = TextEditingController();
                return _buildEditorScreen(
                    _quillController!, _titleEditController!);
              }
              if (state is NoteLoadingState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(
                      color: Colors.black,
                      backgroundColor: Colors.white,
                    )
                  ],
                );
              }
              if (state is NoteLoadSuccessState) {
                _quillController = quill.QuillController(
                    document:
                        quill.Document.fromJson(jsonDecode(state.note.content)),
                    selection: const TextSelection.collapsed(offset: 0));
                _titleEditController =
                    TextEditingController(text: state.note.title);
                return _buildEditorScreen(
                  _quillController!,
                  _titleEditController!,
                );
              }

              if (_titleEditController == null || _quillController == null) {
                _quillController = quill.QuillController.basic();
                _titleEditController = TextEditingController();
              }
              return _buildEditorScreen(
                  _quillController!, _titleEditController!);
            },
            listener: (context, state) {},
          ),
        ),
      ),
    );
  }

  void _updateNote(int? id, String randomHexColor) {
    context.read<NoteBloc>().add(
          NoteEditEvent(
            note: Note(
              id: null,
              color: randomHexColor,
              title: _titleEditController!.text,
              content:
                  jsonEncode(_quillController!.document.toDelta().toJson()),
            ),
            id: id!,
          ),
        );
  }
}
