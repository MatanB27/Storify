import 'package:flutter/material.dart';
/*
  This method will be used when we need to give some kind of an alert
  To the page.
 */

showMessage(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {}, // No need to put anything, just click "Undo"
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
