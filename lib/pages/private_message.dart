import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/chat_class.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/user.dart';
import 'package:storify/widgets/loading.dart';
import 'package:uuid/uuid.dart';
import '../widgets/loading.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;
// Global variables:

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
  // TextEditingController variable for sending a message
  TextEditingController messageText = TextEditingController();
  // Current chat room id
  String chatRoomId;
  // Message Id generator
  String messageId;
  // Current room
  String currentRoomId;

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
                  print(currentRoomId);
                }),
          ],
        );
      },
    );
  }

  // If we send a message and it the first message -
  // It will be created in firebase
  sendMessage() async {
    if (messageText.text.toString() != '') {
      //text must have words
      print(currentRoomId);
      DocumentSnapshot docRoom = await chatRef.doc(currentRoomId).get();
      DocumentSnapshot myDocUser = await userRef.doc(currentUserId).get();
      String senderId = myDocUser.get('id').toString();
      String senderName = myDocUser.get('displayName').toString();

      if (!docRoom.exists) {
        chatRef.doc(currentRoomId).collection('messageId').doc(messageId).set({
          'id': senderId,
          'sender': senderName,
          'message': messageText.text.toString(),
          'timeStamp': DateTime.now(),
        });
      }
    }
    //clearing the message after sending it
    messageText.clear();
  }

  // Getting the current room
  createRoomInFirebase() async {
    // Creating message map (otherId, roomId) in userRef
    // Creating for both current user && other user
    chatRoomId = Uuid().v4();

    DocumentSnapshot myDocUser = await userRef.doc(currentUserId).get();
    Map<dynamic, dynamic> myMapCheck = await myDocUser.get('messages');

    if (!myMapCheck.containsKey(widget.privateId) || myMapCheck.isEmpty) {
      await userRef.doc(currentUserId).set({
        'messages': {
          widget.privateId: chatRoomId,
        },
      }, SetOptions(merge: true));
    }
    DocumentSnapshot otherDocUser = await userRef.doc(widget.privateId).get();
    Map<dynamic, dynamic> otherMapCheck = await otherDocUser.get('messages');

    if (!otherMapCheck.containsKey(currentUserId) || otherMapCheck.isEmpty) {
      userRef.doc(widget.privateId).set({
        'messages': {
          currentUserId: chatRoomId,
        },
      }, SetOptions(merge: true));
    }
    currentRoomId = chatRoomId;
    myMapCheck.forEach((key, value) {
      if (key == widget.privateId) {
        currentRoomId = value;
      }
    });
    print(otherMapCheck);
  }

  sendMessageBlock() {
    return Padding(
      padding: EdgeInsets.all(8.0),
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

  // Disposing the text editor variable when we close the page
  @override
  void dispose() {
    super.dispose();
    messageText.dispose();
  }

  // Initstate - get the current room.
  @override
  void initState() {
    super.initState();
    createRoomInFirebase();
  }

  // Streaming all the messages from the firebase

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
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MessageStream(
                  currentUserId: currentUserId,
                  currentRoomId: currentRoomId,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: sendMessageBlock(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

// The UI of the message bubble
class MessageBubbles extends StatelessWidget {
  final String sender;
  final String message;
  final Timestamp timestamp;
  bool isMe;

  MessageBubbles({this.sender, this.message, this.timestamp, this.isMe});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 5,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                this.message,
                style: TextStyle(color: isMe ? Colors.white : Colors.black),
              ),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            timeago.format(this.timestamp.toDate()),
            style: TextStyle(color: Colors.black54, fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}

// The code where we are getting the messages in the room between the two
// users.
class MessageStream extends StatelessWidget {
  final String currentRoomId;
  final String currentUserId;

  MessageStream({this.currentRoomId, this.currentUserId});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: chatRef
          .doc(this.currentRoomId)
          .collection('messageId')
          .orderBy('timeStamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loading();
        }
        final messages = snapshot.data.docs;
        List<MessageBubbles> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data()['message'];
          final messageSender = message.data()['sender'];
          final time = message.data()['timeStamp'];
          final currentUser = message.data()['id'];

          final messageBubble = MessageBubbles(
            sender: messageSender,
            message: messageText,
            timestamp: time,
            isMe: this.currentUserId == currentUser,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
    ;
  }
}
