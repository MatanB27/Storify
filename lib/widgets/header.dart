import 'package:flutter/material.dart';

// The Appbar in most of our pages

class Header extends StatelessWidget {
  String title;

  Header({
    this.title,
  });
  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.white, //change your color here
      ),
      backgroundColor: Color(0xff09031D),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
