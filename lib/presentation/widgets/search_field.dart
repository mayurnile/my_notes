import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_notes/providers/notes_provider.dart';

import '../../core/core.dart';

class SearchField extends StatelessWidget {
  final NotesProvider _notesProvider = Get.find();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(top: 32.0),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(52.0),
        border: Border.all(
          color: MyNotesTheme.FONT_LIGHT_COLOR,
          width: 2.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //input field
          Flexible(
            child: TextField(
              onChanged: (String value) =>
                  _notesProvider.searchNotes(value.trim()),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search Notes',
                hintStyle: textTheme.headline5,
              ),
            ),
          ),
          //search icon
          SvgPicture.asset(
            Assets.SEARCH,
            height: 22.0,
            width: 22.0,
          )
        ],
      ),
    );
  }
}
