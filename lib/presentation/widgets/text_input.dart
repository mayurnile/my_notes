import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/core.dart';

class MyTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final TextInputType inputType;
  final bool obscureText;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final String? initialValue;
  final int maxLines;
  final void Function(String?)? onSaved;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool enabled;
  final Widget? suffix;
  final Widget? prefix;
  final Widget? action;
  final List<TextInputFormatter>? inputFormatters;
  final bool isError;
  final String? errorText;

  const MyTextField({
    this.label,
    required this.hint,
    required this.inputType,
    this.obscureText = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.words,
    this.initialValue,
    this.maxLines = 1,
    this.onSaved,
    this.onChanged,
    this.validator,
    this.controller,
    this.enabled = true,
    this.suffix,
    this.prefix,
    this.action,
    this.inputFormatters,
    this.isError = false,
    this.errorText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            //heading text
            if (label != null)
              Text(
                label!,
                key: const ValueKey('label'),
                style: textTheme.headline6,
              ),
            //spacing
            const Spacer(),
            //action
            if (action != null) action!,
          ],
        ),
        //spacing
        const SizedBox(height: 6.0),
        //textfield
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: TextFormField(
            controller: controller,
            style: textTheme.headline5!.copyWith(
              fontWeight: FontWeight.w700,
              color: isError ? MyNotesTheme.errorColor : MyNotesTheme.fontDarkColor,
              fontSize: 14.0,
              letterSpacing: obscureText ? 5.0 : 0.8,
            ),
            autofocus: autofocus,
            keyboardType: inputType,
            textCapitalization: textCapitalization,
            obscureText: obscureText,
            initialValue: initialValue,
            maxLines: maxLines,
            onSaved: onSaved,
            onChanged: onChanged,
            validator: validator,
            enabled: enabled,
            decoration: InputDecoration(
              prefixIcon: prefix,
              errorText: errorText,
              hintText: hint,
              hintStyle: textTheme.headline5,
              errorStyle: const TextStyle(
                color: Color(0xFFFF3F34),
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
              focusColor: MyNotesTheme.primaryColor,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: MyNotesTheme.primaryColor,
                  width: 2.0,
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: MyNotesTheme.fontLightColor,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(
                  color: MyNotesTheme.fontLightColor,
                ),
              ),
              suffixIcon: suffix,
            ),
            inputFormatters: inputFormatters,
          ),
        ),
      ],
    );
  }
}
