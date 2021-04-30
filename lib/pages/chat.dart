import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/widgets/chat_history.dart';
import 'package:storify/widgets/header.dart';
import 'package:storify/widgets/loading.dart';

import 'home.dart';
import 'home.dart';
import 'home.dart';
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

  // Loading state
  bool isLoading = false;

  // All the user rooms will be in this variable
  List<String> currentUserRoomList = [];

  // All the history chat tickets will be here.
  List<QuerySnapshot> tickets = [];

  // // Getting all the current user rooms in a list of Id rooms.
  // //TODO: fix the chat history
  getUserRooms() async {
    currentUserRoomList.clear();
    DocumentSnapshot myDocUser = await userRef.doc(currentUserId).get();
    Map<dynamic, dynamic> userRoomsMap = await myDocUser.get('messages');

    userRoomsMap.forEach((key, value) async {
      currentUserRoomList.add(value);
    });
    print(currentUserRoomList);
  }

  // Getting a stream of the chat
  getChatStream() {
    return chatRef
        .doc(currentUserRoomList.first)
        .collection('messageId')
        .orderBy('timeStamp', descending: true)
        .limit(1)
        .snapshots();
  }

  // Build the story tickets here
  buildStoryTickets() {
    return StreamBuilder(
      stream: getChatStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loading();
        }
        List<ChatHistory> tickets = [];
        snapshot.data.docs.forEach((doc) {
          ChatHistory ticket = ChatHistory(
            id: doc.data()['id'],
            otherUserId: doc.data()['otherId'],
            message: doc.data()['message'],
            photoUrl: currentUserId == doc.data()['id']
                ? doc.data()['photos'][1]
                : doc.data()['photos'][0],
            displayName: currentUserId == doc.data()['id']
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

  // [
  // Container(
  // //TODO: delete it, just to check
  // height: 50,
  // width: 50,
  // child: FlatButton(
  // child: Text('hey'),
  // onPressed: () {
  // //getUserRooms();
  // getDocs();
  // },
  // ),
  // ),
  // ],
  // When we are leaving the page it will make the lists empty
  @override
  void dispose() {
    super.dispose();
    currentUserRoomList.clear();
  }

  // Init state of the app
  @override
  void initState() {
    super.initState();
    getUserRooms();
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
