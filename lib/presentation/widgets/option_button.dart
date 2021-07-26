import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OptionButton extends StatelessWidget {
  final String? icon;
  final String? title;
  final void Function()? onPressed;

  const OptionButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            //icon
            SvgPicture.asset(
              icon!,
              height: 22.0,
              width: 22.0,
            ),
            //spacing
            const SizedBox(width: 16.0),
            //title
            Text(
              title!,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
