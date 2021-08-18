import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storify/pages/home.dart';
import 'package:storify/services/auth_service.dart';
import 'package:storify/services/database.dart';
import 'package:storify/services/message_stream.dart';
import 'package:storify/services/navigator_to_pages.dart';
import 'package:storify/user.dart';
import 'package:storify/services/loading.dart';
import '../services/loading.dart';
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

  /*
  We built an header just for this page, we didn't use the other Header component
  Because its not fit.
   */
  header() {
    return FutureBuilder(
      future: userRef.doc(widget.privateId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loadingCircular();
        }
        UserClass user = UserClass.fromDocuments(snapshot.data);
        return AppBar(
          backgroundColor: Color(0xff09031D),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => goBack(context),
          ),
          title: GestureDetector(
            onTap: () {
              showProfile(context, profileId: widget.privateId);
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
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
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
    return Container(
      margin: EdgeInsets.all(15.0),
      height: 61,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35.0),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 3), blurRadius: 5, color: Colors.grey)
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.face,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageText,
                      obscureText: false,
                      decoration: InputDecoration(
                          hintText: "Type Something...",
                          hintStyle: TextStyle(color: Colors.blueAccent),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(width: 15),
                  InkWell(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                          color: Colors.blueAccent, shape: BoxShape.circle),

                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),


                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 15),
        ],
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
        backgroundColor: Color(0xff1C1A32),
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
                  border: Border(),
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
        ),
      ),
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
            color: isMe ? Color(0xff6F61E8) : Color(0xff2B2250),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                this.message,
                style: TextStyle(color: isMe ? Colors.white : Colors.white),
              ),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            timeago.format(this.timestamp.toDate()),
            style: TextStyle(color: Colors.grey, fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}
