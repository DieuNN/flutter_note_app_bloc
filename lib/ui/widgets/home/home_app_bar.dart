


import 'package:flutter/material.dart';
import 'package:note_app/common/app_constants.dart';
import 'package:note_app/common/extensions.dart';

class HomeAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchClick;
  final VoidCallback onInfoClick;

  const HomeAppBarWidget(
      {Key? key, required this.onSearchClick, required this.onInfoClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        "Notes",
        style: TextStyle(
          fontFamily: AppConstants.defaultFont,
          fontSize: 43,
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        _actionButtons(onSearchClick, Icons.search),
        const SizedBox(
          width: 20,
        ),
        _actionButtons(onInfoClick, Icons.info_outline),
        const SizedBox(
          width: 25,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget _actionButtons(VoidCallback onItemClick, IconData icon) {
    return Wrap(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: HexColor.fromHexString("3B3B3B")),
          child: IconButton(
            onPressed: onItemClick,
            icon: Icon(
              icon,
              color: Colors.white,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
