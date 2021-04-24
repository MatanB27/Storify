import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/chat_class.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/user.dart';
import 'package:storify/widgets/loading.dart';
import 'package:uuid/uuid.dart';

class PrivateMessage extends StatefulWidget {
  final String privateId;

  PrivateMessage({this.privateId});

  @override
  _PrivateMessageState createState() => _PrivateMessageState();
}

class _PrivateMessageState extends State<PrivateMessage> {
  //loading boolean
  bool isLoading = false;
  //the current user who is logged in
  final String currentUserId = auth.currentUser?.uid;
  TextEditingController messageText = TextEditingController();
  String chatRoomId;
  header() {
    return FutureBuilder(
      future: userRef.doc(widget.privateId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loading();
        }
        UserClass user = UserClass.fromDocuments(snapshot.data);
        return AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: GestureDetector(
            onTap: () {
              //TODO: go to profile
              print(widget.privateId);
              print(currentUserId);
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    user.displayName,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
                onPressed: () {
                  //TODO : do something
                }),
          ],
        );
      },
    );
  }

  //if we send a message and it the first message -
  //it will be created in firebase
  //TODO: when we send a message it will go straight to the firebase
  sendMessage() async {
    //creating message map (otherId, roomId) in userRef
    chatRoomId = Uuid().v4();
    if (messageText.text.toString() != '') {
      //text must have words
      DocumentSnapshot myDocUser = await userRef.doc(currentUserId).get();
      Map<dynamic, dynamic> myMapCheck = myDocUser.get('messages');

      if (!myMapCheck.containsKey(widget.privateId) || myMapCheck.isEmpty) {
        userRef.doc(currentUserId).set({
          'messages': {
            widget.privateId: chatRoomId,
          },
        }, SetOptions(merge: true));
      }
      DocumentSnapshot otherDocUser = await userRef.doc(widget.privateId).get();
      Map<dynamic, dynamic> otherMapCheck = otherDocUser.get('messages');
      if (!otherMapCheck.containsKey(currentUserId) || otherMapCheck.isEmpty) {
        userRef.doc(widget.privateId).set({
          'messages': {
            currentUserId: chatRoomId,
          },
        }, SetOptions(merge: true));
      }
      //creating chatRooms in chatRef
      //TODO: create chat rooms!
      Map<dynamic, dynamic> mapValues = myDocUser.get('messages');
      print(mapValues);
      DocumentSnapshot chatDoc = await chatRef.doc(chatRoomId).get();
      if (!chatDoc.exists) {
        chatRef
            .doc(chatRoomId)
            .set({'roomId': chatRoomId}, SetOptions(merge: true));
      }
    }
  }

  sendMessageBlock() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: messageText,
        decoration: InputDecoration(
          hintText: 'Write your message...',
          suffixIcon: IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              sendMessage();
            },
          ),
        ),
      ),
    );
  }

  //disposing the text editor variable when we close the page
  @override
  void dispose() {
    super.dispose();
    messageText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: Scaffold(
        backgroundColor: Colors.grey[350],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(55.0),
          child: header(),
        ),
        body: Column(
          children: [
            Flexible(
              child: ListView(
                children: [
                  messageBubbleStream(),
                ],
              ),
            ),
            sendMessageBlock(),
          ],
        ),
      ),
    );
  }
}

//TODO: build the message
//here we are building the message bubbles
class messageBubbleStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
