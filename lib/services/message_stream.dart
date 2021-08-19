import 'package:flutter/material.dart';
import 'package:storify/pages/private_message.dart';
import 'package:storify/services/database.dart';
import 'package:storify/widgets/loading.dart';

/*
  The code where we are getting the messages in the room between the two
  users.
  This class will be used in private message page.
 */
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
          return loadingCircular();
        }
        final messages = snapshot.data.docs;
        var currentUser; //TODO: maybe delete
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
