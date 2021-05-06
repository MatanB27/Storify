import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/auth_service.dart';
import 'package:storify/pages/profile.dart';
import 'package:storify/user.dart';
import 'package:storify/widgets/loading.dart';
import '../widgets/loading.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;

class PrivateMessage extends StatefulWidget {
  final String privateId;
  final String currentRoomId;
  PrivateMessage({this.privateId, this.currentRoomId});

  @override
  _PrivateMessageState createState() => _PrivateMessageState();
}

class _PrivateMessageState extends State<PrivateMessage> {
  //the current user who is logged in
  final String currentUserId = auth.currentUser?.uid;

  // TextEditingController variable for sending a message
  TextEditingController messageText = TextEditingController();

  // Current chat room id
  String chatRoomId;

  // Variable to get the photo Url from the user database.
  String otherUserPhotoUrl;

  // Variable to get the display name from the user database.
  String otherUserDisplayName;

  // Variable to get the photo Url from the user database.
  String thisUserPhotoUrl;

  // Variable to get the display name from the user database.
  String thisUserDisplayName;

  getOtherUserPhotoAndName() async {
    DocumentSnapshot otherDoc = await userRef.doc(widget.privateId).get();
    otherUserPhotoUrl = otherDoc.get('photoUrl');
    otherUserDisplayName = otherDoc.get('displayName');

    DocumentSnapshot thisDoc = await userRef.doc(currentUserId).get();
    thisUserDisplayName = thisDoc.get('displayName');
    thisUserPhotoUrl = thisDoc.get('photoUrl');
  }

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(
                    profileId: widget.privateId,
                  ),
                ),
              );
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
                  //TODO : do something, might delete this icon
                  print(widget.currentRoomId);
                }),
          ],
        );
      },
    );
  }

  // When we click send - it will send the data to the Firebase.
  sendMessage() async {
    // Text must have words
    if (messageText.text.toString() != '') {
      print(widget.currentRoomId);

      DocumentSnapshot doc = await userRef.doc().get();

      String messageTXT = messageText.text.toString();

      //clearing the message after sending it
      messageText.clear();

      // Building the message document
      await messageRef
          .doc(widget.currentRoomId)
          .collection('messagesId')
          .doc(doc.id)
          .set({
        'message': messageTXT,
        'timeStamp': DateTime.now(),
        'sender': thisUserDisplayName,
        'messageId': doc.id,
        'senderId': currentUserId,
      });

      // Building the chatRef room
      await chatRef.doc(widget.currentRoomId).set({
        'ids': [currentUserId, widget.privateId],
        'rid': widget.currentRoomId,
        'names': [thisUserDisplayName, otherUserDisplayName],
        'photos': [thisUserPhotoUrl, otherUserPhotoUrl],
        'recentMessage': messageTXT,
        'timeStamp': DateTime.now(),
      }, SetOptions(merge: true));
    }
  }

  sendMessageBlock() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        controller: messageText,
        obscureText: false,
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

  // Initstate - creating a room in firebase.
  @override
  void initState() {
    super.initState();
    getOtherUserPhotoAndName();
    // getMessagesId();
    print(widget.currentRoomId);
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
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MessageStream(
                  currentUserId: currentUserId,
                  currentRoomId: widget.currentRoomId,
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
  MessageStream({
    this.currentRoomId,
    this.currentUserId,
  });
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: messageRef
          .doc(currentRoomId)
          .collection('messagesId')
          .orderBy('timeStamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loading();
        }
        final messages = snapshot.data.docs;
        var currentUser;
        List<MessageBubbles> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data()['message'];
          final messageSender = message.data()['sender'];
          final time = message.data()['timeStamp'];
          final currentUser = message.data()['senderId'];
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
              children: messageBubbles),
        );
      },
    );
  }
}

// When we click on the chat history tickets - it will send us to the
//Private message page, We are using this method in chat_history widget
showPrivateMessage(BuildContext context, {String privateId, String roomId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PrivateMessage(
        privateId: privateId,
        currentRoomId: roomId,
      ),
    ),
  );
}
