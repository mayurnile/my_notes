import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/core.dart';

class AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //logo
          SvgPicture.asset(
            Assets.LOGO,
            width: screenSize.width * 0.25,
          ),
          //title
          SizedBox(
            width: screenSize.width,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'My Notes',
                style: textTheme.headline1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
