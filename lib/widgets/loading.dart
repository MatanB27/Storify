import 'package:flutter/material.dart';

Container Loading() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        Colors.lightBlue[900],
      ),
    ),
  );
}
