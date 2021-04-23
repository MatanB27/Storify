import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/user.dart';
import 'package:storify/widgets/loading.dart';

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

  sendMessage() {
    return TextField();
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
        body: ListView(
          children: [
            messageBubbleStream(),
            sendMessage(),
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
