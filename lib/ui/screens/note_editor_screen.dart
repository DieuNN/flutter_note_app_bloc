import 'dart:convert';
import 'dart:developer';

import 'package:flex_color_picker/flex_color_picker.dart';
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
  late quill.QuillController quillController;
  final ScrollController scrollController = ScrollController();
  late TextEditingController titleEditController;
  NoteParams? noteParams;
  Color editorBackground = Colors.black;

  @override
  void dispose() {
    titleEditController.dispose();
    scrollController.dispose();
    quillController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    titleEditController = TextEditingController();
    quillController = quill.QuillController.basic();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    noteParams = ModalRoute.of(context)!.settings.arguments as NoteParams;
    context.read<EditorBloc>().add(DisableEditor());
    if (noteParams?.isNewNote != true) {
      context.read<NoteBloc>().add(NoteLoadEvent(id: noteParams!.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return showConfirmDiscardDialog(
            context, noteParams?.id, noteParams?.isNewNote);
      },
      child: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteAddSuccessState || state is NoteEditSuccessState) {
            hideKeyboard();
            backToHomeScreen(context);
          }
          if (state is NoteLoadSuccessState) {
            setState(() {
              editorBackground = HexColor.fromHexString(state.note.color);
              titleEditController.text = state.note.title;
              quillController.document =
                  quill.Document.fromJson(jsonDecode(state.note.content));
            });
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: editorBackground,
          appBar: NoteEditorAppBarWidget(
            onOpenColorPickerDialogClick: () {
              showColorPickerDialog();
            },
            onEditButtonClick: () {
              context.read<EditorBloc>().add(ActiveEditor());
            },
            onSaveButtonClick: () {
              bool? isNewNote = noteParams?.isNewNote;
              int? id =
                  (ModalRoute.of(context)!.settings.arguments as NoteParams).id;

              if (titleEditController.text.trim().isEmpty) {
                Fluttertoast.showToast(msg: "Title cannot be empty!");
                return;
              }

              if (isNewNote ?? false) {
                saveNote(HexColor(editorBackground).toHexString());
              } else {
                updateNote(id);
              }
            },
            onViewButtonClick: () {
              context.read<EditorBloc>().add(DisableEditor());
            },
            backgroundColor: editorBackground,
          ),
          body: buildEditorScreen(quillController, titleEditController),
        ),
      ),
    );
  }

  Future<bool> showColorPickerDialog() async {
    return ColorPicker(
      color: editorBackground,
      onColorChanged: (Color color) => setState(() {
        editorBackground = color;
      }),
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

  Future<bool> showConfirmDiscardDialog(context, int? noteId, bool? isNewNote) {
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
                saveNote(HexColor(editorBackground).toHexString());
              } else {
                updateNote(noteId);
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
              hideKeyboard();
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

  Widget buildEditorScreen(quill.QuillController quillController,
      TextEditingController titleController) {
    return Column(
      children: [
        buildTitleInput(titleController),
        const SizedBox(
          height: 8,
        ),
        buildContentEditor(quillController),
        buildEditorToolBar(quillController),
      ],
    );
  }

  void hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void backToHomeScreen(context) {
    Navigator.popUntil(context, ModalRoute.withName("/"));
  }

  buildContentEditor(quill.QuillController controller) {
    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        var isEditable = state is EditorActiveState;
        return Expanded(
          child: quill.QuillEditor(
            padding: const EdgeInsets.only(left: 8, right: 8),
            controller: (controller),
            focusNode: FocusNode(),
            embedBuilders: FlutterQuillEmbeds.builders(),
            scrollController: scrollController,
            scrollable: true,
            autoFocus: false,
            expands: true,
            showCursor: isEditable,
            readOnly: !isEditable,
            customStyles: quill.DefaultStyles(
              color: editorBackground,
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

  buildTitleInput(TextEditingController controller) {
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

  buildEditorToolBar(quill.QuillController controller) {
    return quill.QuillToolbar.basic(
      controller: controller,
      multiRowsDisplay: false,
      embedButtons: FlutterQuillEmbeds.buttons(),
    );
  }

  void saveNote(String randomHexColor) {
    context.read<NoteBloc>().add(
          NoteAddEvent(
            note: Note(
              id: null,
              title: titleEditController.text,
              content: jsonEncode(quillController.document.toDelta().toJson()),
              color: randomHexColor,
            ),
          ),
        );
  }

  int count = 0;

  void updateNote(int? id) {
    log("In EditorScreen, color is: ${HexColor(editorBackground).toHexString()}");
    count++;
    log("Updated time: $count");
    context.read<NoteBloc>().add(
          NoteEditEvent(
            note: Note(
              id: null,
              color:
                  HexColor(editorBackground).toHexString(leadingHashSign: true),
              title: titleEditController.text,
              content: jsonEncode(quillController.document.toDelta().toJson()),
            ),
            id: id!,
          ),
        );
  }
}
