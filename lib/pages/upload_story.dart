import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:storify/widgets/header.dart';

class UploadStory extends StatefulWidget {
  @override
  _UploadStoryState createState() => _UploadStoryState();
}

class _UploadStoryState extends State<UploadStory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Upload Story',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Text('upload story'),
    );
  }
}
