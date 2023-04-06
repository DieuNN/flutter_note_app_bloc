import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/blocs/note/note_bloc.dart';
import 'package:note_app/common/extensions.dart';
import 'package:note_app/ui/widgets/note/note_item.dart';
import 'package:note_app/ui/widgets/search/no_result.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key}) : super(key: key);
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildSearchTextField(context),
              const SizedBox(
                height: 16,
              ),
              _buildSearchResultListView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultListView() {
    return Expanded(
      child: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NoteSearchingState) {
            return const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  color: Colors.black,
                ),
              ),
            );
          }
          if (state is NoteSearchedState) {
            var notes = state.notes;
            if (notes.isEmpty || _textEditingController.text.isEmpty) {
              return const Expanded(child: NoResultWidget());
            }
            return ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return NoteItem(
                    title: notes[index].title,
                    hexColor: notes[index].color,
                    id: notes[index].id!);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  height: 16,
                );
              },
              itemCount: notes.length,
            );
          }

          return Container(
            child: Center(
              child: NoResultWidget(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchTextField(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        return TextField(
          controller: _textEditingController,
          onChanged: (value) {
            context.read<NoteBloc>().add(NoteSearchEvent(keyword: value));
          },
          style: TextStyle(
              color: HexColor.fromHex("CCCCCC"),
              fontSize: 20,
              fontWeight: FontWeight.w200,
              fontFamily: "Nunito"),
          decoration: InputDecoration(
            hintStyle: TextStyle(
              color: HexColor.fromHex("CCCCCC"),
              fontSize: 20,
              fontWeight: FontWeight.w200,
              fontFamily: "Nunito",
            ),
            suffixIcon: IconButton(
              onPressed: () {
                _textEditingController.clear();
              },
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
            hintText: "Search by the keyword...",
            filled: true,
            fillColor: HexColor.fromHex("3B3B3B"),
            focusColor: HexColor.fromHex("3B3B3B"),
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          ),
          cursorColor: Colors.white,
        );
      },
    );
  }
}
