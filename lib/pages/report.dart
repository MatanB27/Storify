import 'package:flutter/material.dart';
import 'package:storify/widgets/header.dart';

class Report extends StatefulWidget {
  final String currentUserId;
  final String storyId;

  Report({this.currentUserId, this.storyId});

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  @override
  void initState() {
    super.initState();
    print(widget.currentUserId);
    print(widget.storyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: Header(
          title: 'Report story',
        ),
      ),
      body: Container(),
    );
  }
}
