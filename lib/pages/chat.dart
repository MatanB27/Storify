import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/widgets/header.dart';
import 'package:storify/widgets/user_ticket.dart';

class Chat extends StatefulWidget {
  final String chatId;
  Chat({this.chatId});
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(55.0),
          child: Header(
            title: 'Chat',
          ),
        ),
        body: ListView(
          children: [],
        ),
      ),
    );
  }
}
