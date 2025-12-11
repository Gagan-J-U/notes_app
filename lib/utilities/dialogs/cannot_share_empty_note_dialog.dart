import 'package:flutter/material.dart';
import 'package:my_app/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog({
  required BuildContext context,
}) {
  return showGenericDialog<void>(
    context: context,
    title: 'Cannot Share Empty Note',
    content:
        'Please add some content to the note before sharing.',
    optionsBuilder: () => {'OK': null},
  );
}
