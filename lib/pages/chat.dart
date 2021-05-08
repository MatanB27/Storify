import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/widgets/chat_history.dart';
import 'package:storify/widgets/header.dart';
import 'package:storify/widgets/loading.dart';
import 'home.dart';

class Chat extends StatefulWidget {
  final String chatId;
  Chat({this.chatId});
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // Our own id
  final String currentUserId = auth.currentUser?.uid;

  // All the history chat tickets will be here.
  List<QuerySnapshot> tickets = [];

  // Build the story tickets here
  // We are also using short if command to know which photo or name
  // We are going to display.
  buildStoryTickets() {
    return StreamBuilder(
      stream: chatRef
          .where('ids', arrayContainsAny: [this.currentUserId])
          .orderBy('timeStamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loading();
        }
        List<ChatHistory> tickets = [];
        snapshot.data.docs.forEach((doc) {
          ChatHistory ticket = ChatHistory(
            id: doc.data()['ids'][0],
            otherUserId: currentUserId == doc.data()['ids'][0]
                ? doc.data()['ids'][1]
                : doc.data()['ids'][0],
            message: doc.data()['recentMessage'],
            photoUrl: currentUserId == doc.data()['ids'][0]
                ? doc.data()['photos'][1]
                : doc.data()['photos'][0],
            displayName: currentUserId == doc.data()['ids'][0]
                ? doc.data()['names'][1]
                : doc.data()['names'][0],
            rid: doc.data()['rid'],
            timeStamp: doc.data()['timeStamp'],
          );
          tickets.add(ticket);
        });
        return ListView(children: tickets);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        backgroundColor: Colors.grey[350],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(55.0),
          child: Header(
            title: 'Chat',
          ),
        ),
        body: buildStoryTickets(),
      ),
    );
  }
}
