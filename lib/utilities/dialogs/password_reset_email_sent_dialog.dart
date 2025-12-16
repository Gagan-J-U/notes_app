import 'package:flutter/material.dart';
import 'package:my_app/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetEmailSentDialog(
  BuildContext context,
) async {
  return showGenericDialog(
    context: context,
    title: 'PassWord Reset',
    content:
        'we have sent you a password reset link.Please check ur email',
    optionsBuilder: () => {'OK': null},
  );
}
