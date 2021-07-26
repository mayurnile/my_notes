import 'package:flutter/material.dart';
import 'package:my_notes/core/core.dart';

class NoNotesError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        margin: EdgeInsets.only(top: screenSize.height * 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28.0),
        width: screenSize.width,
        decoration: BoxDecoration(
          color: MyNotesTheme.primaryColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            //heading text
            Text(
              'Write down your ideas !',
              style: textTheme.headline2!.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            //spacing
            const SizedBox(height: 12.0),
            //body text
            Text(
              "You haven't taken any notes, click the plus icon below and start creating notes for you to remember...",
              style: textTheme.headline3!.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
