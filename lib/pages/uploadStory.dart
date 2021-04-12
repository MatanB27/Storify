import 'package:flutter/material.dart';
import 'package:storify/widgets/header.dart';

class UploadStory extends StatefulWidget {
  @override
  _UploadStoryState createState() => _UploadStoryState();
}

class _UploadStoryState extends State<UploadStory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: Header(
          title: 'write your story',
        ),
      ),
      body: Text('upload story'),
    );
  }
}
