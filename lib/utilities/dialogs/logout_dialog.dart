import 'package:flutter/material.dart';
import 'package:my_app/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog({
  required BuildContext context,
  required String title,
  required String content,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: title,
    content: content,
    optionsBuilder:
        () => {'Cancel': false, 'Log Out': true},
  ).then((value) => value ?? false);
}
