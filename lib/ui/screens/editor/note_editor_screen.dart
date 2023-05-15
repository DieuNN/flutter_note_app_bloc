import 'dart:convert';
import 'dart:developer';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:note_app/blocs/settings/app_settings_cubit.dart';
import 'package:note_app/common/extensions.dart';
import 'package:note_app/models/entity/note.dart';
import 'package:note_app/models/enums/editor_status.dart';
import 'package:note_app/models/params/note_params.dart';
import 'package:note_app/ui/screens/editor/editor_cubit.dart';
import 'package:note_app/ui/screens/note/note_cubit.dart';
import 'package:note_app/ui/widgets/editor/note_editor_app_bar.dart';

import '../../../models/enums/crud_status.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({Key? key}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late quill.QuillController quillController;
  final ScrollController scrollController = ScrollController();
  late TextEditingController titleEditController;
  NoteParams? noteParams;
  late Color editorBackground;

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
    context.read<EditorCubit>().disableEditor();
    if (noteParams?.isNewNote != true) {
      context.read<NoteCubit>().loadNote(noteId: noteParams!.id!);
    }
    editorBackground = context.read<AppSettingsCubit>().isLightTheme
        ? Colors.white
        : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return showConfirmDiscardDialog(
            context, noteParams?.id, noteParams?.isNewNote);
      },
      child: BlocConsumer<NoteCubit, NoteState>(
        listener: (context, state) {
          log("Editor state: ${state.crudStatus}");
          if (state.crudStatus == CrudStatus.success) {
            setState(() {
              editorBackground = HexColor.fromHexString(state.note?.color ?? "#FFFFFF");
              titleEditController.text = state.note?.title ?? "";
              quillController.document =
                  quill.Document.fromJson(jsonDecode(state.note!.content));
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
              context.read<EditorCubit>().activeEditor();
            },
            onSaveButtonClick: () {
              log("Save clicked");
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
              hideKeyboard();
              backToHomeScreen(context);
            },
            onViewButtonClick: () {
              context.read<EditorCubit>().disableEditor();
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.read<AppSettingsCubit>().isLightTheme
            ? Colors.white
            : Colors.black,
        title: Text(
          "Save changes?",
          style: TextStyle(
              color: context.read<AppSettingsCubit>().isLightTheme
                  ? Colors.black
                  : Colors.white,
              fontFamily: "Nunito"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (isNewNote ?? true) {
                saveNote(HexColor(editorBackground).toHexString());
              } else {
                updateNote(noteId);
              }
              hideKeyboard();
              Navigator.popUntil(context, ModalRoute.withName("/"));
            },
            child: Text(
              "Yes",
              style: TextStyle(
                color: context.read<AppSettingsCubit>().isLightTheme
                    ? Colors.black
                    : Colors.white,
                fontFamily: "Nunito",
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              hideKeyboard();
              Navigator.popUntil(context, ModalRoute.withName("/"));
            },
            child: Text(
              "Discard",
              style: TextStyle(
                color: context.read<AppSettingsCubit>().isLightTheme
                    ? Colors.black
                    : Colors.white,
                fontFamily: "Nunito",
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                color: context.read<AppSettingsCubit>().isLightTheme
                    ? Colors.black
                    : Colors.white,
                fontFamily: "Nunito",
              ),
            ),
          ),
        ],
      ),
    );
    return Future.value(false);
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
    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, state) {
        var isEditable = state.editorStatus == EditorStatus.active;
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
                TextStyle(
                    color: context.read<AppSettingsCubit>().isLightTheme
                        ? Colors.black
                        : Colors.white,
                    fontFamily: "Nunito",
                    fontSize: 23),
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
    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, state) {
        bool isEnabled = (state.editorStatus == EditorStatus.active);
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
          cursorColor: context.read<AppSettingsCubit>().isLightTheme
              ? Colors.black
              : Colors.white,
          style: TextStyle(
            color: context.read<AppSettingsCubit>().isLightTheme
                ? Colors.black
                : Colors.white,
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
    context.read<NoteCubit>().addNote(
          note: Note(
            id: null,
            title: titleEditController.text,
            content: jsonEncode(quillController.document.toDelta().toJson()),
            color: randomHexColor,
          ),
        );
  }

  void updateNote(int? id) {
    context.read<NoteCubit>().updateNote(
          newNote: Note(
            id: null,
            color:
                HexColor(editorBackground).toHexString(leadingHashSign: true),
            title: titleEditController.text,
            content: jsonEncode(quillController.document.toDelta().toJson()),
          ),
          id: id!,
        );
  }
}
