import 'package:flutter/material.dart';
import 'package:my_app/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showGenericDialog<void>(
    context: context,
    title: title,
    content: message,
    optionsBuilder: () => {'OK': null},
  );
}
