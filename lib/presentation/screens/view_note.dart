import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_notes/providers/auth_provider.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/core.dart';
import '../../core/models/models.dart';
import '../../providers/notes_provider.dart';

class ViewNoteScreen extends StatelessWidget {
  final Note viewNote;

  const ViewNoteScreen({
    Key? key,
    required this.viewNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22.0, 12.0, 22.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //appBar
                  _buildAppBar(textTheme),
                  //new note form
                  _buildNoteData(textTheme),
                  //display image
                  _buildImageView(screenSize),
                  //spacing
                  SizedBox(height: screenSize.height * 0.03),
                  //actions
                  _buildActions(screenSize, textTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(TextTheme textTheme) {
    return Row(
      children: [
        //back button
        InkWell(
          onTap: () => locator.get<NavigationService>().navigateBack(),
          child: SvgPicture.asset(
            Assets.back,
            width: 32.0,
            height: 32.0,
          ),
        ),
        //spacing
        const SizedBox(width: 18.0),
        //title
        Text(
          'View Note',
          style: textTheme.headline2,
        ),
      ],
    );
  }

  Widget _buildNoteData(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //spacing
        const SizedBox(height: 22.0),
        //title
        Text(
          viewNote.title,
          style: textTheme.headline4,
        ),
        //spacing
        const SizedBox(height: 4.0),
        //description
        Text(
          viewNote.description,
          style: textTheme.headline5!.copyWith(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildImageView(Size screenSize) {
    return viewNote.imagePath != null
        ? Padding(
            padding: const EdgeInsets.only(top: 22.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                viewNote.imagePath!,
                width: screenSize.width,
                height: screenSize.height * 0.3,
                fit: BoxFit.cover,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildActions(Size screenSize, TextTheme textTheme) {
    return SizedBox(
      width: screenSize.width,
      child: ElevatedButton(
        onPressed: () async {
          final NotesProvider _notesProvider = Get.find();
          final AuthProvider _authProvider = Get.find();
          File? image;
          if (viewNote.imagePath != null) {
            image = await urlToFile(viewNote.imagePath!);
          }
          _notesProvider.createNewNote(
            firestore: _notesProvider.firestore,
            userId: _authProvider.email ?? '',
            title: viewNote.title,
            description: viewNote.description,
            image: image,
          );

          locator.get<NavigationService>().navigateBack();
        },
        child: Text(
          'Add to My Note',
          style: textTheme.headline4!.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Future<File> urlToFile(String imageUrl) async {
    final rng = Random();
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    // final File file = File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
    final File file = File("$tempPath${rng.nextInt(100)}.png");
    final http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }
}
