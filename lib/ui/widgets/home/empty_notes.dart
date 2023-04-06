import 'package:flutter/material.dart';

class EmptyNotesWidget extends StatelessWidget {
  const EmptyNotesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset("assets/empty.png"),
          const Text(
            "Create your first note !",
            style: TextStyle(
              fontFamily: "Nunito",
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w200,
            ),
          ),
        ],
      ),
    );
  }
}
