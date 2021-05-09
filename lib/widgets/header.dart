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
        color: Colors.black, //change your color here
      ),
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
