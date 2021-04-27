import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/chat_class.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/pages/private_message.dart';
import 'package:storify/widgets/chat_history.dart';
import 'package:storify/widgets/header.dart';
import 'package:storify/widgets/loading.dart';
import 'package:storify/widgets/user_ticket.dart';

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

  // Query variable
  Future<QuerySnapshot> chatHistoryResults;

  // All the user rooms will be in this variable
  List<String> roomsUserList = [];

  // All the chat rooms will be in this variable
  List<String> roomsChatList = [];

  // All the history chat tickets will be here.
  List<QuerySnapshot> tickets = [];

  // Getting all the current user rooms in a list of Id rooms.
  //TODO: fix the chat history
  getRooms() async {
    roomsUserList = [];
    //roomsChatList = [];
    DocumentSnapshot myDocUser = await userRef.doc(currentUserId).get();
    Map<dynamic, dynamic> userRoomsMap = await myDocUser.get('messages');
    userRoomsMap.forEach((key, value) {
      roomsUserList.add(value);
    });
    print(roomsUserList);
    roomsUserList.forEach((element) async {
      String chatDoc = await chatRef.doc(element).get();
      roomsChatList.add(chatDoc.toString());
    });
    print(roomsChatList);
  }

  // Build the story tickets here
  buildStoryTickets() {
    return FutureBuilder(
      future: chatRef.get().then((snapshot) {
        snapshot.docs.forEach((element) {});
      }),
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
        body: ListView(
          children: [
            //buildStoryTickets(),
            Container(
              height: 100,
              width: 100,
              child: FlatButton(onPressed: () {
                getRooms();
              }),
            ),
          ],
        ),
      ),
    );
  }
}
