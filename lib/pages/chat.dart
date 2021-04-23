import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/auth_service.dart';
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
  //our own id
  final String currentUserId = auth.currentUser?.uid;
  //loading state
  bool isLoading = false;

  //TODO: delete
  List<ChatHistory> chatTickets = [
    ChatHistory(
      id: '123',
      displayName: 'matan',
      timestamp: timestampNow,
      photoUrl: 'https://picsum.photos/250?image=9',
      message: 'my last message.',
    ),
    ChatHistory(
      id: '123',
      displayName: 'abcd',
      timestamp: timestampNow,
      photoUrl: 'https://picsum.photos/250?image=9',
      message: 'my last message.',
    ),
    ChatHistory(
      id: '123',
      displayName: 'efgh',
      timestamp: timestampNow,
      photoUrl: 'https://picsum.photos/250?image=9',
      message: 'my message.',
    ),
  ];

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
            children: chatTickets,
          )),
    );
  }
}
