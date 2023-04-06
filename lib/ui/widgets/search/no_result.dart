import 'package:flutter/material.dart';

class NoResultWidget extends StatelessWidget {
  const NoResultWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          Image.asset("assets/no_result.png"),
          const Text(
            "Note not found. Try searching again.",
            style: TextStyle(
              fontFamily: "Nunito",
              fontWeight: FontWeight.w200,
              color: Colors.white,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
