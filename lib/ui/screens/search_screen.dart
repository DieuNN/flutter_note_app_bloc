import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/common/extensions.dart';
import 'package:note_app/ui/widgets/note/note_item.dart';
import 'package:note_app/ui/widgets/search/no_result.dart';

import '../../blocs/note/note_bloc.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

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
          if (state is NoteSearchedState) {
            var notes = state.notes;
            if (notes.isEmpty || _textEditingController.text.trim().isEmpty) {
              return const Center(child: NoResultWidget());
            }
            return ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return NoteItemWidget(
                  note: state.notes[index],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  height: 16,
                );
              },
              itemCount: notes.length,
            );
          }
          return const Center(
            child: NoResultWidget(),
          );
        },
      ),
    );
  }

  Future<void> _onSearchResult(String keyword) async {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(seconds: 1), () {
      log("is my debounce active?  ${_debounce?.isActive}");
      context.read<NoteBloc>().add(NoteSearchEvent(keyword: keyword));
    });
  }

  Widget _buildSearchTextField(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        return TextField(
          controller: _textEditingController,
          onChanged: (value) async => _onSearchResult(value),
          style: TextStyle(
              color: HexColor.fromHexString("CCCCCC"),
              fontSize: 20,
              fontWeight: FontWeight.w200,
              fontFamily: "Nunito"),
          decoration: InputDecoration(
            hintStyle: TextStyle(
              color: HexColor.fromHexString("CCCCCC"),
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
            fillColor: HexColor.fromHexString("3B3B3B"),
            focusColor: HexColor.fromHexString("3B3B3B"),
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
