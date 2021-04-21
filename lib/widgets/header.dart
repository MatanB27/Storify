import 'package:flutter/material.dart';
import 'package:storify/pages/chat.dart';

class Header extends StatelessWidget {
  String title;

  Header({
    this.title,
  });
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
