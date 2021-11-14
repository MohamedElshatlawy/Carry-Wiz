import 'package:Carrywiz/components/delete-confirmation-dialog.dart';
import 'package:flutter/material.dart';

class DialogHelper {
  static exit(context) => showDialog(
      context: context, builder: (context) => DeleteConfirmationDialog());
}
