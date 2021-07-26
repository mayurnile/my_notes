import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

import '../../core/core.dart';
import '../../core/models/models.dart';
import '../../providers/notes_provider.dart';
import './widgets.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({
    Key? key,
    required this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: MyNotesTheme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //title bar
          _buildTitleBar(context, textTheme),
          //spacing
          const SizedBox(height: 4.0),
          //description
          Text(
            note.description,
            style: textTheme.headline5!.copyWith(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          //spacing
          const SizedBox(height: 8.0),
          //image
          _buildImage(screenSize),
          //time
          _buildRecordTime(textTheme),
        ],
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //title
        Text(
          note.title,
          style: textTheme.headline4,
        ),
        //options button
        IconButton(
          onPressed: () => _showOptions(context, textTheme),
          padding: const EdgeInsets.all(0.0),
          alignment: Alignment.centerRight,
          icon: const Icon(
            Icons.more_horiz,
            color: MyNotesTheme.primaryColor,
            size: 24.0,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordTime(TextTheme textTheme) {
    String recordTime = '';
    final DateTime now = DateTime.now();

    final Duration duration = now.difference(note.createdTime);

    if (duration > const Duration(hours: 5)) {
      final DateFormat formatter = DateFormat('d MMM, y');
      recordTime = formatter.format(note.createdTime);
    } else if (duration > const Duration(minutes: 59)) {
      recordTime = '${duration.inHours} hour ago';
    } else {
      recordTime = '${duration.inMinutes} min ago';
    }

    return Text(
      recordTime,
      style: textTheme.headline5,
    );
  }

  Widget _buildImage(Size screenSize) {
    return note.imagePath!.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: SizedBox(
              width: screenSize.width,
              height: screenSize.height * 0.25,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  note.imagePath!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
  }

  void _showOptions(BuildContext context, TextTheme textTheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          padding: const EdgeInsets.all(22.0),
          decoration:const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              //heading
              Text(
                'Options',
                style: textTheme.headline3,
              ),
              //spacing
              const SizedBox(height: 12.0),
              //options
              OptionButton(
                icon: Assets.edit,
                title: 'Edit',
                onPressed: () {
                  locator.get<NavigationService>().navigateToNamed(
                    addNoteRoute,
                    arguments: {
                      'note': note,
                      'isEdit': true,
                    },
                  );
                },
              ),
              //divider
              const Divider(
                color: MyNotesTheme.fontLightColor,
                indent: 32.0,
                endIndent: 32.0,
              ),
              OptionButton(
                icon: Assets.share,
                title: 'Share',
                onPressed: () async {
                  final NotesProvider _notesProvider = Get.find();
                  final url = await _notesProvider.shareNote(noteID: note.id!);
                  Navigator.of(context).pop();

                  Share.share('Hey checkout my note:\n $url');
                },
              ),
              //divider
              const Divider(
                color: MyNotesTheme.fontLightColor,
                indent: 32.0,
                endIndent: 32.0,
              ),
              OptionButton(
                icon: Assets.remove,
                title: 'Remove',
                onPressed: () async {
                  final NotesProvider _notesProvider = Get.find();
                  final result =
                      await _notesProvider.removeNote(noteId: note.id!);

                  if (result) {
                    Fluttertoast.showToast(msg: 'Note Removed !');
                  } else {
                    Fluttertoast.showToast(msg: 'Something went wrong...');
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
