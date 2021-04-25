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
import '../widgets/loading.dart';
import 'home.dart';
import 'home.dart';
import 'home.dart';
import 'home.dart';

// Global variables:
// Current room
String currentRoom;

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
                }),
          ],
        );
      },
    );
  }

  //if we send a message and it the first message -
  //it will be created in firebase
  //TODO: NOT WORKING IF WE SEND THE FIRST MESSAGE - CHECK!!
  sendMessage() async {
    timestampNow = DateTime.now();
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
      Map<dynamic, dynamic> mapRooms = myDocUser.get('messages');
      mapRooms.forEach((key, value) {
        if (key == widget.privateId) {
          currentRoom = value.toString();
        }
      });
      // We are creating it before so it wont give me bugs
      chatRef.doc(currentRoom).collection('messageId').doc(messageId);
      //TODO: not working well, check first message
      DocumentSnapshot docRoom = await chatRef.doc(currentRoom).get();
      String senderId = myDocUser.get('id').toString();
      String senderName = myDocUser.get('displayName').toString();

      if (!docRoom.exists) {
        chatRef.doc(currentRoom).collection('messageId').doc(messageId).set({
          'id': senderId,
          'sender': senderName,
          'message': messageText.text.toString(),
          'timestamp': timestampNow,
        });
      }
    }
  }

  sendMessageBlock() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
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
          ),
        ],
      ),
    );
  }

  //disposing the text editor variable when we close the page
  @override
  void dispose() {
    super.dispose();
    messageText.dispose();
  }

  // Streaming all the messages from the firebase
  messageStream() {
    return StreamBuilder(
      stream: chatRef
          .doc(currentRoom)
          .collection('messageId')
          .orderBy('TimeStamp', descending: true)
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
          final time = message.data()['timestamp'];
          final currentUser = message.data()['id'];

          final messageBubble = MessageBubbles(
            sender: messageSender,
            message: messageText,
            timestamp: time,
            isMe: currentUserId == currentUser,
          );
          messageBubbles.add(messageBubble);
        }
        return ListView(
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          children: messageBubbles,
        );
      },
    );
  }

  //TODO: check UI!
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
                  messageStream(),
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

// The UI of the message bubble
class MessageBubbles extends StatelessWidget {
  final String sender;
  final String message;
  final DateTime timestamp;
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
          Text(
            this.sender,
            style: TextStyle(color: Colors.black54, fontSize: 12.0),
          ),
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
        ],
      ),
    );
  }
}
