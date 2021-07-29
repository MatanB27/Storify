import 'package:flutter/material.dart';
import 'package:storify/services/database.dart';
import 'package:storify/services/scaffold_message.dart';
import 'package:storify/widgets/header.dart';

class Report extends StatefulWidget {
  final String currentUserId;
  final String storyId;

  Report({this.currentUserId, this.storyId});

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  // Controller of the textfield
  TextEditingController reportController = TextEditingController();

  // Function that will send the report to the firebase
  reportStoryToFirebase() {
    if (reportController.text.toString().trim().length > 10) {
      reportsRef.doc().set({
        'userReporting': widget.currentUserId,
        'storyReported': widget.storyId,
        'text': reportController.text.toString(),
      });
      showMessage(context, "Story has been reported successfully!");
      Navigator.pop(context);
    } else {
      showMessage(context, "You must write at least 10 characters");
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget.currentUserId);
    print(widget.storyId);
  }

  @override
  void dispose() {
    super.dispose();
    reportController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff09031D),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: Header(
          title: 'Report story',
        ),
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(42.0),
          child: Column(
            children: [
              Text(
                "Why do you want to report this story?",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                controller: reportController,
                maxLength: 100,
                maxLines: 20,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  hintText: 'Type here...',
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              SizedBox(
                height: 18.0,
              ),
              Container(
                color: Colors.blueAccent,
                child: FlatButton(
                  onPressed: () {
                    reportStoryToFirebase();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Report',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
