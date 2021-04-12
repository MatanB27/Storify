import 'package:flutter/material.dart';
import 'package:storify/widgets/header.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: Header(
          title: 'Feed',
        ),
      ),
      body: Text('feed'),
    );
  }
}
