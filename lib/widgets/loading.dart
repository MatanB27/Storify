import 'package:flutter/material.dart';

// In case we are waiting for fetching data from the database,
// We will show a spinner that will indicate us that the data has not
// fetched yet.
Container loading() {
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
