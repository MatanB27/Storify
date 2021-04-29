import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/widgets/chat_history.dart';
import 'package:storify/widgets/header.dart';
import 'package:storify/widgets/loading.dart';

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
  List<String> roomsUserList = [];

  // All the chat rooms will be in this variable
  List<String> roomsChatList = [];

  // All the history chat tickets will be here.
  List<QuerySnapshot> tickets = [];

  // Getting all the current user rooms in a list of Id rooms.
  //TODO: fix the chat history
  getUserRooms() async {
    DocumentSnapshot myDocUser = await userRef.doc(currentUserId).get();
    Map<dynamic, dynamic> userRoomsMap = await myDocUser.get('messages');

    userRoomsMap.forEach((key, value) async {
      roomsUserList.add(value);
    });
    print(roomsChatList);
    print(roomsUserList);
    roomsChatList = [];
    roomsUserList = [];
  }

  // Getting a stream of the chat
  getChatStream() {
    return chatRef
        .doc('ae3f209f-3497-417e-92dd-5815d06e3762')
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
            id: doc.data()['senderId'],
            otherUserId: doc.data()['getterId'],
            message: doc.data()['message'],
            photoUrl: 'image',
            displayName: 'other user name',
            rid: doc.data()['rid'],
            timeStamp: doc.data()['timeStamp'],
          );
          tickets.add(ticket);
        });
        return ListView(
          children: tickets,
        );
      },
    );
  }

  // Container(
  // //TODO: delete it, just to check
  // height: 50,
  // width: 50,
  // child: FlatButton(
  // child: Text(element),
  // onPressed: () {
  // //getUserRooms();
  // print(element);
  // },
  // ),
  // ),
  // tickets,

  @override
  void initState() {
    super.initState();
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
