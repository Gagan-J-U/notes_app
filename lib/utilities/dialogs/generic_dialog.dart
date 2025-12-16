import 'package:flutter/material.dart';

typedef DialogOptionBuilder<t> = Map<String, t?> Function();

Future<t?> showGenericDialog<t>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder<t> optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<t>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions:
            options.keys.map((optionTitle) {
              final optionValue = options[optionTitle];
              return TextButton(
                onPressed: () {
                  Navigator.of(context).pop(optionValue);
                },
                child: Text(
                  optionTitle,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
      );
    },
  );
}
