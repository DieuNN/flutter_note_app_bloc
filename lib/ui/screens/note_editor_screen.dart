import 'dart:convert';
import 'dart:developer';

import 'package:flex_color_picker/flex_color_picker.dart';
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
  quill.QuillController? _quillController;
  final ScrollController _scrollController = ScrollController();
  TextEditingController? _titleEditController;
  Color _editorBackground = Colors.white;

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<NoteBloc>().add(NoteInitEvent());
        NoteParams? noteParams =
            ModalRoute.of(context)!.settings.arguments as NoteParams;
        context.read<AppBloc>().add(AppRefreshEvent());
        return _showConfirmDiscard(
            context, noteParams.id, noteParams.isNewNote);
      },
      child: BlocListener<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteAddSuccessState || state is NoteEditSuccessState) {
            _hideKeyboard();
            _backToHomeScreen(context);
          }
        },
        child: Scaffold(
          backgroundColor: _editorBackground,
          appBar: NoteEditorAppBarWidget(
            onOpenColorPickerDialogClick: () {
              _showColorPickerDialog();
            },
            onEditButtonClick: () {
              context.read<EditorBloc>().add(ActiveEditor());
            },
            onSaveButtonClick: () {
              bool? isNewNote =
                  (ModalRoute.of(context)!.settings.arguments as NoteParams)
                      .isNewNote!;

              int? id =
                  (ModalRoute.of(context)!.settings.arguments as NoteParams).id;

              if (_titleEditController!.text.trim().isEmpty) {
                Fluttertoast.showToast(msg: "Title cannot be empty!");
                return;
              }

              if (isNewNote) {
                _saveNote(HexColor(_editorBackground).toHexString());
              } else {
                _updateNote(id, HexColor(_editorBackground).toHexString());
              }
            },
            onViewButtonClick: () {
              context.read<EditorBloc>().add(DisableEditor());
            },
            backgroundColor: _editorBackground,
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
                    Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                    ),
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

  Future<bool> _showColorPickerDialog() async {
    return ColorPicker(
      color: _editorBackground,
      onColorChanged: (Color color) =>
          setState(() => _editorBackground = color),
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      // Showing color code prefix and text styled differently in the dialog.
      colorCodeTextStyle: Theme.of(context).textTheme.bodyMedium,
      colorCodePrefixStyle: Theme.of(context).textTheme.bodySmall,
      // Showing the new thumb color property option in dialog version
      selectedPickerTypeColor: Theme.of(context).colorScheme.primary,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }

  Future<bool> _showConfirmDiscard(context, int? noteId, bool? isNewNote) {
    Future<bool>? result;
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
              if (isNewNote ?? true) {
                _saveNote(HexColor.randomHexColor());
              } else {
                _updateNote(noteId, HexColor.randomHexColor());
              }
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
              result = Future.value(true);
              _hideKeyboard();
              Navigator.popUntil(context, ModalRoute.withName("/"));
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
              result = Future.value(false);
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Nunito",
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? Future.value(false);
  }

  Widget _buildEditorScreen(quill.QuillController quillController,
      TextEditingController titleController) {
    return Column(
      children: [
        _buildTitleInput(titleController),
        const SizedBox(
          height: 8,
        ),
        _buildContentEditor(quillController),
        _buildEditorToolBar(quillController),
      ],
    );
  }

  void _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _backToHomeScreen(context) {
    Navigator.popUntil(context, ModalRoute.withName("/"));
  }

  _buildContentEditor(quill.QuillController controller) {
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
              color: _editorBackground,
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

  _buildTitleInput(TextEditingController controller) {
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
              hintStyle: TextStyle(color: HexColor.fromHexString("9A9A9A"))),
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

  _buildEditorToolBar(quill.QuillController controller) {
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
